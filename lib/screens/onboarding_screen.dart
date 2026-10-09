// File: lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/preferences_service.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback? onComplete;

  const OnboardingScreen({super.key, this.onComplete});

  Future<void> _handleGetStarted(BuildContext context) async {
    await PreferencesService.setHasSeenOnboarding(true);
    onComplete?.call();
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignupScreen(),
      ),
    );
  }

  Future<void> _handleLogIn(BuildContext context) async {
    await PreferencesService.setHasSeenOnboarding(true);
    onComplete?.call();
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final horizPadding = Responsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: ResponsiveContainer(
            maxWidth: Responsive.authMaxWidth,
            child: Padding(
              padding: EdgeInsets.only(
                left: horizPadding,
                right: horizPadding,
                top: 24,
                bottom: bottomPadding + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Hero Tulip Logo
                  Image.asset(
                    'assets/tulip.png',
                    width: 108,
                    height: 108,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 36),

                  // Refined Deep Maroon Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.secondarySoft,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.secondary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppTheme.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'MINIMAL TASK PLANNER',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.secondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Title and Subtitle with high aesthetic typography
                  Text(
                    'Get things done.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.8,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    'Plan, prioritize, and accomplish your tasks with clarity and focus.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      color: AppTheme.textSecondary,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Primary "Get Started" Button in Olive Green
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.buttonShadow,
                    ),
                    child: ElevatedButton(
                      onPressed: () => _handleGetStarted(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.pureWhite,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Get started',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.pureWhite,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Secondary "Log In" Button in Deep Maroon accent
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => _handleLogIn(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.secondary,
                        side: BorderSide(
                          color: AppTheme.secondary.withValues(alpha: 0.7),
                          width: 1.4,
                        ),
                        backgroundColor: AppTheme.pureWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Log in',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.secondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
