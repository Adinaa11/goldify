import 'package:flutter/material.dart';

import '../models/user_profile_model.dart';
import '../repositories/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {

  final ProfileRepository repository;

  ProfileViewModel(
    this.repository,
  );

  UserProfileModel? profile;

  bool isLoading = true;

  Future<void> loadProfile() async {

    try {
      isLoading = true;
      notifyListeners();
      profile =
          await repository.loadProfile();

    } catch(e){
      debugPrint(
        "PROFILE LOAD ERROR: $e",
      );

    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await repository.supabase.auth.signOut();
  }
}