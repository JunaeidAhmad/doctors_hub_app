import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class PrimaryCtaButton extends StatelessWidget {
  const PrimaryCtaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.trailingIcon = '→',
    this.height = 52.0,
    this.isLoading = false,
    this.isEnabled = true,
    this.backgroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? trailingIcon;
  final double height;
  final bool isLoading;
  final bool isEnabled;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final effectiveEnabled = isEnabled && !isLoading && onPressed != null;

    final bgColor = !effectiveEnabled
        ? AppColors.line
        : (backgroundColor ?? AppColors.accent);

    return SizedBox(
      height: height,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.zero,
        child: InkWell(
          onTap: effectiveEnabled ? onPressed : null,
          splashColor: AppColors.accentPressed,
          highlightColor: AppColors.accentPressed,
          borderRadius: BorderRadius.zero,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              border: Border.all(
                color: effectiveEnabled ? AppColors.ink : AppColors.line,
                width: AppColors.borderWidth,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.paper,
                            ),
                          ),
                        )
                      : Text(
                          label,
                          style: AppTypography.button.copyWith(
                            color: effectiveEnabled ? AppColors.paper : AppColors.muted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                if (!isLoading && trailingIcon != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    trailingIcon!,
                    style: TextStyle(
                      fontFamily: AppTypography.fontArchivo,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: effectiveEnabled ? AppColors.paper : AppColors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
