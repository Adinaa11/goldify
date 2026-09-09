import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'views/splash_screen.dart';

/// GLOBAL LOCALE
ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('id'));

void main() {
  runApp(const GoldifyApp());
}

class GoldifyApp extends StatelessWidget {
  const GoldifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (context, locale, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Goldify',

          /// 🔥 INI YANG BIKIN GLOBAL CHANGE
          locale: locale,

          supportedLocales: const [
            Locale('id'),
            Locale('en'),
          ],

          /// 🔥 WAJIB BIAR GA ERROR TEXTFIELD
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          theme: ThemeData(
            useMaterial3: true,
          ),

          home: const SplashScreen(),
        );
      },
    );
  }
}