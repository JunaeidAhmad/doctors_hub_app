import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  var appBuild = 0;
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    appBuild = int.tryParse(packageInfo.buildNumber) ?? 0;
  } catch (_) {
    // Keep 0: the header is still sent, the server treats it as a build.
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appBuildNumberProvider.overrideWithValue(appBuild),
      ],
      child: const DoctorsHubApp(),
    ),
  );
}
