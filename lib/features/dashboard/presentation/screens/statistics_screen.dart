import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:case_zero_detective/core/constants/app_colors.dart';
import 'package:case_zero_detective/core/providers/progress_provider.dart';
import 'package:case_zero_detective/core/providers/settings_provider.dart';
import 'package:case_zero_detective/core/services/sound_service.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressProvider);
    final settings = ref.watch(settingsProvider);
    final fontSize = settings.fontSize;

    return Scaffold(
      backgroundColor: AppColors.darkestGray,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.neonRed.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      SoundService().playClick();
                      context.pop();
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.neonRed,
                      size: 28.0 * fontSize,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'STATISTICS',
                    style: TextStyle(
                      fontSize: 20.0 * fontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neonRed,
                      fontFamily: 'Courier New',
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      SoundService().playClick();
                      ref.invalidate(progressProvider);
                    },
                    icon: Icon(
                      Icons.refresh,
                      color: AppColors.neonBlue,
                      size: 24.0 * fontSize,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: progressAsync.when(
                  loading: () => _buildLoadingState(fontSize),
                  error: (error, stack) => _buildErrorState(ref, fontSize),
                  data: (progressList) {
                    final completedCases = progressList.where((p) => p.isCompleted).length;
                    final totalClues = progressList.fold(0, (sum, p) => sum + p.cluesFound);
                    final totalScore = progressList.fold(0, (sum, p) => sum + p.score);

                    // Get rank
                    String getRank() {
                      if (completedCases >= 10) return 'MASTER DETECTIVE';
                      if (completedCases >= 5) return 'CHIEF INSPECTOR';
                      if (completedCases >= 3) return 'DETECTIVE';
                      if (completedCases >= 1) return 'ROOKIE DETECTIVE';
                      return 'NOVICE';
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Card
                        _buildSummaryCard(getRank(), completedCases, totalClues, totalScore, fontSize),
                        const SizedBox(height: 24),

                        // Progress Chart
                        _buildSectionTitle('CASE PROGRESS', fontSize),
                        const SizedBox(height: 16),
                        _buildProgressChart(progressList, fontSize),
                        const SizedBox(height: 24),

                        // Performance Metrics
                        _buildSectionTitle('PERFORMANCE METRICS', fontSize),
                        const SizedBox(height: 16),
                        _buildPerformanceMetrics(progressList, fontSize),
                        const SizedBox(height: 24),

                        // Case Breakdown
                        _buildSectionTitle('CASE BREAKDOWN', fontSize),
                        const SizedBox(height: 16),
                        _buildCaseBreakdown(progressList, fontSize),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, double fontSize) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.neonRed,
        fontSize: 16 * fontSize,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildSummaryCard(String rank, int cases, int clues, int score, double fontSize) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
            colors: [
              AppColors.darkGray.withOpacity(0.8),
              Colors.black.withOpacity(0.9),
            ]),
        border: Border.all(color: AppColors.neonBlue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DETECTIVE PROFILE',
                    style: TextStyle(
                      color: AppColors.neonRed,
                      fontSize: 12 * fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'INVESTIGATOR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24 * fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Rank: $rank',
                    style: TextStyle(
                      color: AppColors.neonBlue,
                      fontSize: 14 * fontSize,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.darkGray,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: AppColors.neonBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('CASES', cases.toString(), AppColors.neonRed, fontSize),
              _buildStatCard('CLUES', clues.toString(), AppColors.neonBlue, fontSize),
              _buildStatCard('SCORE', score.toString(), AppColors.neonGreen, fontSize),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, double fontSize) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 28 * fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12 * fontSize,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressChart(List<CaseProgress> progressList, double fontSize) {
    final completed = progressList.where((p) => p.isCompleted).length.toDouble();
    final inProgress = progressList.where((p) => !p.isCompleted && p.cluesFound > 0).length.toDouble();
    final notStarted = progressList.where((p) => !p.isCompleted && p.cluesFound == 0).length.toDouble();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black.withOpacity(0.3),
        border: Border.all(color: AppColors.neonRed.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  if (completed > 0)
                    PieChartSectionData(
                      value: completed,
                      color: AppColors.neonGreen,
                      radius: 40,
                      title: '${((completed / progressList.length) * 100).toInt()}%',
                      titleStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 14 * fontSize,
                      ),
                    ),
                  if (inProgress > 0)
                    PieChartSectionData(
                      value: inProgress,
                      color: AppColors.neonOrange,
                      radius: 40,
                      title: '${((inProgress / progressList.length) * 100).toInt()}%',
                      titleStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 14 * fontSize,
                      ),
                    ),
                  if (notStarted > 0)
                    PieChartSectionData(
                      value: notStarted,
                      color: AppColors.neonRed,
                      radius: 40,
                      title: '${((notStarted / progressList.length) * 100).toInt()}%',
                      titleStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 14 * fontSize,
                      ),
                    ),
                ],
                centerSpaceRadius: 30,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegend('Completed', AppColors.neonGreen, fontSize),
              const SizedBox(height: 12),
              _buildLegend('In Progress', AppColors.neonOrange, fontSize),
              const SizedBox(height: 12),
              _buildLegend('Not Started', AppColors.neonRed, fontSize),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String text, Color color, double fontSize) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14 * fontSize,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceMetrics(List<CaseProgress> progressList, double fontSize) {
    final completedCases = progressList.where((p) => p.isCompleted);

    if (completedCases.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.black.withOpacity(0.3),
          border: Border.all(color: AppColors.neonRed.withOpacity(0.2)),
        ),
        child: Center(
          child: Text(
            'Complete your first case to see performance metrics',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14 * fontSize,
            ),
          ),
        ),
      );
    }

    final avgTime = completedCases.fold(0.0, (sum, p) => sum + p.timeSpent) / completedCases.length;
    final avgAccuracy = completedCases.fold(0.0, (sum, p) => sum + p.accuracy) / completedCases.length;
    final fastest = completedCases.reduce((a, b) => a.timeSpent < b.timeSpent ? a : b);
    final slowest = completedCases.reduce((a, b) => a.timeSpent > b.timeSpent ? a : b);

    return SizedBox(
      height: 160,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          _buildMetricCard(
            'Avg Time',
            '${avgTime.toStringAsFixed(1)}m',
            Icons.timer,
            AppColors.neonBlue,
            fontSize,
          ),
          _buildMetricCard(
            'Fastest Case',
            '${fastest.timeSpent.toInt()}m',
            Icons.flash_on,
            AppColors.neonGreen,
            fontSize,
          ),
          _buildMetricCard(
            'Slowest Case',
            '${slowest.timeSpent.toInt()}m',
            Icons.hourglass_bottom,
            AppColors.neonRed,
            fontSize,
          ),
          _buildMetricCard(
            'Avg Accuracy',
            '${avgAccuracy.toStringAsFixed(0)}%',
            Icons.track_changes,
            AppColors.neonOrange,
            fontSize,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, double fontSize) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withOpacity(0.3),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20 * fontSize),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16 * fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12 * fontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseBreakdown(List<CaseProgress> progressList, double fontSize) {
    return Column(
      children: progressList.map((progress) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.black.withOpacity(0.3),
            border: Border.all(color: AppColors.neonBlue.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.darkGray,
                ),
                child: Center(
                  child: Text(
                    'C${progress.caseNumber}',
                    style: TextStyle(
                      color: AppColors.neonRed,
                      fontSize: 20 * fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Case #${progress.caseNumber}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16 * fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildCaseStat('Clues', '${progress.cluesFound}', fontSize),
                        const SizedBox(width: 16),
                        _buildCaseStat('Score', '${progress.score}', fontSize),
                        const SizedBox(width: 16),
                        _buildCaseStat('Time', '${progress.timeSpent.toInt()}m', fontSize),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress.isCompleted ? 1.0 : progress.cluesFound / 5.0,
                      backgroundColor: Colors.white10,
                      color: progress.isCompleted ? AppColors.neonGreen : AppColors.neonRed,
                    ),
                  ],
                ),
              ),
              Icon(
                progress.isCompleted ? Icons.check_circle :
                progress.cluesFound > 0 ? Icons.hourglass_top : Icons.lock,
                color: progress.isCompleted ? AppColors.neonGreen :
                progress.cluesFound > 0 ? AppColors.neonOrange : Colors.grey,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCaseStat(String label, String value, double fontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 10 * fontSize,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14 * fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(double fontSize) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.neonRed),
          const SizedBox(height: 20),
          Text(
            'Loading statistics...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16 * fontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, double fontSize) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: AppColors.neonRed, size: 48),
          const SizedBox(height: 20),
          Text(
            'Failed to load statistics',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16 * fontSize,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => ref.invalidate(progressProvider),
            child: Text('Retry', style: TextStyle(fontSize: 14 * fontSize)),
          ),
        ],
      ),
    );
  }
}