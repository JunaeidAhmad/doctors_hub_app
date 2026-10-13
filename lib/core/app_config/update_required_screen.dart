import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/dh_scaffold.dart';
import '../widgets/kicker.dart';
import 'app_config_providers.dart';
import 'update_actions.dart';

/// Full-screen block shown while `updateRequiredProvider` is set (426 or
/// `client.status == update_required`). No back, no tab bar.
class UpdateRequiredScreen extends ConsumerWidget {
  const UpdateRequiredScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateNotifier = ref.watch(updateRequiredProvider);
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;
    final isBn = locale.languageCode == 'bn';

    return ValueListenableBuilder(
      valueListenable: updateNotifier,
      builder: (context, failure, _) {
        final nativeMessage = isBn
            ? (failure?.messageBn ?? failure?.messageEn)
            : (failure?.messageEn ?? failure?.messageBn);
        final message = (nativeMessage != null && nativeMessage.isNotEmpty)
            ? nativeMessage
            : l10n.updateRequiredFallback;
        final storeUrl = failure?.storeUrl ?? '';

        return PopScope(
          canPop: false,
          child: DhScaffold(
            backgroundColor: AppColors.paper,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    const Kicker('DOCTORS HUB'),
                    const SizedBox(height: 12),
                    Text(l10n.updateRequiredTitle, style: AppTypography.h1),
                    const SizedBox(height: 12),
                    Text(message, style: AppTypography.body),
                    const SizedBox(height: 28),
                    if (storeUrl.isNotEmpty)
                      Container(
                        height: 52,
                        color: AppColors.accent,
                        child: InkWell(
                          onTap: () => openStoreUrl(storeUrl),
                          child: Center(
                            child: Text(
                              l10n.updateNow,
                              style: AppTypography.button
                                  .copyWith(color: AppColors.paper),
                            ),
                          ),
                        ),
                      ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
