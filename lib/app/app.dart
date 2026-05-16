import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import '../core/i18n/locale_controller.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

class SanadApp extends StatelessWidget {
  const SanadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocaleController(),
      child: Consumer<LocaleController>(
        builder: (context, localeController, _) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Sanad',
            theme: AppTheme.darkTheme,
            locale: localeController.locale,
            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}