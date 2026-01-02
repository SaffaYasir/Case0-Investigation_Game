import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:case_zero_detective/core/constants/app_colors.dart';
import 'package:case_zero_detective/core/constants/app_images.dart';
import 'package:case_zero_detective/core/providers/auth_provider.dart';
import 'package:case_zero_detective/core/providers/progress_provider.dart';
import 'package:case_zero_detective/features/auth/terms_acceptance_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends ConsumerStatefulWidget {
const DashboardScreen({super.key});

@override
ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
int _selectedNavIndex = 0;
bool _isSyncing = false;

@override
void initState() {
super.initState();
WidgetsBinding.instance.addPostFrameCallback((_) {
_checkTermsAcceptance();
});
}

void _checkTermsAcceptance() async {
await Future.delayed(const Duration(milliseconds: 1000));

final profileAsync = ref.read(userProfileProvider);

profileAsync.when(
data: (doc) {
if (doc.exists && mounted) {
final acceptedTerms = doc.data()?['acceptedTerms'] as bool? ?? false;
final userId = FirebaseAuth.instance.currentUser?.uid;

if (!acceptedTerms && userId != null && mounted) {
_showTermsAcceptanceDialog(context, userId);
}
}
},
loading: () {},
error: (error, stack) {},
);
}

void _showTermsAcceptanceDialog(BuildContext context, String userId) {
showDialog(
context: context,
barrierDismissible: false,
builder: (context) => TermsAcceptanceDialog(
onAccept: () async {
try {
await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .update({
'acceptedTerms': true,
'termsAcceptedAt': FieldValue.serverTimestamp(),
'updatedAt': FieldValue.serverTimestamp(),
});

if (mounted) {
Navigator.pop(context);
ref.invalidate(userProfileProvider);
}
} catch (e) {
if (mounted) {
Navigator.pop(context);
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Error: $e'),
backgroundColor: AppColors.neonRed,
),
);
}
}
},
onDecline: () {
Navigator.pop(context);
_showLogoutDialog(context);
},
),
);
}

Future<void> _syncProgress() async {
if (_isSyncing) return;

setState(() {
_isSyncing = true;
});

try {
// Force refresh progress from Firebase
ref.invalidate(progressProvider);
ref.invalidate(userProfileProvider);

// Wait for refresh
await Future.delayed(const Duration(seconds: 1));

if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: const Text('Progress synced from cloud'),
backgroundColor: AppColors.neonGreen,
duration: const Duration(seconds: 2),
),
);
}
} catch (e) {
if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Sync failed: $e'),
backgroundColor: AppColors.neonRed,
),
);
}
} finally {
if (mounted) {
setState(() {
_isSyncing = false;
});
}
}
}

@override
Widget build(BuildContext context) {
final profileAsync = ref.watch(userProfileProvider);
final progressAsync = ref.watch(progressProvider);
final screenWidth = MediaQuery.of(context).size.width;
final isLargeScreen = screenWidth > 768;

return Scaffold(
backgroundColor: Colors.black,
body: Stack(
children: [
// Background Image
Positioned.fill(
child: Image.asset(
AppImages.dashboardBg,
fit: BoxFit.cover,
),
),

// Gradient Overlay
Positioned.fill(
child: Container(
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
colors: [
Colors.black.withOpacity(0.4),
Colors.black.withOpacity(0.8),
],
),
),
),
),

// Main Content
SafeArea(
child: Column(
children: [
// Fixed Glass Navbar
_buildGlassNavBar(),

// Scrollable Content
Expanded(
child: SingleChildScrollView(
physics: const BouncingScrollPhysics(),
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
_buildWelcomeSection(profileAsync),
const SizedBox(height: 32),

_buildSectionHeader(
'DASHBOARD OVERVIEW',
onTap: () => context.push('/statistics'),
),
const SizedBox(height: 16),
progressAsync.when(
loading: () => _buildLoadingStats(),
error: (error, stack) => _buildErrorStats(),
data: (progressList) => _buildStatsGrid(progressList, isLargeScreen),
),

const SizedBox(height: 32),
_buildSectionHeader(
'ACTIVE INVESTIGATION',
onTap: () => context.push('/cases'),
),
const SizedBox(height: 16),
progressAsync.when(
loading: () => _buildLoadingCaseCard(),
error: (error, stack) => _buildErrorCaseCard(),
data: (progressList) => Column(
children: [
_buildCaseCard(
context: context,
caseNumber: 1,
progressList: progressList,
),
const SizedBox(height: 16),
_buildCaseCard(
context: context,
caseNumber: 2,
progressList: progressList,
),
],
),
),

const SizedBox(height: 32),
_buildSectionHeader('QUICK ACTIONS'),
const SizedBox(height: 16),
_buildQuickActionsGrid(isLargeScreen),

const SizedBox(height: 40),
_buildLogoutButton(),
const SizedBox(height: 40),
],
),
),
),
),
],
),
),
],
),
);
}

