import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'state/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const IptvStreamerApp(),
    ),
  );
}

class IptvStreamerApp extends ConsumerWidget {
  const IptvStreamerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = AppRouter.create();
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(isTv: false),
      darkTheme: AppTheme.dark(isTv: false),
      themeMode: ThemeMode.dark,
      routerConfig: router,
      builder: (context, child) {
        // Aplica tema adaptativo com base na largura da tela (TV vs celular).
        final isTv = MediaQuery.sizeOf(context).width >= 960;
        return Theme(
          data: AppTheme.dark(isTv: isTv),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
