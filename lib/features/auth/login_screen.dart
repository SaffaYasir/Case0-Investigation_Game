import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/analytics_service.dart'; // ADD THIS
import '../../core/utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/loading_overlay.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _passwordVisible = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Track successful login in analytics
      AnalyticsService().logLogin('email_password');
      AnalyticsService().logScreenView(screenName: 'DashboardScreen');

    } catch (e) {
      final errorMessage = _getUserFriendlyError(e.toString());
      setState(() {
        _errorMessage = errorMessage;
      });

      // Track login error in analytics
      AnalyticsService().logError('login_error', errorMessage);
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

      // Track successful Google login in analytics
      AnalyticsService().logLogin('google');
      AnalyticsService().logScreenView(screenName: 'DashboardScreen');

    } catch (e) {
      final errorMessage = _getUserFriendlyError(e.toString());
      setState(() {
        _errorMessage = errorMessage;
      });

      // Track Google login error in analytics
      AnalyticsService().logError('google_login_error', errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getUserFriendlyError(String error) {
    if (error.contains('user-not-found') || error.contains('wrong-password')) {
      return 'Invalid email or password';
    } else if (error.contains('too-many-requests')) {
      return 'Too many failed attempts. Please try again later.';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your connection.';
    } else if (error.contains('user-disabled')) {
      return 'This account has been disabled.';
    } else if (error.contains('operation-not-allowed')) {
      return 'Email/password sign-in is not enabled.';
    }
    return error.replaceAll('Exception: ', '');
  }

  void _goToSignup() {
    AnalyticsService().logEvent(name: 'navigate_to_signup');
    context.push('/signup');
  }

  void _goToForgotPassword() {
    AnalyticsService().logEvent(name: 'navigate_to_forgot_password');
    context.push('/forgot-password');
  }

  @override
  void initState() {
    super.initState();
    // Track screen view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService().logScreenView(screenName: 'LoginScreen');
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Authenticating...',
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
                              AnalyticsService().logEvent(name: 'login_back_pressed');
                              context.go('/');
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
                          'CASE 0',
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
                          'DETECTIVE LOGIN',
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
                hintText: 'Enter your password',
                prefixIcon: Icons.lock,
                obscureText: !_passwordVisible,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                  icon: Icon(
                    _passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: AppColors.textSecondary,
                  ),
                ),
                validator: Validators.validatePassword,
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _goToForgotPassword,
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: AppColors.neonRed,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              CustomButton(
                text: 'LOGIN',
                onPressed: () {
                  AnalyticsService().logEvent(name: 'login_button_pressed');
                  _login();
                },
                icon: Icons.login,
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
                    AnalyticsService().logEvent(name: 'google_login_button_pressed');
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
                        'Sign in with Google',
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
                    'New Detective? ',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: _goToSignup,
                    child: Text(
                      'JOIN THE FORCE',
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