import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/security_model.dart';

class SecurityViewModel {

  final supabase = Supabase.instance.client;

  Future<SecurityModel> getSecurityInfo() async {

    final user = supabase.auth.currentUser;

    String deviceName = "Unknown Device";
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final android =
          await deviceInfo.androidInfo;

      deviceName = android.model;
    }

    else if (Platform.isIOS) {

      final ios =
          await deviceInfo.iosInfo;

      deviceName = ios.name;
    }

    return SecurityModel(

      email: user?.email ?? "-",
      deviceName: deviceName,

      lastLogin:
          user?.lastSignInAt?.toString() ?? "-",
    );
  }
}