import 'package:flutter/material.dart';
import '../../../core/models/story_model.dart';
import '../../../core/constants/app_colors.dart';

class PasswordGame extends StatefulWidget {
  final MiniGame game;
  final Function(bool) onGameComplete;

  const PasswordGame({super.key, required this.game, required this.onGameComplete});

  @override
  State<PasswordGame> createState() => _PasswordGameState();
}

class _PasswordGameState extends State<PasswordGame> {
  final TextEditingController _controller = TextEditingController();
  String _message = '';
  bool _success = false;

  void _checkPassword() {
    final correctPassword = widget.game.config['correctPassword'] ?? '1024';
    final hint = widget.game.config['hint'] ?? 'The journalist\'s birthday';

    if (_controller.text == correctPassword) {
      setState(() {
        _success = true;
        _message = 'Phone unlocked!';
      });
      Future.delayed(Duration(seconds: 1), () {
        widget.onGameComplete(true);
      });
    } else {
      setState(() {
        _message = 'Wrong passcode! Try again.';
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hint = widget.game.config['hint'] ?? 'The journalist\'s birthday';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/cases/case2/crime_scene.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.darken),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.darkGray.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.neonRed, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: AppColors.neonRed.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Phone Image
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.neonRed, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonRed.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.phone_android,
                      color: AppColors.neonRed,
                      size: 60,
                    ),
                  ),

                  SizedBox(height: 20),

                  // Title
                  Text(
                    'LOCKED PHONE',
                    style: TextStyle(
                      color: AppColors.neonRed,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: AppColors.neonRed.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10),

                  // Hint
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.neonRed),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'HINT:',
                          style: TextStyle(
                            color: AppColors.neonRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          hint,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Message
                  if (_message.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _success
                            ? AppColors.neonGreen.withOpacity(0.2)
                            : AppColors.neonRed.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: _success
                                ? AppColors.neonGreen
                                : AppColors.neonRed
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _success ? Icons.check : Icons.error,
                            color: _success
                                ? AppColors.neonGreen
                                : AppColors.neonRed,
                          ),
                          SizedBox(width: 10),
                          Text(
                            _message,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 20),

                  // Password Input
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.neonRed,
                        fontSize: 32,
                        letterSpacing: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black,
                        hintText: "____",
                        hintStyle: TextStyle(
                          color: AppColors.darkGray,
                          fontSize: 32,
                          letterSpacing: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: AppColors.neonRed),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: AppColors.neonRed),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: AppColors.neonRed, width: 2),
                        ),
                        counterText: '',
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Unlock Button
                  ElevatedButton(
                    onPressed: _checkPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonRed,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: AppColors.neonRed.withOpacity(0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_open, color: Colors.black),
                        SizedBox(width: 10),
                        Text(
                          'UNLOCK PHONE',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10),

                  // Hint Button
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: AppColors.neonRed),
                          ),
                          title: Text(
                            'NEED HELP?',
                            style: TextStyle(
                              color: AppColors.neonRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            'Try these common date formats:\n'
                                '• DDMM (like 1506 for June 15)\n'
                                '• MMDD (like 0615 for June 15)\n'
                                '• YYYY (year of birth)\n'
                                'The hint says: $hint',
                            style: TextStyle(color: Colors.white),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'OK',
                                style: TextStyle(color: AppColors.neonRed),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(
                      'Need help?',
                      style: TextStyle(
                        color: AppColors.neonRed,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}