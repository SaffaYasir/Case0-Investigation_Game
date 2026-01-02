import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:case_zero_detective/features/auth/terms_acceptance_dialog.dart';
import 'package:case_zero_detective/core/theme/app_theme.dart';
import 'package:case_zero_detective/features/splash/splash_screen.dart';
import 'package:case_zero_detective/features/auth/login_screen.dart';
import 'package:case_zero_detective/features/auth/signup_screen.dart';
import 'package:case_zero_detective/features/auth/forgot_password.dart';
import 'package:case_zero_detective/features/dashboard/dashboard_screen.dart';
import 'package:case_zero_detective/features/cases/case_list_screen.dart';
import 'package:case_zero_detective/features/cases/case_play_screen.dart';
import 'package:case_zero_detective/features/profile/profile_screen.dart';
import 'package:case_zero_detective/features/profile/edit_profile.dart';
import 'package:case_zero_detective/features/profile/achivements_screen.dart';
import 'package:case_zero_detective/features/settings/settings_screen.dart';
import 'package:case_zero_detective/features/legal/legal_screen.dart';
import 'package:case_zero_detective/core/constants/app_colors.dart';
import 'package:case_zero_detective/core/providers/auth_provider.dart';
import 'package:case_zero_detective/features/dashboard/presentation/screens/statistics_screen.dart';
import 'package:case_zero_detective/core/widgets/game_initializer.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'CASE 0 - Crime Investigation',
      theme: AppTheme.darkDetectiveTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => GameInitializer(
        child: TermsGuard(child: child!),
      ),
    );
  }
}

// Terms Guard Widget
class TermsGuard extends ConsumerStatefulWidget {
  final Widget child;

  const TermsGuard({super.key, required this.child});

  @override
  ConsumerState<TermsGuard> createState() => _TermsGuardState();
}

class _TermsGuardState extends ConsumerState<TermsGuard> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTerms();
    });
  }

  void _checkTerms() {
    final authState = ref.read(authStateProvider);
    final user = authState.value;

    if (user != null && !_dialogShown) {
      final profileAsync = ref.read(userProfileProvider);

      profileAsync.when(
        data: (doc) {
          if (doc.exists && mounted) {
            final acceptedTerms = doc.data()?['acceptedTerms'] as bool? ?? false;
            if (!acceptedTerms) {
              _showTermsDialog(user.uid);
              setState(() {
                _dialogShown = true;
              });
            }
          }
        },
        loading: () {},
        error: (_, __) {},
      );
    }
  }

  void _showTermsDialog(String userId) {
    if (_dialogShown) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TermsAcceptanceDialog(
        onAccept: () async {
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .update({
              'acceptedTerms': true,
              'termsAcceptedAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });

            if (mounted) {
              Navigator.pop(context);
              ref.invalidate(userProfileProvider);
            }
          } catch (e) {
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: AppColors.neonRed,
                ),
              );
            }
          }
        },
        onDecline: () {
          Navigator.pop(context);
          FirebaseAuth.instance.signOut();
          if (mounted) {
            context.go('/login');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('You must accept terms to use the app.'),
                backgroundColor: AppColors.neonRed,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) async {
      final authValue = authState.value;
      final isLoggedIn = authValue != null;
      final path = state.matchedLocation;

      // Allow splash screen to handle its own navigation
      if (path == '/splash') {
        return null; // Let splash screen show for its full duration
      }

      // If user is logged in and trying to access auth routes
      final authRoutes = ['/login', '/signup', '/forgot-password'];
      if (isLoggedIn && authRoutes.contains(path)) {
        return '/dashboard';
      }

      // If user is NOT logged in and trying to access protected routes
      final protectedRoutes = [
        '/dashboard', '/cases', '/profile', '/edit-profile',
        '/achievements', '/settings', '/statistics'
      ];

      if (!isLoggedIn &&
          (protectedRoutes.any((route) => path.startsWith(route)) ||
              path.contains('/case/'))) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        pageBuilder: (context, state) => const MaterialPage(
          child: SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => const MaterialPage(
          child: LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        pageBuilder: (context, state) => const MaterialPage(
          child: SignupScreen(),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        pageBuilder: (context, state) => const MaterialPage(
          child: ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        pageBuilder: (context, state) => const MaterialPage(
          child: DashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/cases',
        name: 'cases',
        pageBuilder: (context, state) => const MaterialPage(
          child: CaseListScreen(),
        ),
      ),
      GoRoute(
        path: '/case/:caseNumber',
        name: 'casePlay',
        pageBuilder: (context, state) {
          final caseNumber = int.tryParse(state.pathParameters['caseNumber'] ?? '1') ?? 1;
          return MaterialPage(
            child: CasePlayScreen(caseNumber: caseNumber),
          );
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        pageBuilder: (context, state) => const MaterialPage(
          child: ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'editProfile',
        pageBuilder: (context, state) => const MaterialPage(
          child: EditProfile(),
        ),
      ),
      GoRoute(
        path: '/achievements',
        name: 'achievements',
        pageBuilder: (context, state) => const MaterialPage(
          child: AchivementsScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => const MaterialPage(
          child: SettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/statistics',
        name: 'statistics',
        pageBuilder: (context, state) => const MaterialPage(
          child: StatisticsScreen(),
        ),
      ),
      // Legal Routes
      GoRoute(
        path: '/legal/:type',
        name: 'legal',
        pageBuilder: (context, state) {
          final type = state.pathParameters['type'] ?? 'privacy';
          return MaterialPage(
            child: LegalScreen(type: type),
          );
        },
      ),
      // Error routes kept for compatibility
      GoRoute(
        path: '/stats',
        redirect: (context, state) => '/statistics',
      ),
      GoRoute(
        path: '/leaderboard',
        name: 'leaderboard',
        pageBuilder: (context, state) => MaterialPage(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Leaderboard'),
              backgroundColor: AppColors.darkGray,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.neonRed),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(
              child: Text(
                'Leaderboard - Coming Soon',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        pageBuilder: (context, state) => MaterialPage(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Notifications'),
              backgroundColor: AppColors.darkGray,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.neonRed),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(
              child: Text(
                'No new notifications',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/help',
        name: 'help',
        pageBuilder: (context, state) => MaterialPage(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Help & Support'),
              backgroundColor: AppColors.darkGray,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.neonRed),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(
              child: Text(
                'Help Center - Coming Soon',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        redirect: (context, state) => '/splash',
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: AppColors.darkestGray,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '404',
              style: TextStyle(
                fontSize: 72,
                color: AppColors.neonRed,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 30),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Case Not Found',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'This investigation path doesn\'t exist',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => context.go('/dashboard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonRed,
                  ),
                  child: const Text('Return to Dashboard'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
});