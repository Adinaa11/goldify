import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/splash_screen.dart';
import 'views/new_password_page.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xkfwmrwubfycwrxjyvbs.supabase.co',
    anonKey: 'sb_publishable_MrVK5tquee3E_kfBaZV1AA_xOFTMEXb',
  );

  runApp(const GoldifyApp());
}

class GoldifyApp extends StatefulWidget {
  const GoldifyApp({super.key});

  @override
  State<GoldifyApp> createState() => _GoldifyAppState();
}

class _GoldifyAppState extends State<GoldifyApp> {
  StreamSubscription<AuthState>? _authSubscription;
  bool _recoveryHandled = false;

  @override
  void initState() {
    super.initState();

    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        debugPrint('==============================');
        debugPrint('AUTH EVENT: ${data.event}');
        debugPrint('AUTH SESSION: ${data.session != null}');
        debugPrint('==============================');

        if (data.event == AuthChangeEvent.passwordRecovery) {
          debugPrint('PASSWORD RECOVERY DETECTED');

          if (_recoveryHandled) {
            debugPrint('RECOVERY ALREADY HANDLED');
            return;
          }

          _recoveryHandled = true;

          _openNewPasswordPage();
        }
      },
      onError: (error, stackTrace) {
        debugPrint('AUTH ERROR: $error');
      },
    );
  }

  void _openNewPasswordPage() {
    debugPrint('TRYING TO OPEN NEW PASSWORD PAGE...');

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final navigator = navigatorKey.currentState;

      debugPrint(
        'NAVIGATOR STATE: ${navigator != null ? "AVAILABLE" : "NULL"}',
      );

      if (navigator == null) {
        debugPrint('NAVIGATOR NOT READY - RETRYING...');

        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!mounted) return;

          final retryNavigator = navigatorKey.currentState;

          debugPrint(
            'RETRY NAVIGATOR STATE: '
            '${retryNavigator != null ? "AVAILABLE" : "NULL"}',
          );

          if (retryNavigator == null) {
            debugPrint('NAVIGATOR STILL NULL');
            return;
          }

          debugPrint('OPENING NEW PASSWORD PAGE NOW');

          retryNavigator.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const NewPasswordPage(),
            ),
            (route) => false,
          );
        });

        return;
      }

      debugPrint('OPENING NEW PASSWORD PAGE NOW');

      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const NewPasswordPage(),
        ),
        (route) => false,
      );
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Goldify',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}