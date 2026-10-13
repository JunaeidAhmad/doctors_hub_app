import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/app_failure.dart';
import '../providers/app_providers.dart';
import 'app_config.dart';

/// Set by the network layer when a 426 or an `update_required` app-config
/// response arrives. `go_router` listens to it and blocks the app.
final updateRequiredProvider =
    Provider<ValueNotifier<UpdateRequiredFailure?>>((ref) {
  final notifier = ValueNotifier<UpdateRequiredFailure?>(null);
  ref.onDispose(notifier.dispose);
  return notifier;
});

/// Calls `GET /api/app-config/` once on launch. Never blocks the app:
/// offline or a failed call resolves to `null` and the app continues.
final appConfigProvider = FutureProvider<AppConfigResponse?>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final response =
        await apiClient.get<Map<String, dynamic>>(apiClient.appConfigUrl);
    final data = response.data;
    if (data == null) return null;

    final config = AppConfigResponse.fromJson(Map<String, dynamic>.from(data));

    if (config.isUpdateRequired) {
      final platformBlock =
          config.platformBlock(ref.read(appPlatformProvider));
      final storeUrl = platformBlock.storeUrl;
      final message = config.updateMessage;
      ref.read(updateRequiredProvider).value = UpdateRequiredFailure(
        code: 'app_update_required',
        storeUrl: storeUrl.isEmpty ? null : storeUrl,
        messageEn: message.en.isEmpty ? null : message.en,
        messageBn: message.bn.isEmpty ? null : message.bn,
        message: message.en,
      );
    }

    return config;
  } catch (_) {
    return null;
  }
});
