import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../core/config/environment.dart';
import '../core/l10n/locale_provider.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';

/// Provider global del ambiente actual
final envConfigProvider = Provider<EnvConfig>((ref) {
  throw UnimplementedError('envConfigProvider must be overridden at startup');
});

class RutaCeroApp extends ConsumerWidget {
  const RutaCeroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final env = ref.watch(envConfigProvider);

    return MaterialApp.router(
      title: env.appName,
      debugShowCheckedModeBanner: env.showDebugBanner,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      locale: locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter,
    );
  }
}
