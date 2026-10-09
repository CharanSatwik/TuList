// File: lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../utils/validators.dart';
import '../services/preferences_service.dart';
import '../widgets/app_error_banner.dart';
import '../widgets/auth_text_field.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  final bool fromOnboarding;
  const SignupScreen({super.key, this.fromOnboarding = false});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _localError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitSignUp() async {
    setState(() {
      _localError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _localError = 'Passwords do not match. Please re-enter them.';
      });
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signUp(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      PreferencesService.setHasSeenOnboarding(true);
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final authProvider = Provider.of<AuthProvider>(context);
    final displayedError = _localError ?? authProvider.errorMessage;
    final horizPadding = Responsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppTheme.textPrimary,
                  size: 22,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              left: horizPadding,
              right: horizPadding,
              top: 8,
              bottom: bottomPadding + 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: Responsive.authMaxWidth),
              // Dedicated Golden Cream Card enclosing the entire signup form
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.cardSage,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: AppTheme.borderLight,
                    width: 1.5,
                  ),
                  boxShadow: AppTheme.goldenCardShadow,
                ),
                child: _buildForm(context, authProvider, displayedError),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    AuthProvider authProvider,
    String? displayedError,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // App Logo
          Center(
            child: Image.asset(
              'assets/form.png',
              width: 78,
              height: 78,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),

          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.secondarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'NEW ACCOUNT',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.secondary,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Header Text
          Center(
            child: Text(
              "Let's get started!",
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Sign up to track and organize your tasks',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Inline Error Message
          if (displayedError != null)
            AppErrorBanner(
              message: displayedError,
              onDismiss: () {
                setState(() {
                  _localError = null;
                });
                authProvider.clearError();
              },
            ),

          AuthTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'name@example.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 18),
          AuthTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Min. 6 characters',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            validator: Validators.validatePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppTheme.textTertiary,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          const SizedBox(height: 18),
          AuthTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hint: 'Re-enter your password',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submitSignUp(),
            validator: (val) =>
                Validators.validateConfirmPassword(val, _passwordController.text),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppTheme.textTertiary,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
          ),

          const SizedBox(height: 26),

          // Sign up button in Dark Gold with button shadow
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.buttonShadow,
            ),
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : _submitSignUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.pureWhite,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: authProvider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.pureWhite,
                        ),
                      ),
                    )
                  : Text(
                      'Sign up',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.pureWhite,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 22),

          // Switch to Sign In
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  authProvider.clearError();
                  if (widget.fromOnboarding) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(fromOnboarding: true),
                      ),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  'Log in',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.secondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