Widget _buildGlassNavBar() {
return ClipRRect(
child: BackdropFilter(
filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
child: Container(
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
decoration: BoxDecoration(
color: Colors.black.withOpacity(0.5),
border: Border(
bottom: BorderSide(color: AppColors.neonRed.withOpacity(0.3), width: 0.5),
),
),
child: Row(
children: [
_buildLogo(),
const SizedBox(width: 12),
Expanded(
child: SizedBox(
height: 42,
child: ListView(
scrollDirection: Axis.horizontal,
physics: const BouncingScrollPhysics(),
children: [
_buildNavItem('Home', Icons.grid_view_rounded, 0),
_buildNavItem('Cases', Icons.folder_copy_outlined, 1),
_buildNavItem('Stats', Icons.query_stats_rounded, 2),
_buildNavItem('Profile', Icons.person_outline_rounded, 3),
_buildNavItem('Settings', Icons.settings_outlined, 4),
],
),
),
),
// Sync Button
_isSyncing
? Container(
width: 38,
height: 38,
padding: const EdgeInsets.all(8),
child: CircularProgressIndicator(
strokeWidth: 2,
color: AppColors.neonBlue,
),
)
    : IconButton(
onPressed: _syncProgress,
icon: Icon(
Icons.sync,
color: AppColors.neonBlue,
),
tooltip: 'Sync progress',
),
const SizedBox(width: 8),
_buildProfileBadge(),
],
),
),
),
);
}

Widget _buildSectionHeader(String title, {VoidCallback? onTap}) {
return Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Row(
children: [
Container(
width: 4,
height: 18,
decoration: BoxDecoration(
color: AppColors.neonRed,
boxShadow: [BoxShadow(color: AppColors.neonRed, blurRadius: 10)],
),
),
const SizedBox(width: 10),
Text(
title,
style: TextStyle(
fontSize: 13,
fontWeight: FontWeight.w900,
color: Colors.white.withOpacity(0.9),
letterSpacing: 2,
shadows: [Shadow(color: AppColors.neonRed.withOpacity(0.5), blurRadius: 5)],
),
),
],
),
if (onTap != null)
GestureDetector(
onTap: onTap,
child: Text(
'VIEW ALL',
style: TextStyle(
color: AppColors.neonRed,
fontSize: 11,
fontWeight: FontWeight.bold,
letterSpacing: 1,
),
),
),
],
);
}

Widget _buildStatsGrid(List<CaseProgress> progressList, bool isLargeScreen) {
final completedCases = progressList.where((p) => p.isCompleted).length;
final totalClues = progressList.fold(0, (total, p) => total + p.cluesFound);
final totalScore = progressList.fold(0, (total, p) => total + p.score);
final totalTime = progressList.fold(0.0, (total, p) => total + p.timeSpent);
final rank = _getRank(completedCases);

return GridView.count(
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
crossAxisCount: isLargeScreen ? 4 : 2,
childAspectRatio: 1.15,
crossAxisSpacing: 16,
mainAxisSpacing: 16,
children: [
_buildStatCardWithImage(
'Active Cases',
progressList.length.toString(),
AppColors.neonRed,
Icons.folder_special,
AppImages.card1Bg,
),
_buildStatCardWithImage(
'Clues Found',
totalClues.toString(),
AppColors.neonBlue,
Icons.manage_search_rounded,
AppImages.card2Bg,
),
_buildStatCardWithImage(
'Time Spent',
'${totalTime.toInt()}m',
AppColors.neonGreen,
Icons.timer,
AppImages.card3Bg,
),
_buildStatCardWithImage(
'Rank',
rank,
AppColors.neonOrange,
Icons.military_tech_rounded,
AppImages.card4Bg,
),
],
);
}

