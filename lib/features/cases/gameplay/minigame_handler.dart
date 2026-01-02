import 'package:flutter/material.dart';
import '../../../core/models/story_model.dart';
import '../../puzzles/screens/safe_code_game.dart';
import '../../puzzles/screens/memory_match_game.dart';
import '../../puzzles/screens/suspect_selection_screen.dart';
import '../../puzzles/screens/password_game.dart';

class MiniGameHandler {
  static Widget getGameWidget({
    required MiniGame game,
    required Function(bool) onGameComplete,
    required BuildContext context,
  }) {
    switch (game.type) {
      case GameType.CRACK_CODE:
        return SafeCodeGame(
          correctCode: game.config['correctCode'] ?? '0000',
          hints: List<String>.from(game.config['hints'] ?? []),
          onGameComplete: onGameComplete,
        );

      case GameType.EVIDENCE_MATCH:
        return MemoryMatchGame(
          config: game.config,
          onGameComplete: onGameComplete,
          nextGameId: 'safe_game', // For Case 1, next game is safe code
        );

      case GameType.SUSPECT_SELECTION:
        return SuspectSelectionScreen(
          suspects: List<String>.from(game.config['suspects'] ?? []),
          correctSuspect: game.config['correctSuspect'] ?? '',
          onSuspectSelected: (suspect) {
            onGameComplete(suspect == game.config['correctSuspect']);
          },
        );

      case GameType.PASSWORD:
        return PasswordGame(
          game: game,
          onGameComplete: onGameComplete,
        );

      default:
        return const Center(child: Text("Game type not found"));
    }
  }
}