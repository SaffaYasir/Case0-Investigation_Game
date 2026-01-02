import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/providers/progress_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressProvider);

    return progressAsync.when(
      loading: () => _buildLoadingScreen(context),
      error: (error, stack) => _buildErrorScreen(context, error),
      data: (progressList) => _buildProfileScreen(context, ref, progressList),
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
              'LOADING PROFILE...',
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
                'ERROR LOADING PROGRESS',
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

  Widget _buildProfileScreen(BuildContext context, WidgetRef ref, List<CaseProgress> progressList) {
    final completedCases = progressList.where((p) => p.isCompleted).length;
    final rank = _getRank(completedCases);
    final totalScore = progressList.fold(0, (total, p) => total + p.score);
    final totalClues = progressList.fold(0, (total, p) => total + p.cluesFound);

    final case1Completed = progressList.any((p) => p.caseNumber == 1 && p.isCompleted);
    final case2Completed = progressList.any((p) => p.caseNumber == 2 && p.isCompleted);

    return Scaffold(
      body: SafeArea(
        child: Stack(
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
            Column(
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
                        'DETECTIVE PROFILE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neonRed,
                          fontFamily: 'Courier New',
                          letterSpacing: 1,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => context.push('/edit-profile'),
                        icon: Icon(
                          Icons.edit,
                          color: AppColors.neonRed,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height - 100,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withOpacity(0.5),
                                    border: Border.all(
                                      color: AppColors.neonRed,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.neonRed.withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: Image.asset(
                                      AppImages.appLogo,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.neonRed.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    rank,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'DETECTIVE AGENT',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.neonRed,
                                letterSpacing: 2,
                                fontFamily: 'Courier New',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'detective@case0.gov',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 24),

                            LayoutBuilder(
                              builder: (context, constraints) {
                                final availableWidth = constraints.maxWidth;
                                final itemWidth = (availableWidth - 12) / 2;

                                return Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    SizedBox(
                                      width: itemWidth,
                                      child: _buildStatCard('Rank', rank, Icons.star, AppColors.neonRed),
                                    ),
                                    SizedBox(
                                      width: itemWidth,
                                      child: _buildStatCard('Score', '$totalScore', Icons.bolt, AppColors.neonOrange),
                                    ),
                                    SizedBox(
                                      width: itemWidth,
                                      child: _buildStatCard('Cases', '$completedCases', Icons.cases, AppColors.neonGreen),
                                    ),
                                    SizedBox(
                                      width: itemWidth,
                                      child: _buildStatCard('Clues', '$totalClues', Icons.search, AppColors.neonBlue),
                                    ),
                                  ],
                                );
                              },
                            ),

                            const SizedBox(height: 30),

                            Column(
                              children: [
                                _buildActionButton(
                                  'Edit Profile',
                                  Icons.edit,
                                      () => context.push('/edit-profile'),
                                ),
                                _buildActionButton(
                                  'Achievements',
                                  Icons.emoji_events,
                                      () => context.push('/achievements'),
                                ),
                                _buildActionButton(
                                  'Settings',
                                  Icons.settings,
                                      () => context.push('/settings'),
                                ),
                              ],
                            ),

                            const SizedBox(height: 30),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.neonRed.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CASE HISTORY',
                                    style: TextStyle(
                                      color: AppColors.neonRed,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildCaseItem(
                                    'Case 1: Vanished Necklace',
                                    case1Completed ? 'Completed' : 'Available',
                                    case1Completed ? AppColors.neonGreen : AppColors.neonOrange,
                                  ),
                                  _buildCaseItem(
                                    'Case 2: Murder Alley',
                                    case2Completed ? 'Completed' : 'Available',
                                    case2Completed ? AppColors.neonGreen : AppColors.neonOrange,
                                  ),
                                  _buildCaseItem(
                                    'Case 3: Digital Shadows',
                                    'Locked',
                                    AppColors.textDisabled,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getRank(int completedCases) {
    if (completedCases >= 10) return 'MASTER DETECTIVE';
    if (completedCases >= 5) return 'CHIEF INSPECTOR';
    if (completedCases >= 3) return 'DETECTIVE';
    if (completedCases >= 1) return 'ROOKIE DETECTIVE';
    return 'NOVICE';
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.neonRed.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.neonRed, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseItem(String title, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.darkGray,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: statusColor),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}