Widget _buildStatCardWithImage(String title, String value, Color color, IconData icon, String bgImage) {
return Container(
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(20),
image: DecorationImage(image: AssetImage(bgImage), fit: BoxFit.cover),
border: Border.all(color: color.withOpacity(0.3), width: 1),
boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 15)],
),
child: ClipRRect(
borderRadius: BorderRadius.circular(20),
child: BackdropFilter(
filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
child: Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
gradient: LinearGradient(
begin: Alignment.topLeft,
colors: [Colors.black.withOpacity(0.85), Colors.black.withOpacity(0.3)],
),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Container(
padding: const EdgeInsets.all(8),
decoration: BoxDecoration(
color: color.withOpacity(0.15),
shape: BoxShape.circle,
),
child: Icon(icon, color: color, size: 20),
),
Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
ConstrainedBox(
constraints: const BoxConstraints(
maxHeight: 50,
),
child: FittedBox(
fit: BoxFit.scaleDown,
alignment: Alignment.centerLeft,
child: Text(
value,
style: TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
color: Colors.white,
fontFamily: 'monospace',
),
),
),
),
const SizedBox(height: 2),
Text(
title.toUpperCase(),
style: TextStyle(
color: Colors.white54,
fontSize: 9,
letterSpacing: 1,
fontWeight: FontWeight.w600,
),
),
],
),
],
),
),
),
),
);
}

Widget _buildCaseCard({
required BuildContext context,
required int caseNumber,
required List<CaseProgress> progressList,
}) {
final caseProgress = progressList.firstWhere(
(p) => p.caseNumber == caseNumber,
orElse: () => CaseProgress(
caseNumber: caseNumber,
isCompleted: false,
cluesFound: 0,
timeSpent: 0,
accuracy: 0,
),
);

final isCompleted = caseProgress.isCompleted;
final progressPercentage = isCompleted ? 100 : (caseProgress.cluesFound * 20).clamp(0, 100);
final title = caseNumber == 1 ? 'The Vanished Necklace' : 'Murder at Alley 17';
final thumbnail = caseNumber == 1 ? AppImages.case1Thumbnail : AppImages.case2Cover;
final status = isCompleted ? 'COMPLETED' : 'IN PROGRESS';
final statusColor = isCompleted ? AppColors.neonGreen : AppColors.neonOrange;
final progressColor = isCompleted ? AppColors.neonGreen : AppColors.neonRed;

return GestureDetector(
onTap: () => context.push('/case/$caseNumber'),
child: Container(
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(24),
color: AppColors.darkGray.withOpacity(0.6),
border: Border.all(color: statusColor.withOpacity(0.3)),
),
child: ClipRRect(
borderRadius: BorderRadius.circular(24),
child: BackdropFilter(
filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
child: Padding(
padding: const EdgeInsets.all(16),
child: Row(
children: [
Container(
width: 75,
height: 75,
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(16),
image: DecorationImage(image: AssetImage(thumbnail), fit: BoxFit.cover),
border: Border.all(color: progressColor, width: 1.5),
),
),
const SizedBox(width: 16),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'CASE #$caseNumber • $status',
style: TextStyle(
color: statusColor,
fontSize: 9,
fontWeight: FontWeight.w900,
letterSpacing: 1,
),
),
const SizedBox(height: 4),
Text(
title,
style: const TextStyle(
color: Colors.white,
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 10),
Row(
children: [
_buildMiniStat('Clues', caseProgress.cluesFound.toString(), AppColors.neonBlue),
const SizedBox(width: 12),
_buildMiniStat('Time', '${caseProgress.timeSpent.toInt()}m', AppColors.neonOrange),
const SizedBox(width: 12),
_buildMiniStat('Score', caseProgress.score.toString(), AppColors.neonGreen),
],
),
const SizedBox(height: 8),
Stack(
children: [
Container(
height: 4,
width: double.infinity,
decoration: BoxDecoration(
color: Colors.white10,
borderRadius: BorderRadius.circular(2),
),
),
Container(
width: (progressPercentage / 100) * 200,
height: 4,
decoration: BoxDecoration(
color: progressColor,
borderRadius: BorderRadius.circular(2),
boxShadow: [BoxShadow(color: progressColor, blurRadius: 5)],
),
),
],
),
const SizedBox(height: 6),
Text(
'${progressPercentage}% INVESTIGATED',
style: const TextStyle(color: Colors.white38, fontSize: 9),
),
],
),
),
const Icon(Icons.chevron_right_rounded, color: Colors.white24),
],
),
),
),
),
),
);
}

Widget _buildMiniStat(String label, String value, Color color) {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
label,
style: TextStyle(
color: Colors.white54,
fontSize: 10,
),
),
Text(
value,
style: TextStyle(
color: color,
fontSize: 14,
fontWeight: FontWeight.bold,
),
),
],
);
}

