import 'package:flutter/foundation.dart';

/// Tolerant model for `GET /api/app-config/` (additive-only forever).
///
/// Unknown enum values and unknown fields are ignored; only the fields the
/// v1 schema marks as `required` are non-nullable.
enum ClientUpdateStatus { ok, updateAvailable, updateRequired, unknown }

@immutable
class PlatformBlock {
  const PlatformBlock({
    this.minSupportedBuild = 0,
    this.latestBuild = 0,
    this.storeUrl = '',
  });

  final int minSupportedBuild;
  final int latestBuild;
  final String storeUrl;

  factory PlatformBlock.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const PlatformBlock();
    return PlatformBlock(
      minSupportedBuild: (json['min_supported_build'] as num?)?.toInt() ?? 0,
      latestBuild: (json['latest_build'] as num?)?.toInt() ?? 0,
      storeUrl: json['store_url'] is String ? json['store_url'] as String : '',
    );
  }
}

@immutable
class DeprecationDates {
  const DeprecationDates({this.deprecatedOn, this.sunsetOn});

  final String? deprecatedOn;
  final String? sunsetOn;

  factory DeprecationDates.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DeprecationDates();
    return DeprecationDates(
      deprecatedOn: json['deprecated_on'] is String
          ? json['deprecated_on'] as String
          : null,
      sunsetOn:
          json['sunset_on'] is String ? json['sunset_on'] as String : null,
    );
  }

  bool get hasSunset => sunsetOn != null && sunsetOn!.isNotEmpty;
}

@immutable
class UpdateMessage {
  const UpdateMessage({this.en = '', this.bn = ''});

  final String en;
  final String bn;

  factory UpdateMessage.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UpdateMessage();
    return UpdateMessage(
      en: json['en'] is String ? json['en'] as String : '',
      bn: json['bn'] is String ? json['bn'] as String : '',
    );
  }

  String forLocale(String languageCode) {
    if (languageCode == 'bn' && bn.isNotEmpty) return bn;
    return en;
  }
}

class AppConfigResponse {
  const AppConfigResponse({
    required this.apiCurrentVersion,
    required this.deprecations,
    required this.clientStatus,
    required this.android,
    required this.ios,
    required this.updateMessage,
    this.clientPlatform,
    this.clientBuild,
    this.serverTime,
  });

  final String apiCurrentVersion;
  final Map<String, DeprecationDates> deprecations;
  final ClientUpdateStatus clientStatus;
  final PlatformBlock android;
  final PlatformBlock ios;
  final UpdateMessage updateMessage;
  final String? clientPlatform;
  final int? clientBuild;
  final String? serverTime;

  bool get isUpdateRequired =>
      clientStatus == ClientUpdateStatus.updateRequired;

  bool get isUpdateAvailable =>
      clientStatus == ClientUpdateStatus.updateAvailable;

  DeprecationDates? deprecationFor(String version) => deprecations[version];

  PlatformBlock platformBlock(String platform) =>
      platform == 'ios' ? ios : android;

  factory AppConfigResponse.fromJson(Map<String, dynamic> json) {
    final api = json['api'];
    final client = json['client'];
    final platforms = json['platforms'];

    final deprecations = <String, DeprecationDates>{};
    if (api is Map && api['deprecations'] is Map) {
      (api['deprecations'] as Map).forEach((key, value) {
        if (key is String) {
          deprecations[key] = DeprecationDates.fromJson(
            value is Map ? Map<String, dynamic>.from(value) : null,
          );
        }
      });
    }

    var status = ClientUpdateStatus.unknown;
    switch (client is Map ? client['status'] : null) {
      case 'ok':
        status = ClientUpdateStatus.ok;
        break;
      case 'update_available':
        status = ClientUpdateStatus.updateAvailable;
        break;
      case 'update_required':
        status = ClientUpdateStatus.updateRequired;
        break;
    }

    return AppConfigResponse(
      apiCurrentVersion:
          api is Map && api['current_version'] is String
              ? api['current_version'] as String
              : '',
      deprecations: deprecations,
      clientStatus: status,
      android: PlatformBlock.fromJson(
        platforms is Map && platforms['android'] is Map
            ? Map<String, dynamic>.from(platforms['android'] as Map)
            : null,
      ),
      ios: PlatformBlock.fromJson(
        platforms is Map && platforms['ios'] is Map
            ? Map<String, dynamic>.from(platforms['ios'] as Map)
            : null,
      ),
      updateMessage: UpdateMessage.fromJson(
        json['update_message'] is Map
            ? Map<String, dynamic>.from(json['update_message'] as Map)
            : null,
      ),
      clientPlatform:
          client is Map && client['platform'] is String
              ? client['platform'] as String
              : null,
      clientBuild:
          client is Map ? (client['build'] as num?)?.toInt() : null,
      serverTime:
          json['server_time'] is String ? json['server_time'] as String : null,
    );
  }
}
