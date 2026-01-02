import 'package:flutter/material.dart';
import '../../../core/models/story_model.dart';

class HiddenObjectGame extends StatefulWidget {
  final MiniGame game;
  final Function(bool) onGameComplete;

  const HiddenObjectGame({super.key, required this.game, required this.onGameComplete});

  @override
  State<HiddenObjectGame> createState() => _HiddenObjectGameState();
}

class _HiddenObjectGameState extends State<HiddenObjectGame> {
  bool _found = false;

  @override
  Widget build(BuildContext context) {
    final String backgroundImage = widget.game.config['backgroundImage'];
    final List<dynamic> objects = widget.game.config['objects']; // List of maps

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            backgroundImage,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // Objects to find
          ..._buildObjects(objects),

          // Instructions
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              color: Colors.black.withOpacity(0.7),
              child: Column(
                children: [
                  Text(
                    'FIND THE HIDDEN PHONE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap on the victim\'s pocket to find the phone',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Found overlay
          if (_found)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 80),
                      SizedBox(height: 20),
                      Text(
                        'PHONE FOUND!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'You found the victim\'s phone',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () => widget.onGameComplete(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        ),
                        child: Text(
                          'CONTINUE INVESTIGATION',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildObjects(List<dynamic> objects) {
    List<Widget> widgets = [];

    for (var obj in objects) {
      final Map<String, dynamic> object = obj;
      final Map<String, dynamic> position = object['position'];

      // Get position values with defaults
      double left = (position['left'] ?? 0).toDouble();
      double top = (position['top'] ?? 0).toDouble();
      double width = (position['width'] ?? 100).toDouble();
      double height = (position['height'] ?? 100).toDouble();

      widgets.add(
        Positioned(
          left: left,
          top: top,
          width: width,
          height: height,
          child: GestureDetector(
            onTap: () {
              if (!_found) {
                setState(() {
                  _found = true;
                });
              }
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red.withOpacity(0.5), width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  Icons.phone_android,
                  color: Colors.red.withOpacity(0.7),
                  size: 30,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }
}