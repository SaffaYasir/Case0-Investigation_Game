import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/providers/progress_provider.dart';

class AchivementsScreen extends ConsumerWidget {
  const AchivementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressProvider);

    return progressAsync.when(
      loading: () => _buildLoadingScreen(context),
      error: (error, stack) => _buildErrorScreen(context, error),
      data: (progressList) => _buildAchievementsScreen(context, progressList),
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkestGray,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.neonRed),
            const SizedBox(height: 20),
            Text(
              'LOADING ACHIEVEMENTS...',
              style: TextStyle(
                color: AppColors.neonRed,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, Object error) {
    return Scaffold(
      backgroundColor: AppColors.darkestGray,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: AppColors.neonRed, size: 64),
              const SizedBox(height: 20),
              Text(
                'ERROR LOADING ACHIEVEMENTS',
                style: TextStyle(
                  color: AppColors.neonRed,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                error.toString(),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonRed,
                ),
                child: const Text('GO BACK'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsScreen(BuildContext context, List<CaseProgress> progressList) {
    final completedCases = progressList.where((p) => p.isCompleted).length;
    final totalClues = progressList.fold(0, (total, p) => total + p.cluesFound);
    final totalScore = progressList.fold(0, (total, p) => total + p.score);

    final achievements = [
      _buildAchievement(
        title: 'FIRST CASE SOLVED',
        description: 'Successfully solve your first investigation',
        isUnlocked: completedCases >= 1,
        icon: Icons.emoji_events,
        iconColor: AppColors.neonGreen,
      ),
      _buildAchievement(
        title: 'CLUE COLLECTOR',
        description: 'Collect 10 clues across all cases',
        isUnlocked: totalClues >= 10,
        icon: Icons.search,
        iconColor: AppColors.neonBlue,
      ),
      _buildAchievement(
        title: 'CASE MASTER',
        description: 'Complete 2 cases',
        isUnlocked: completedCases >= 2,
        icon: Icons.folder_copy,
        iconColor: AppColors.neonOrange,
      ),
      _buildAchievement(
        title: 'SCORE CHAMPION',
        description: 'Reach 1000 total score',
        isUnlocked: totalScore >= 1000,
        icon: Icons.star,
        iconColor: AppColors.neonPurple,
      ),
      _buildAchievement(
        title: 'PERFECT INVESTIGATOR',
        description: 'Solve a case without any mistakes',
        isUnlocked: false,
        icon: Icons.thumb_up,
        iconColor: AppColors.textDisabled,
      ),
      _buildAchievement(
        title: 'SPEED DETECTIVE',
        description: 'Solve a case in under 5 minutes',
        isUnlocked: false,
        icon: Icons.timer,
        iconColor: AppColors.textDisabled,
      ),
    ];

    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    final progressPercentage = (unlockedCount / achievements.length * 100).toInt();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.dashboardBg),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.neonRed.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(
                          Icons.arrow_back,
                          color: AppColors.neonRed,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'ACHIEVEMENTS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neonRed,
                          fontFamily: 'Courier New',
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.neonRed.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'ACHIEVEMENT PROGRESS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildAchievementStat('$unlockedCount', 'Unlocked', AppColors.neonGreen),
                                  _buildAchievementStat('${achievements.length}', 'Total', AppColors.neonBlue),
                                  _buildAchievementStat('$progressPercentage%', 'Progress', AppColors.neonOrange),
                                ],
                              ),
                              const SizedBox(height: 16),
                              LinearProgressIndicator(
                                value: unlockedCount / achievements.length,
                                backgroundColor: AppColors.darkGray,
                                color: AppColors.neonRed,
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          'YOUR ACHIEVEMENTS',
                          style: TextStyle(
                            color: AppColors.neonRed,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),

                        ...achievements.map((achievement) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildAchievementCard(
                            title: achievement.title,
                            description: achievement.description,
                            isUnlocked: achievement.isUnlocked,
                            icon: achievement.icon,
                            iconColor: achievement.iconColor,
                          ),
                        )),

                        const SizedBox(height: 30),

                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.neonBlue.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.lock,
                                color: AppColors.neonBlue,
                                size: 40,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'MORE ACHIEVEMENTS COMING SOON',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Complete more cases to unlock additional achievements',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildAchievementStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard({
    required String title,
    required String description,
    required bool isUnlocked,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked ? iconColor : AppColors.textDisabled,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked ? iconColor.withOpacity(0.2) : AppColors.darkGray,
              border: Border.all(
                color: isUnlocked ? iconColor : AppColors.textDisabled,
              ),
            ),
            child: Icon(
              icon,
              color: isUnlocked ? iconColor : AppColors.textDisabled,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isUnlocked ? Colors.white : AppColors.textDisabled,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: isUnlocked ? AppColors.textSecondary : AppColors.textDisabled,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isUnlocked ? Icons.check_circle : Icons.lock,
            color: isUnlocked ? AppColors.neonGreen : AppColors.textDisabled,
            size: 24,
          ),
        ],
      ),
    );
  }
}

class _Achievement {
  final String title;
  final String description;
  final bool isUnlocked;
  final IconData icon;
  final Color iconColor;

  _Achievement({
    required this.title,
    required this.description,
    required this.isUnlocked,
    required this.icon,
    required this.iconColor,
  });
}

_Achievement _buildAchievement({
  required String title,
  required String description,
  required bool isUnlocked,
  required IconData icon,
  required Color iconColor,
}) {
  return _Achievement(
    title: title,
    description: description,
    isUnlocked: isUnlocked,
    icon: icon,
    iconColor: iconColor,
  );
}