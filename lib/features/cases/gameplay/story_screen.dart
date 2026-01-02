import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/models/story_model.dart';

class StorySceneWidget extends StatelessWidget {
  final StoryScene scene;
  final Function(String) onChoiceSelected;
  final Function(String) onGameTriggered;
  final List<Clue> collectedClues;
  final int caseNumber;

  const StorySceneWidget({
    super.key,
    required this.scene,
    required this.onChoiceSelected,
    required this.onGameTriggered,
    required this.collectedClues,
    this.caseNumber = 1,
  });

  @override
  Widget build(BuildContext context) {
    final String bgPath = AppImages.getCaseBackground(caseNumber, scene.id);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // 1. BACKGROUND LAYER
            Positioned.fill(
              child: AppImages.image(
                bgPath,
                fit: BoxFit.cover,
              ),
            ),

            // 2. ATMOSPHERIC OVERLAY
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                      Colors.black,
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                ),
              ),
            ),

            // 3. UI OVERLAY (Using a Column to prevent pixel overflow)
            SafeArea(
              child: Column(
                children: [
                  _buildNeonHeader(),
                  const Spacer(), // Pushes the content to the bottom
                  _buildDialogueSection(context),
                  _buildChoicesSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeonHeader() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neonRed, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "CASE #$caseNumber",
            style: TextStyle(
              color: AppColors.neonRed,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.5,
            ),
          ),
          Text(
            "CLUES: ${collectedClues.length}",
            style: TextStyle(
              color: AppColors.neonBlue,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogueSection(BuildContext context) {
    final hasCharacter = scene.characters.isNotEmpty;
    final activeChar = scene.characters.firstWhere(
          (c) => c.isHighlighted,
      orElse: () => hasCharacter ? scene.characters.first : StoryCharacter(id: 'none', name: 'NARRATOR', imagePath: ''),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      // Constraints ensure the card doesn't grow infinitely and cause overflow
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.35,
      ),
      child: Card(
        color: Colors.black, // Solid black to hide white PNG backgrounds
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.neonRed.withOpacity(0.7), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wraps content tightly
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // FIXED: SOLID BLACK CIRCLE FOR IMAGES
                  Container(
                    width: 75, // Slightly smaller to prevent pushing text out
                    height: 75,
                    decoration: BoxDecoration(
                      color: Colors.black, // FORCES black background behind PNG
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.neonRed, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        activeChar.imagePath.isEmpty
                            ? AppImages.detectiveSilhouette
                            : activeChar.imagePath,
                        fit: BoxFit.cover,
                        // Blends the image with black if there is transparency/white edges
                        color: Colors.black.withOpacity(0.05),
                        colorBlendMode: BlendMode.darken,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeChar.name.toUpperCase(),
                          style: TextStyle(
                            color: AppColors.neonRed,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        if (activeChar.emotion != null)
                          Text(
                            activeChar.emotion!.toUpperCase(),
                            style: TextStyle(
                                color: AppColors.neonOrange,
                                fontSize: 11,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Flexible allows text to scroll if it is too long (prevents Henry's alibi overflow)
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    scene.dialogue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.4,
                      fontFamily: 'Courier New',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoicesSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: scene.choices.map((choice) {
          final isGame = choice.triggersGame;
          final color = isGame ? AppColors.neonOrange : AppColors.neonGreen;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: double.infinity,
              height: 50, // Fixed height for consistent flow
              child: ElevatedButton(
                onPressed: () => isGame ? onGameTriggered(choice.gameId!) : onChoiceSelected(choice.nextSceneId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: color,
                  side: BorderSide(color: color, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 4,
                ),
                child: Text(
                    choice.text.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}