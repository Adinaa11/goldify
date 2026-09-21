import 'dart:io';

import 'package:flutter/material.dart';

import '../models/user_profile_model.dart';
import '../repositories/profile_repository.dart';

class PersonalInfoViewModel extends ChangeNotifier {

  final ProfileRepository repository;

  PersonalInfoViewModel(
    this.repository,
  );

  UserProfileModel? profile;
  File? imageFile;
  bool isLoading = true;
  bool isSaving = false;

  // LOAD PROFILE
  Future<void> loadProfile() async {
    try {
      isLoading = true;

      notifyListeners();

      profile =
          await repository.loadProfile();

    } catch(e){

      debugPrint(
        "LOAD ERROR VIEWMODEL: $e"
      );

    } finally {

      isLoading = false;
      notifyListeners();
    }
  }

  // PICK IMAGE
  void setImage(File file){
    imageFile = file;
    notifyListeners();
  }

  // UPDATE PROFILE
  Future<bool> updateProfile({
    required String name,
    required String phone,
  }) async {

    try {

      isSaving = true;
      notifyListeners();

      String? uploadedUrl =
          profile?.avatarUrl;

      // upload jika user pilih foto baru
      if(imageFile != null){

        final result =
            await repository.uploadImage(
              imageFile!,
            );

        if(result == null){
          return false;
        }
        uploadedUrl = result;
      }

      final updatedProfile =
          UserProfileModel(
            name: name,
            email:
            profile?.email ?? '',
            phone: phone,
            avatarUrl:
            uploadedUrl,
          );

      await repository.updateProfile(
        updatedProfile,
      );

      profile =
          updatedProfile;

      return true;

    }catch(e){

      debugPrint(
        "UPDATE ERROR VIEWMODEL: $e"
      );

      return false;

    }finally{
      isSaving = false;
      notifyListeners();
    }
  }
}