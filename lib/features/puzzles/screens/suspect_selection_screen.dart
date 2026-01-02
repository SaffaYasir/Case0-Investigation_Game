import 'package:flutter/material.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/constants/app_colors.dart';

class SuspectSelectionScreen extends StatefulWidget {
final List<String> suspects;
final Function(String) onSuspectSelected;
final String correctSuspect;

const SuspectSelectionScreen({
super.key,
required this.suspects,
required this.onSuspectSelected,
required this.correctSuspect,
});

@override
State<SuspectSelectionScreen> createState() => _SuspectSelectionScreenState();
}

class _SuspectSelectionScreenState extends State<SuspectSelectionScreen> {
String? _selectedSuspect;

String _getCharacterImage(String suspectName) {
final name = suspectName.toLowerCase().trim();

// Case 1 suspects
if (name.contains('victoria')) return AppImages.victoria;
if (name.contains('henry') || name.contains('butler')) return AppImages.henryButler;
if (name.contains('chloe')) return AppImages.chloe;
if (name.contains('james')) return AppImages.james;

// Case 2 suspects
if (name.contains('alex') || name.contains('carter')) return AppImages.alexCarter;
if (name.contains('miller') || name.contains('officer')) return AppImages.officerMiller;
if (name.contains('shadow')) return AppImages.shadow;
if (name.contains('mayor') || name.contains('assistant') || name.contains('david') || name.contains('chen'))
return AppImages.mayorAssistant;

// Default fallback
return AppImages.detectiveSilhouette;
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: Colors.black.withOpacity(0.95),
body: Container(
decoration: BoxDecoration(
image: DecorationImage(
image: AssetImage(AppImages.case2CrimeScene),
fit: BoxFit.cover,
colorFilter: ColorFilter.mode(
Colors.black.withOpacity(0.8),
BlendMode.darken,
),
),
),
child: SafeArea(
child: Column(
children: [
// Header
Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: Colors.black.withOpacity(0.8),
border: Border(
bottom: BorderSide(color: AppColors.neonRed, width: 2),
),
),
child: Column(
children: [
Text(
"FINAL ACCUSATION",
style: TextStyle(
color: AppColors.neonRed,
fontSize: 28,
fontWeight: FontWeight.bold,
letterSpacing: 3,
fontFamily: 'Courier New',
),
),
const SizedBox(height: 8),
Text(
"Select the guilty suspect",
style: TextStyle(
color: Colors.white,
fontSize: 16,
fontFamily: 'Courier New',
),
),
],
),
),

// Instructions
Container(
padding: const EdgeInsets.all(16),
margin: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.black.withOpacity(0.6),
borderRadius: BorderRadius.circular(12),
border: Border.all(color: AppColors.neonBlue, width: 1),
),
child: Row(
children: [
Icon(Icons.warning, color: AppColors.neonOrange, size: 24),
const SizedBox(width: 12),
Expanded(
child: Text(
"Choose carefully. Accusing the wrong person will fail the case.",
style: TextStyle(
color: Colors.white,
fontSize: 14,
),
),
),
],
),
),

// Suspects Grid
Expanded(
child: GridView.builder(
padding: const EdgeInsets.all(16),
gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 2,
childAspectRatio: 0.75,
crossAxisSpacing: 16,
mainAxisSpacing: 16,
),
itemCount: widget.suspects.length,
itemBuilder: (context, index) {
final suspect = widget.suspects[index];
final isSelected = _selectedSuspect == suspect;

return _buildSuspectCard(suspect, isSelected);
},
),
),

// Confirmation Button
Padding(
padding: const EdgeInsets.all(20),
child: ElevatedButton(
onPressed: _selectedSuspect == null
? null
    : () => widget.onSuspectSelected(_selectedSuspect!),
style: ElevatedButton.styleFrom(
backgroundColor: _selectedSuspect == null
? Colors.grey[800]
    : AppColors.neonRed,
minimumSize: const Size(double.infinity, 60),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
elevation: 8,
shadowColor: AppColors.neonRed.withOpacity(0.5),
),
child: Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(Icons.gavel, color: Colors.white, size: 24),
const SizedBox(width: 12),
Text(
"MAKE ACCUSATION",
style: TextStyle(
color: Colors.white,
fontSize: 18,
fontWeight: FontWeight.bold,
letterSpacing: 1.5,
),
),
],
),
),
),
],
),
),
),
);
}

Widget _buildSuspectCard(String suspect, bool isSelected) {
return GestureDetector(
onTap: () => setState(() => _selectedSuspect = suspect),
child: AnimatedContainer(
duration: const Duration(milliseconds: 300),
decoration: BoxDecoration(
color: Colors.black,
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: isSelected ? AppColors.neonRed : Colors.grey[800]!,
width: isSelected ? 3 : 2,
),
boxShadow: isSelected
? [
BoxShadow(
color: AppColors.neonRed.withOpacity(0.5),
blurRadius: 15,
spreadRadius: 2,
),
]
    : [
BoxShadow(
color: Colors.black.withOpacity(0.5),
blurRadius: 10,
spreadRadius: 1,
),
],
),
child: Column(
children: [
// Suspect Image
Expanded(
child: ClipRRect(
borderRadius: const BorderRadius.vertical(
top: Radius.circular(14),
),
child: Container(
color: Colors.grey[900],
child: Image.asset(
_getCharacterImage(suspect),
fit: BoxFit.cover,
width: double.infinity,
errorBuilder: (context, error, stackTrace) {
debugPrint('Image error for $suspect: $error');
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
Icons.person,
color: Colors.grey[600],
size: 60,
),
const SizedBox(height: 8),
Text(
suspect,
style: TextStyle(
color: Colors.grey[600],
fontSize: 14,
),
textAlign: TextAlign.center,
),
],
),
);
},
),
),
),
),

// Suspect Name
Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: isSelected
? AppColors.neonRed.withOpacity(0.2)
    : Colors.black,
borderRadius: const BorderRadius.vertical(
bottom: Radius.circular(14),
),
),
child: Center(
child: Text(
suspect.toUpperCase(),
style: TextStyle(
color: isSelected ? AppColors.neonRed : Colors.white,
fontSize: 14,
fontWeight: FontWeight.bold,
letterSpacing: 1.2,
),
textAlign: TextAlign.center,
),
),
),
],
),
),
);
}
}