Widget _buildQuickActionsGrid(bool isLargeScreen) {
return GridView.count(
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
crossAxisCount: isLargeScreen ? 4 : 2,
childAspectRatio: 1.4,
crossAxisSpacing: 12,
mainAxisSpacing: 12,
children: [
_buildActionCard('Continue', Icons.play_arrow_rounded, AppColors.neonRed, () => context.push('/case/1')),
_buildActionCard('Archives', Icons.inventory_2_outlined, AppColors.neonBlue, () => context.push('/cases')),
_buildActionCard('Statistics', Icons.bar_chart, AppColors.neonGreen, () => context.push('/statistics')),
_buildActionCard('Rewards', Icons.emoji_events_outlined, AppColors.neonOrange, () => context.push('/achievements')),
],
);
}

Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
return GestureDetector(
onTap: onTap,
child: Container(
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(16),
color: Colors.black.withOpacity(0.4),
border: Border.all(color: color.withOpacity(0.2)),
),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(icon, color: color, size: 28),
const SizedBox(height: 8),
Text(
title.toUpperCase(),
style: const TextStyle(
color: Colors.white,
fontSize: 10,
fontWeight: FontWeight.bold,
letterSpacing: 1,
),
),
],
),
),
);
}

Widget _buildLogoutButton() {
return Center(
child: TextButton.icon(
onPressed: () => _showLogoutDialog(context),
icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white38, size: 18),
label: const Text(
'TERMINATE SESSION',
style: TextStyle(
color: Colors.white38,
letterSpacing: 2,
fontSize: 11,
fontWeight: FontWeight.bold,
),
),
),
);
}

Widget _buildLoadingStats() {
return GridView.count(
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
crossAxisCount: 2,
childAspectRatio: 1.15,
crossAxisSpacing: 16,
mainAxisSpacing: 16,
children: List.generate(
4,
(index) => Container(
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(20),
color: AppColors.darkGray.withOpacity(0.3),
),
child: const Center(child: CircularProgressIndicator(color: AppColors.neonRed)),
),
),
);
}

Widget _buildErrorStats() {
return Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(16),
color: AppColors.darkGray.withOpacity(0.3),
border: Border.all(color: AppColors.neonRed),
),
child: Center(
child: Text(
'Failed to load stats',
style: TextStyle(color: AppColors.textSecondary),
),
),
);
}

Widget _buildLoadingCaseCard() {
return Container(
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(24),
color: AppColors.darkGray.withOpacity(0.3),
),
child: const Padding(
padding: EdgeInsets.all(16),
child: Row(
children: [
SizedBox(width: 75, height: 75, child: CircularProgressIndicator()),
SizedBox(width: 16),
Expanded(child: LinearProgressIndicator()),
],
),
),
);
}

Widget _buildErrorCaseCard() {
return Container(
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(24),
color: AppColors.darkGray.withOpacity(0.3),
border: Border.all(color: AppColors.neonRed),
),
child: Padding(
padding: const EdgeInsets.all(16),
child: Row(
children: [
const Icon(Icons.error, color: AppColors.neonRed),
const SizedBox(width: 16),
Expanded(
child: Text(
'Failed to load cases',
style: TextStyle(color: AppColors.textSecondary),
),
),
],
),
),
);
}

Widget _buildNavItem(String title, IconData icon, int index) {
bool isSelected = _selectedNavIndex == index;
return GestureDetector(
onTap: () {
setState(() => _selectedNavIndex = index);
if (index == 1) context.push('/cases');
if (index == 2) context.push('/statistics');
if (index == 3) context.push('/profile');
if (index == 4) context.push('/settings');
},
child: AnimatedContainer(
duration: const Duration(milliseconds: 200),
margin: const EdgeInsets.only(right: 8),
padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
decoration: BoxDecoration(
color: isSelected ? AppColors.neonRed.withOpacity(0.15) : Colors.transparent,
borderRadius: BorderRadius.circular(12),
border: Border.all(
color: isSelected ? AppColors.neonRed : Colors.transparent,
width: 1,
),
),
child: Row(
children: [
Icon(icon, color: isSelected ? AppColors.neonRed : Colors.white54, size: 18),
if (isSelected) const SizedBox(width: 8),
if (isSelected)
Text(
title,
style: TextStyle(
color: AppColors.neonRed,
fontSize: 12,
fontWeight: FontWeight.bold,
),
),
],
),
),
);
}

Widget _buildLogo() {
return Container(
width: 38,
height: 38,
decoration: BoxDecoration(
shape: BoxShape.circle,
border: Border.all(color: AppColors.neonRed, width: 1.5),
boxShadow: [BoxShadow(color: AppColors.neonRed.withOpacity(0.3), blurRadius: 8)],
),
child: ClipRRect(
borderRadius: BorderRadius.circular(19),
child: Image.asset(AppImages.appLogo, fit: BoxFit.cover),
),
);
}

