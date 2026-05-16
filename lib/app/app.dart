import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../core/i18n/locale_controller.dart';
import '../core/session/session_controller.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/data/services/auth_service.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import 'router.dart';

class SanadApp extends StatelessWidget {
  const SanadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleController>(
          create: (_) => LocaleController(),
        ),
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<AuthRepositoryImpl>(
          create: (context) => AuthRepositoryImpl(
            context.read<AuthService>(),
          ),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthRepositoryImpl>(),)
            // ..checkLoginStatus(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, SessionController>(
          create: (context) => SessionController(
            timeout: const Duration(minutes: 1),
            onTimeout: () async {
              final authProvider = context.read<AuthProvider>();
              if (authProvider.isLoggedIn) {
                await authProvider.logout();
              }
            },
          )..start(),
          update: (context, authProvider, previous) => previous!,
        ),
      ],
      child: Consumer3<LocaleController, AuthProvider, SessionController>(
        builder: (context, localeController, authProvider, sessionController, _) {
          return Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) {
              if (authProvider.isLoggedIn) {
                sessionController.registerInteraction();
              }
            },
            onPointerMove: (_) {
              if (authProvider.isLoggedIn) {
                sessionController.registerInteraction();
              }
            },
            child: MaterialApp.router(
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
              routerConfig: createRouter(authProvider),
            ),
          );
        },
      ),
    );
  }
}