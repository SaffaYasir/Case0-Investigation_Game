import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';

class TermsAcceptanceDialog extends StatelessWidget {
final VoidCallback onAccept;
final VoidCallback onDecline;

const TermsAcceptanceDialog({
super.key,
required this.onAccept,
required this.onDecline,
});

@override
Widget build(BuildContext context) {
return Dialog(
backgroundColor: AppColors.darkestGray,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(20),
side: BorderSide(color: AppColors.neonRed, width: 2),
),
child: ConstrainedBox( // ADD THIS: Constrain the height
constraints: BoxConstraints(
maxHeight: MediaQuery.of(context).size.height * 0.85, // Limit to 85% of screen height
),
child: Column(
mainAxisSize: MainAxisSize.min, // Keep it as small as possible
children: [
// Fixed header
Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: AppColors.darkGray,
borderRadius: const BorderRadius.only(
topLeft: Radius.circular(20),
topRight: Radius.circular(20),
),
),
child: Row(
children: [
const SizedBox(width: 40), // Space for alignment
Expanded(
child: Center(
child: Text(
'TERMS & CONDITIONS',
style: TextStyle(
color: AppColors.neonRed,
fontSize: 18,
fontWeight: FontWeight.bold,
letterSpacing: 2,
),
),
),
),
IconButton(
onPressed: () => Navigator.pop(context),
icon: Icon(Icons.close, color: AppColors.neonRed),
),
],
),
),

// Scrollable content
Expanded( // ADD THIS: Make content scrollable
child: SingleChildScrollView(
padding: const EdgeInsets.all(20),
child: Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
// Important Note
Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: AppColors.neonRed.withOpacity(0.1),
borderRadius: BorderRadius.circular(10),
border: Border.all(color: AppColors.neonRed),
),
child: Row(
children: [
Icon(Icons.warning, color: AppColors.neonRed, size: 24),
const SizedBox(width: 12),
Expanded(
child: Text(
'Please read and accept our terms before proceeding.',
style: TextStyle(
color: AppColors.textPrimary,
fontWeight: FontWeight.bold,
),
),
),
],
),
),

const SizedBox(height: 20),

// Terms Summary
Text(
'By continuing, you agree to:',
style: TextStyle(
color: AppColors.neonBlue,
fontWeight: FontWeight.bold,
fontSize: 16,
),
),

const SizedBox(height: 10),

_buildTermItem('• Our Privacy Policy (data collection & usage)'),
_buildTermItem('• Terms & Conditions (app usage rules)'),
_buildTermItem('• Acceptable use policy'),
_buildTermItem('• Age restrictions (13+ only)'),

const SizedBox(height: 20),

// Links to Full Terms
Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
TextButton(
onPressed: () {
Navigator.pop(context); // Close dialog first
context.push('/legal/privacy');
},
child: Text(
'View Privacy Policy',
style: TextStyle(color: AppColors.neonBlue),
),
),
TextButton(
onPressed: () {
Navigator.pop(context); // Close dialog first
context.push('/legal/terms');
},
child: Text(
'View Full Terms',
style: TextStyle(color: AppColors.neonBlue),
),
),
],
),

const SizedBox(height: 20),

// Checkbox Agreement
Row(
children: [
Icon(Icons.check_box, color: AppColors.neonGreen, size: 24),
const SizedBox(width: 12),
Expanded(
child: Text(
'I have read and agree to the Terms & Conditions and Privacy Policy',
style: TextStyle(
color: AppColors.textPrimary,
fontSize: 12,
),
),
),
],
),
],
),
),
),

// Fixed footer with buttons
Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: AppColors.darkGray,
borderRadius: const BorderRadius.only(
bottomLeft: Radius.circular(20),
bottomRight: Radius.circular(20),
),
),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
// Decline Button
Expanded(
child: OutlinedButton(
onPressed: onDecline,
style: OutlinedButton.styleFrom(
padding: const EdgeInsets.symmetric(vertical: 14),
side: BorderSide(color: AppColors.neonRed),
),
child: Text(
'DECLINE',
style: TextStyle(
color: AppColors.neonRed,
fontWeight: FontWeight.bold,
),
),
),
),

const SizedBox(width: 16),

// Accept Button
Expanded(
child: ElevatedButton(
onPressed: onAccept,
style: ElevatedButton.styleFrom(
backgroundColor: AppColors.neonRed,
padding: const EdgeInsets.symmetric(vertical: 14),
),
child: const Text(
'ACCEPT',
style: TextStyle(
fontWeight: FontWeight.bold,
),
),
),
),
],
),
),
],
),
),
);
}

Widget _buildTermItem(String text) {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 4),
child: Text(
text,
style: TextStyle(color: AppColors.textPrimary),
),
);
}
}