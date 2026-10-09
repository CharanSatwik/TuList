// File: lib/widgets/app_error_banner.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AppErrorBanner extends StatelessWidget {
  final String message;
  final bool isSuccess;
  final VoidCallback? onDismiss;

  const AppErrorBanner({
    super.key,
    required this.message,
    this.isSuccess = false,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSuccess ? AppTheme.priorityLowBg : AppTheme.deleteRedBg;
    final borderColor = isSuccess ? AppTheme.priorityLow : AppTheme.deleteRed;
    final iconColor = isSuccess ? AppTheme.priorityLow : AppTheme.deleteRed;
    final textColor = isSuccess ? const Color(0xFF065F46) : const Color(0xFF991B1B);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            isSuccess
                ? Icons.check_circle_outline_rounded
                : Icons.error_outline_rounded,
            color: iconColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textColor,
                height: 1.35,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              behavior: HitTestBehavior.opaque,
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: textColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
