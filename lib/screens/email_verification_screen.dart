// File: lib/screens/email_verification_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/app_error_banner.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  Timer? _timer;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  bool _isResending = false;
  String? _statusMessage;
  bool _isStatusSuccess = false;

  @override
  void initState() {
    super.initState();
    // Auto-check verification status every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkVerificationStatus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerificationStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isVerified = await authProvider.checkEmailVerified();
    if (isVerified && mounted) {
      _timer?.cancel();
    }
  }

  void _startCooldown() {
    setState(() {
      _resendCooldown = 60;
    });
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleResend() async {
    if (_resendCooldown > 0 || _isResending) return;

    setState(() {
      _isResending = true;
      _statusMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.resendVerificationEmail();
      _startCooldown();
      if (mounted) {
        setState(() {
          _statusMessage = 'Verification email resent! Check your inbox.';
          _isStatusSuccess = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = e.toString().replaceFirst('Exception: ', '');
          _isStatusSuccess = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final authProvider = Provider.of<AuthProvider>(context);
    final email = authProvider.currentUser?.email ?? 'your email';
    final isWide = Responsive.isTablet(context) || Responsive.isDesktop(context);
    final horizPadding = Responsive.horizontalPadding(context);

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),

        // Icon card
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.mark_email_unread_outlined,
            size: 42,
            color: AppTheme.pureWhite,
          ),
        ),

            const SizedBox(height: 28),

            Text(
              'Verify your email',
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'We sent a verification link to',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Click the link in the email to activate your account.\nThis screen updates automatically once verified.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.45,
              ),
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 20),
              AppErrorBanner(
                message: _statusMessage!,
                isSuccess: _isStatusSuccess,
                onDismiss: () => setState(() => _statusMessage = null),
              ),
            ],

            const SizedBox(height: 32),

            // Resend button
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: _resendCooldown > 0 || _isResending ? null : AppTheme.buttonShadow,
              ),
              child: ElevatedButton(
                onPressed: _resendCooldown > 0 || _isResending
                    ? null
                    : _handleResend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.pureWhite,
                  disabledBackgroundColor: AppTheme.borderLight,
                  disabledForegroundColor: AppTheme.textTertiary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isResending
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
                        _resendCooldown > 0
                            ? 'Resend in ${_resendCooldown}s'
                            : 'Resend Verification Email',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Sign out / use different email
            TextButton(
              onPressed: () async {
                Provider.of<TaskProvider>(context, listen: false).clear();
                await authProvider.signOut();
              },
              child: Text(
                'Use a different email',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],
    );

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              left: horizPadding,
              right: horizPadding,
              top: 12,
              bottom: bottomPadding + 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: Responsive.authMaxWidth),
              child: isWide
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 36,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.pureWhite,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.borderLight),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: content,
                    )
                  : content,
            ),
          ),
        ),
      ),
    );
  }
}
