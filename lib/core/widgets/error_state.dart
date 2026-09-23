import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'primary_cta_button.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.title = 'Something went wrong',
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.accentTint,
                border: Border.all(color: AppColors.ink, width: AppColors.borderWidth),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 28,
                color: AppColors.accentDeep,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTypography.secondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            PrimaryCtaButton(
              label: 'Retry',
              onPressed: onRetry,
              trailingIcon: '↻',
              height: 44,
            ),
          ],
        ),
      ),
    );
  }
}
