import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:case_zero_detective/core/constants/app_colors.dart';
import 'package:case_zero_detective/core/constants/app_images.dart';
import 'package:case_zero_detective/core/providers/auth_provider.dart';
import 'package:case_zero_detective/core/services/auth_service.dart';
import 'package:case_zero_detective/core/services/analytics_service.dart'; // ADD THIS
import 'package:case_zero_detective/core/utils/validators.dart';
import 'package:case_zero_detective/widgets/custom_button.dart';
import 'package:case_zero_detective/widgets/custom_textfield.dart';
import 'package:case_zero_detective/widgets/loading_overlay.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();

  bool _isLoading = false;
  bool _passwordsVisible = false;
  bool _agreeToTerms = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      setState(() {
        _errorMessage = 'You must agree to the Terms of Service';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        displayName: _displayNameController.text.trim(),
      );

      // Track successful signup in analytics
      AnalyticsService().logSignup('email_password');
      AnalyticsService().logScreenView(screenName: 'DashboardScreen');

      // Navigation will happen automatically through TermsGuard
      // The TermsGuard will show terms dialog if needed

    } catch (e) {
      final errorMessage = _getUserFriendlyError(e.toString());
      setState(() {
        _errorMessage = errorMessage;
      });

      // Track signup error in analytics
      AnalyticsService().logError('signup_error', errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithGoogle();

      // Track successful Google signup in analytics
      AnalyticsService().logSignup('google');
      AnalyticsService().logScreenView(screenName: 'DashboardScreen');

    } catch (e) {
      final errorMessage = _getUserFriendlyError(e.toString());
      setState(() {
        _errorMessage = errorMessage;
      });

      // Track Google signup error in analytics
      AnalyticsService().logError('google_signup_error', errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getUserFriendlyError(String error) {
    if (error.contains('email-already-in-use')) {
      return 'This email is already registered. Please login instead.';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak. Please use a stronger password.';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email address.';
    } else if (error.contains('operation-not-allowed')) {
      return 'Email/password sign-up is not enabled.';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your connection.';
    }
    return error.replaceAll('Exception: ', '');
  }

  void _goToLogin() {
    AnalyticsService().logEvent(name: 'navigate_to_login');
    context.go('/login');
  }

  @override
  void initState() {
    super.initState();
    // Track screen view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService().logScreenView(screenName: 'SignupScreen');
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Creating your detective profile...',
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppImages.authBg),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.black.withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Back Button
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            onPressed: () {
                              AnalyticsService().logEvent(name: 'signup_back_pressed');
                              _goToLogin();
                            },
                            icon: Icon(
                              Icons.arrow_back,
                              color: AppColors.neonRed,
                              size: 28,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Logo
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.neonRed,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonRed.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.asset(
                              AppImages.appLogo,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Title
                        Text(
                          'JOIN THE FORCE',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neonRed,
                            fontFamily: 'Courier New',
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: AppColors.neonRed.withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          'CREATE DETECTIVE PROFILE',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            letterSpacing: 1.5,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Form Container
                        Container(
                          padding: const EdgeInsets.all(24),
                          constraints: BoxConstraints(
                            maxWidth: 400,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.darkestGray.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.neonRed.withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonRed.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 30,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: _buildFormContent(),
                        ),
                      ],
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

  Widget _buildFormContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.neonRed.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.neonRed),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error,
                  color: AppColors.neonRed,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

        Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _displayNameController,
                label: 'DETECTIVE NAME',
                hintText: 'Enter your detective name',
                prefixIcon: Icons.person,
                validator: Validators.validateDisplayName,
              ),

              const SizedBox(height: 20),

              CustomTextField(
                controller: _emailController,
                label: 'EMAIL',
                hintText: 'detective@investigation.gov',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),

              const SizedBox(height: 20),

              CustomTextField(
                controller: _passwordController,
                label: 'PASSWORD',
                hintText: 'At least 6 characters',
                prefixIcon: Icons.lock,
                obscureText: !_passwordsVisible,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _passwordsVisible = !_passwordsVisible;
                    });
                  },
                  icon: Icon(
                    _passwordsVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: AppColors.textSecondary,
                  ),
                ),
                validator: Validators.validatePassword,
              ),

              const SizedBox(height: 20),

              CustomTextField(
                controller: _confirmPasswordController,
                label: 'CONFIRM PASSWORD',
                hintText: 'Re-enter your password',
                prefixIcon: Icons.lock_outline,
                obscureText: !_passwordsVisible,
                validator: (value) =>
                    Validators.validateConfirmPassword(
                      value,
                      _passwordController.text,
                    ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.darkGray.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.neonRed.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                        if (value != null) {
                          AnalyticsService().logEvent(
                            name: 'terms_checkbox_changed',
                            parameters: {'checked': value},
                          );
                        }
                      },
                      activeColor: AppColors.neonRed,
                      checkColor: AppColors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TERMS OF SERVICE',
                            style: TextStyle(
                              color: AppColors.neonRed,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'I agree to the Terms of Service, Privacy Policy, and understand that all investigations are confidential.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              CustomButton(
                text: 'CREATE ACCOUNT',
                onPressed: () {
                  AnalyticsService().logEvent(name: 'signup_button_pressed');
                  _signup();
                },
                icon: Icons.person_add_alt,
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: AppColors.lighterGray.withOpacity(0.5),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: AppColors.lighterGray.withOpacity(0.5),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    AnalyticsService().logEvent(name: 'google_signup_button_pressed');
                    _signInWithGoogle();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.g_mobiledata,
                        color: Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Sign up with Google',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already a detective? ',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: _goToLogin,
                    child: Text(
                      'LOGIN HERE',
                      style: TextStyle(
                        color: AppColors.neonRed,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}