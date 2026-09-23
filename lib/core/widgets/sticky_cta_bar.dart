import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'primary_cta_button.dart';

class StickyCtaBar extends StatelessWidget {
  const StickyCtaBar({
    super.key,
    required this.buttonLabel,
    required this.onPressed,
    this.kicker,
    this.subtitle,
    this.trailingIcon = '→',
    this.isEnabled = true,
    this.isLoading = false,
  });

  final String buttonLabel;
  final VoidCallback? onPressed;
  final String? kicker;
  final String? subtitle;
  final String? trailingIcon;
  final bool isEnabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.paper,
        border: Border(
          top: BorderSide(color: AppColors.ink, width: AppColors.borderWidth),
        ),
      ),
      child: Row(
        children: [
          if (kicker != null || subtitle != null) ...[
            Expanded(
              flex: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (kicker != null)
                    Text(
                      kicker!.toUpperCase(),
                      style: AppTypography.kicker.copyWith(fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.h2.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: kicker != null || subtitle != null ? 5 : 1,
            child: PrimaryCtaButton(
              label: buttonLabel,
              onPressed: onPressed,
              trailingIcon: trailingIcon,
              isEnabled: isEnabled,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
