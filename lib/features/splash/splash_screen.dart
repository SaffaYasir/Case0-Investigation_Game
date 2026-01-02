import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _hasNavigated = false;
  bool _showContent = false;
  bool _shouldShowBackground = false;

  @override
  void initState() {
    super.initState();

    // Start with pure black to hide native splash flash
    // Then quickly fade in the actual splash screen

    // Phase 1: Immediately show black (to hide native flash)
    Timer(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _shouldShowBackground = true;
        });
      }
    });

    // Phase 2: Fade in the actual splash content
    Timer(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _showContent = true;
        });
      }
    });

    // Phase 3: Navigate after total delay
    Timer(const Duration(seconds: 3), () {
      _navigateBasedOnAuth();
    });
  }

  void _navigateBasedOnAuth() {
    if (_hasNavigated || !mounted) return;

    _hasNavigated = true;

    final authState = ref.read(authStateProvider);

    authState.when(
      data: (user) {
        if (mounted) {
          if (user != null) {
            context.go('/dashboard');
          } else {
            context.go('/login');
          }
        }
      },
      loading: () {
        if (mounted) {
          context.go('/login');
        }
      },
      error: (error, stack) {
        if (mounted) {
          context.go('/login');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Always black background first
      body: AnimatedContainer(
        duration: 300.ms,
        curve: Curves.easeIn,
        decoration: BoxDecoration(
          image: _shouldShowBackground
              ? DecorationImage(
            image: AssetImage(AppImages.splashBg),
            fit: BoxFit.cover,
          )
              : null,
        ),
        child: AnimatedOpacity(
          opacity: _showContent ? 1 : 0,
          duration: 800.ms,
          curve: Curves.easeInOut,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
            child: Center( // Changed from SafeArea + Column to Center
              child: SingleChildScrollView( // Added to prevent overflow
                child: Padding(
                  padding: const EdgeInsets.all(20), // Consistent padding
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center, // Added for center alignment
                    children: [
                      // Logo with animation
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.darkGray.withOpacity(0.5),
                          border: Border.all(
                            color: AppColors.neonRed,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonRed.withOpacity(0.5),
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
                      )
                          .animate()
                          .scale(
                        duration: 1.seconds,
                        curve: Curves.elasticOut,
                      )
                          .fadeIn(delay: 200.ms),

                      const SizedBox(height: 30),

                      // App Title with typewriter effect
                      SizedBox(
                        width: double.infinity, // Takes full width
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'CASE 0',
                              textStyle: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: AppColors.neonRed,
                                fontFamily: 'Courier New',
                                letterSpacing: 3,
                                shadows: [
                                  Shadow(
                                    color: AppColors.neonRed.withOpacity(0.8),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center, // Center align text
                              speed: const Duration(milliseconds: 150),
                            ),
                          ],
                          totalRepeatCount: 1,
                          onTap: () {
                            print("Tap Event");
                          },
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        'CRIME INVESTIGATION',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          fontFamily: 'Courier New',
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center, // Center align
                      )
                          .animate()
                          .fadeIn(delay: 1.seconds)
                          .slideY(begin: 0.1, end: 0, duration: 500.ms),

                      const SizedBox(height: 50),

                      // Loading indicator section
                      SizedBox(
                        width: 250,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center, // Center align
                          children: [
                            // Animated loading bar
                            Container(
                              width: 250,
                              height: 4,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: AppColors.darkGray,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.neonRed.withOpacity(0.1),
                                          AppColors.neonRed,
                                          AppColors.neonRed.withOpacity(0.1),
                                        ],
                                      ),
                                    ),
                                  )
                                      .animate(
                                    onPlay: (controller) => controller.repeat(reverse: true),
                                  )
                                      .slide(
                                    duration: 1.5.seconds,
                                    begin: const Offset(-1, 0),
                                    end: const Offset(4, 0),
                                    curve: Curves.easeInOut,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Loading text with fingerprint icon
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center, // Center align
                              children: [
                                Icon(
                                  Icons.fingerprint,
                                  color: AppColors.neonRed,
                                  size: 20,
                                )
                                    .animate(
                                  onPlay: (controller) => controller.repeat(reverse: true),
                                )
                                    .scale(duration: 1.seconds)
                                    .fadeIn(delay: 300.ms),
                                const SizedBox(width: 10),
                                Text(
                                  'Initializing System...',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                )
                                    .animate()
                                    .fadeIn(delay: 500.ms)
                                    .slideX(begin: 0.2, end: 0, duration: 400.ms),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Version info at bottom
                      const SizedBox(height: 50), // Added spacing instead of Spacer
                      Text(
                        'v1.0.0',
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 12,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 1.5.seconds)
                          .slideY(begin: 0.5, end: 0, duration: 600.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}