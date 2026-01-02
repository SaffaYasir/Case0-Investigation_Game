import 'package:case_zero_detective/core/providers/progress_provider.dart';

class ProgressHelper {
  static Future<void> saveCaseProgress({
    required int caseNumber,
    required bool isCompleted,
    required int score,
    required int cluesFound,
    required double timeSpent,
    required double accuracy,
  }) async {
    try {
      final progress = CaseProgress(
        caseNumber: caseNumber,
        isCompleted: isCompleted,
        score: score,
        cluesFound: cluesFound,
        timeSpent: timeSpent,
        accuracy: accuracy,
      );

      // Load existing progress
      final progressList = await ProgressService.loadProgress();
      final index = progressList.indexWhere((p) => p.caseNumber == caseNumber);

      if (index >= 0) {
        progressList[index] = progress;
      } else {
        progressList.add(progress);
      }

      await ProgressService.saveProgress(progressList);
    } catch (e) {
      print('Error saving progress: $e');
    }
  }
}