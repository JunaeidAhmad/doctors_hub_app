import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_config_providers.dart';
import 'update_actions.dart';

/// Dismissible soft banner shown on Home when the app-config call reports
/// `update_available` or a v1 sunset date. The copy comes from the server's
/// `update_message.<locale>` with an ARB fallback.
class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(appConfigProvider);
    final config = configAsync.valueOrNull;
    if (config == null) return const SizedBox.shrink();

    final isSunset = config.deprecationFor('v1')?.hasSunset ?? false;
    if (!config.isUpdateAvailable && !isSunset) {
      return const SizedBox.shrink();
    }

    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;
    final platform = ref.watch(appPlatformProvider);
    final storeUrl = config.platformBlock(platform).storeUrl;

    var message = config.updateMessage.forLocale(locale.languageCode);
    if (message.isEmpty) {
      message =
          isSunset ? l10n.updateSoonMessage : l10n.updateAvailableMessage;
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.accentWash,
        border: Border(
          bottom: BorderSide(color: AppColors.ink, width: AppColors.borderWidth),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              message,
              style: AppTypography.secondary.copyWith(color: AppColors.ink),
            ),
          ),
          if (storeUrl.isNotEmpty)
            TextButton(
              onPressed: () => openStoreUrl(storeUrl),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accentDeep,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Text(
                l10n.updateNow,
                style: const TextStyle(
                  fontFamily: AppTypography.fontArchivo,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close, size: 18, color: AppColors.ink),
            tooltip: l10n.close,
          ),
        ],
      ),
    );
  }
}