Widget _buildProfileBadge() {
return Consumer(
builder: (context, ref, child) {
final profileAsync = ref.watch(userProfileProvider);
return profileAsync.when(
data: (doc) {
final rank = doc.exists ? (doc.data()!['rank'] as String? ?? 'Rookie') : 'Rookie';
final name = doc.exists ? (doc.data()!['displayName'] as String? ?? 'A') : 'A';
return GestureDetector(
onTap: () => context.push('/profile'),
child: Stack(
children: [
Container(
width: 38,
height: 38,
decoration: BoxDecoration(
shape: BoxShape.circle,
border: Border.all(color: AppColors.neonRed.withOpacity(0.5)),
color: Colors.white10,
),
child: Center(
child: Text(
name[0].toUpperCase(),
style: TextStyle(
color: AppColors.neonRed,
fontWeight: FontWeight.bold,
),
),
),
),
Positioned(
bottom: 0,
right: 0,
child: CircleAvatar(
radius: 7,
backgroundColor: Colors.black,
child: Image.asset(
AppImages.getRankBadge(rank),
width: 10,
),
),
)
],
),
);
},
loading: () => const SizedBox(
width: 38,
height: 38,
child: CircularProgressIndicator(strokeWidth: 2),
),
error: (_, __) => const Icon(Icons.person, color: Colors.white24),
);
},
);
}

Widget _buildWelcomeSection(AsyncValue<dynamic> profileAsync) {
return profileAsync.when(
data: (doc) {
final name = doc.exists ? (doc.data()!['displayName'] as String? ?? 'AGENT') : 'AGENT';
final rank = doc.exists ? (doc.data()!['rank'] as String? ?? 'Rookie') : 'Rookie';
return Container(
width: double.infinity,
padding: const EdgeInsets.all(24),
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(24),
border: Border.all(color: AppColors.neonRed.withOpacity(0.1)),
gradient: LinearGradient(colors: [Colors.white.withOpacity(0.05), Colors.transparent]),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'OPERATIVE STATUS: ACTIVE',
style: TextStyle(
color: Colors.greenAccent,
fontSize: 9,
fontWeight: FontWeight.w900,
letterSpacing: 2,
),
),
const SizedBox(height: 8),
Text(
'WELCOME, ${name.toUpperCase()}',
style: TextStyle(
fontSize: 24,
fontWeight: FontWeight.w900,
color: AppColors.neonRed,
fontFamily: 'monospace',
letterSpacing: 1,
),
),
const SizedBox(height: 4),
Text(
'CURRENT RANK: $rank',
style: TextStyle(
color: Colors.white38,
fontSize: 12,
letterSpacing: 1,
),
),
],
),
);
},
loading: () => const LinearProgressIndicator(),
error: (_, __) => const Text('WELCOME, DETECTIVE'),
);
}

void _showComingSoon(BuildContext context, String feature) {
showDialog(
context: context,
builder: (context) => BackdropFilter(
filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
child: AlertDialog(
backgroundColor: Colors.black.withOpacity(0.8),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
side: BorderSide(color: AppColors.neonBlue),
),
title: Text(
'ENCRYPTED DATA',
style: TextStyle(
color: AppColors.neonBlue,
fontWeight: FontWeight.bold,
fontSize: 16,
),
),
content: Text(
'$feature is currently under decryption by HQ.',
style: const TextStyle(color: Colors.white70),
),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: Text(
'ACKNOWLEDGED',
style: TextStyle(color: AppColors.neonBlue),
),
),
],
),
),
);
}

void _showLogoutDialog(BuildContext context) {
showDialog(
context: context,
builder: (context) => AlertDialog(
backgroundColor: Colors.black,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
side: BorderSide(color: AppColors.neonRed),
),
title: const Text(
'TERMINATE SESSION?',
style: TextStyle(
color: Colors.white,
fontWeight: FontWeight.bold,
),
),
content: const Text(
'Are you sure you want to disconnect from the mainframe?',
style: TextStyle(color: Colors.white60),
),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: const Text(
'CANCEL',
style: TextStyle(color: Colors.white38),
),
),
ElevatedButton(
style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonRed),
onPressed: () {
Navigator.pop(context);
context.go('/login');
},
child: const Text(
'TERMINATE',
style: TextStyle(fontWeight: FontWeight.bold),
),
),
],
),
);
}

String _getRank(int completedCases) {
if (completedCases >= 10) return 'MASTER DETECTIVE';
if (completedCases >= 5) return 'CHIEF INSPECTOR';
if (completedCases >= 3) return 'DETECTIVE';
if (completedCases >= 1) return 'ROOKIE DETECTIVE';
return 'NOVICE';
}
}
