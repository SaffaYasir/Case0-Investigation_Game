import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../widgets/number_button.dart';

class SafeCodeGame extends StatefulWidget {
final String correctCode;
final List<String> hints;
final Function(bool) onGameComplete;
final int maxAttempts;

const SafeCodeGame({
super.key,
required this.correctCode,
required this.hints,
required this.onGameComplete,
this.maxAttempts = 5,
});

@override
State<SafeCodeGame> createState() => _SafeCodeGameState();
}

class _SafeCodeGameState extends State<SafeCodeGame> {
List<String> _currentCode = ['', '', '', ''];
int _currentPosition = 0;
int _attempts = 0;
bool _gameCompleted = false;
bool _gameFailed = false;
List<String> _attemptHistory = [];
int _currentHintIndex = 0;

void _onNumberPressed(String number) {
if (_gameCompleted || _gameFailed || _currentPosition >= 4) return;

setState(() {
_currentCode[_currentPosition] = number;
_currentPosition++;

if (_currentPosition == 4) {
_checkCode();
}
});
}

void _onBackspace() {
if (_gameCompleted || _gameFailed || _currentPosition <= 0) return;

setState(() {
_currentPosition--;
_currentCode[_currentPosition] = '';
});
}

void _checkCode() {
String enteredCode = _currentCode.join();

setState(() {
_attempts++;
_attemptHistory.add(enteredCode);

if (enteredCode == widget.correctCode) {
_gameCompleted = true;
widget.onGameComplete(true);
} else if (_attempts >= widget.maxAttempts) {
_gameFailed = true;
widget.onGameComplete(false);
} else {
_currentCode = ['', '', '', ''];
_currentPosition = 0;
}
});
}

void _showHint() {
if (_currentHintIndex < widget.hints.length) {
showDialog(
context: context,
builder: (context) => AlertDialog(
backgroundColor: AppColors.darkGray,
title: Text(
'HINT',
style: TextStyle(color: AppColors.neonBlue),
),
content: Text(
widget.hints[_currentHintIndex],
style: TextStyle(color: AppColors.textPrimary),
),
actions: [
TextButton(
onPressed: () {
setState(() {
_currentHintIndex++;
});
Navigator.pop(context);
},
child: Text(
'OK',
style: TextStyle(color: AppColors.neonBlue),
),
),
],
),
);
}
}

void _resetGame() {
setState(() {
_currentCode = ['', '', '', ''];
_currentPosition = 0;
_attempts = 0;
_attemptHistory = [];
_gameCompleted = false;
_gameFailed = false;
_currentHintIndex = 0;
});
}

Widget _buildDigitBox(int index) {
bool isActive = index == _currentPosition;
bool isFilled = _currentCode[index].isNotEmpty;

return Container(
width: 60,
height: 80,
margin: const EdgeInsets.symmetric(horizontal: 8),
decoration: BoxDecoration(
color: Colors.black.withOpacity(0.8),
borderRadius: BorderRadius.circular(12),
border: Border.all(
color: isActive
? AppColors.neonRed
    : isFilled
? AppColors.neonRed.withOpacity(0.7)
    : AppColors.neonRed.withOpacity(0.3),
width: isActive ? 3 : 2,
),
boxShadow: isActive
? [
BoxShadow(
color: AppColors.neonRed.withOpacity(0.5),
blurRadius: 15,
spreadRadius: 3,
),
]
    : isFilled
? [
BoxShadow(
color: AppColors.neonRed.withOpacity(0.3),
blurRadius: 10,
),
]
    : [],
),
child: Center(
child: Text(
_currentCode[index].isNotEmpty ? _currentCode[index] : '?',
style: TextStyle(
fontSize: 32,
fontWeight: FontWeight.bold,
color: isFilled ? AppColors.neonRed : AppColors.textSecondary,
fontFamily: 'Courier New',
),
),
),
);
}

@override
Widget build(BuildContext context) {
final screenWidth = MediaQuery.of(context).size.width;

return Scaffold(
backgroundColor: Colors.black,
body: SafeArea(
child: Column(
children: [
// Header
Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: AppColors.darkGray,
border: Border(
bottom: BorderSide(
color: AppColors.neonRed.withOpacity(0.3),
),
),
),
child: Row(
children: [
IconButton(
onPressed: () => Navigator.pop(context),
icon: Icon(Icons.arrow_back, color: AppColors.neonRed),
),
const SizedBox(width: 10),
Expanded( // ADDED: Wrap text in Expanded to prevent overflow
child: Text(
'CRACK THE SAFE',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
color: AppColors.neonRed,
fontFamily: 'Courier New',
letterSpacing: 2,
),
),
),
],
),
),

// Game Area - FIXED: Added proper constraints
Expanded(
child: SingleChildScrollView(
child: Padding(
padding: const EdgeInsets.all(16),
child: Column(
children: [
// Instructions
Text(
'Enter the 4-digit combination',
style: TextStyle(
color: AppColors.textSecondary,
fontSize: 14,
),
),
const SizedBox(height: 20),

// Code Display - FIXED: Use constraints
Container(
constraints: BoxConstraints(maxWidth: screenWidth * 0.9),
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: Colors.black.withOpacity(0.7),
borderRadius: BorderRadius.circular(20),
border: Border.all(
color: AppColors.neonRed.withOpacity(0.5),
width: 2,
),
boxShadow: [
BoxShadow(
color: AppColors.neonRed.withOpacity(0.2),
blurRadius: 30,
spreadRadius: 5,
),
],
),
child: Row(
mainAxisAlignment: MainAxisAlignment.center,
children: List.generate(4, (index) => _buildDigitBox(index)),
),
),
const SizedBox(height: 30),

// Attempts Counter
Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.black.withOpacity(0.5),
borderRadius: BorderRadius.circular(12),
border: Border.all(
color: AppColors.neonRed.withOpacity(0.3),
),
),
child: Column(
children: [
Text(
'ATTEMPTS',
style: TextStyle(
color: AppColors.neonRed,
fontWeight: FontWeight.bold,
letterSpacing: 2,
),
),
Text(
'$_attempts/${widget.maxAttempts}',
style: TextStyle(
fontSize: 28,
fontWeight: FontWeight.bold,
color: AppColors.neonRed,
),
),
],
),
),
const SizedBox(height: 20),

// Hint Button
SizedBox(
width: double.infinity,
child: ElevatedButton.icon(
onPressed: _showHint,
style: ElevatedButton.styleFrom(
backgroundColor: AppColors.neonBlue,
padding: const EdgeInsets.symmetric(vertical: 16),
),
icon: const Icon(Icons.lightbulb),
label: const Text('GET HINT'),
),
),
const SizedBox(height: 20),

// Number Pad - FIXED: Adjust spacing and padding
Container(
padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
child: GridView.count(
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
crossAxisCount: 3,
childAspectRatio: 1.3,
mainAxisSpacing: 8, // REDUCED from 10
crossAxisSpacing: 8, // REDUCED from 10
children: [
// Numbers 1-9
for (int i = 1; i <= 9; i++)
Padding(
padding: const EdgeInsets.all(2.0),
child: NumberButton(
number: i.toString(),
onPressed: () => _onNumberPressed(i.toString()),
isActive: !_gameCompleted && !_gameFailed,
size: 45, // REDUCED from 50
),
),

// Backspace
Padding(
padding: const EdgeInsets.all(2.0),
child: GestureDetector(
onTap: _onBackspace,
child: Container(
decoration: BoxDecoration(
shape: BoxShape.circle,
color: Colors.black.withOpacity(0.7),
border: Border.all(
color: AppColors.neonOrange,
width: 2,
),
boxShadow: [
BoxShadow(
color: AppColors.neonOrange.withOpacity(0.3),
blurRadius: 10,
),
],
),
child: Center(
child: Icon(
Icons.backspace,
color: AppColors.neonOrange,
size: 28, // REDUCED from 30
),
),
),
),
),

// Number 0
Padding(
padding: const EdgeInsets.all(2.0),
child: NumberButton(
number: '0',
onPressed: () => _onNumberPressed('0'),
isActive: !_gameCompleted && !_gameFailed,
size: 45, // REDUCED from 50
),
),

// Submit/Enter
Padding(
padding: const EdgeInsets.all(2.0),
child: GestureDetector(
onTap: (_currentPosition == 4 &&
!_gameCompleted &&
!_gameFailed)
? _checkCode
    : null,
child: Container(
decoration: BoxDecoration(
shape: BoxShape.circle,
color: Colors.black.withOpacity(0.7),
border: Border.all(
color: (_currentPosition == 4 &&
!_gameCompleted &&
!_gameFailed)
? AppColors.neonGreen
    : AppColors.neonGreen.withOpacity(0.3),
width: 2,
),
boxShadow: [
BoxShadow(
color: AppColors.neonGreen.withOpacity(0.3),
blurRadius: 10,
),
],
),
child: Center(
child: Icon(
Icons.keyboard_return,
color: (_currentPosition == 4 &&
!_gameCompleted &&
!_gameFailed)
? AppColors.neonGreen
    : AppColors.neonGreen.withOpacity(0.3),
size: 28, // REDUCED from 30
),
),
),
),
),
],
),
),
const SizedBox(height: 20),

// Game State Messages
if (_gameCompleted)
Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: AppColors.neonGreen.withOpacity(0.2),
borderRadius: BorderRadius.circular(12),
border: Border.all(color: AppColors.neonGreen, width: 2),
),
child: Column(
children: [
Icon(
Icons.lock_open,
color: AppColors.neonGreen,
size: 40,
),
const SizedBox(height: 10),
Text(
'SAFE UNLOCKED!',
style: TextStyle(
color: AppColors.neonGreen,
fontWeight: FontWeight.bold,
),
),
],
),
),

if (_gameFailed)
Container(
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: AppColors.neonRed.withOpacity(0.2),
borderRadius: BorderRadius.circular(12),
border: Border.all(color: AppColors.neonRed, width: 2),
),
child: Column(
children: [
Icon(
Icons.lock,
color: AppColors.neonRed,
size: 40,
),
const SizedBox(height: 10),
Text(
'SAFE LOCKED!',
style: TextStyle(
color: AppColors.neonRed,
fontWeight: FontWeight.bold,
),
),
],
),
),

if (_gameCompleted || _gameFailed) const SizedBox(height: 20),

if (_gameCompleted || _gameFailed)
SizedBox(
width: double.infinity,
child: ElevatedButton(
onPressed: _resetGame,
style: ElevatedButton.styleFrom(
backgroundColor: AppColors.neonRed,
padding: const EdgeInsets.symmetric(vertical: 16),
),
child: const Text('PLAY AGAIN'),
),
),
],
),
),
),
),
],
),
),
);
}
}
