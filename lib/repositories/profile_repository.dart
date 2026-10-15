import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile_model.dart';

class ProfileRepository {

  final supabase =
      Supabase.instance.client;

  // LOAD PROFILE
  Future<UserProfileModel?> loadProfile() async {

    final user =
        supabase.auth.currentUser;

    if(user == null){
      return null;
    }

    try {

      final data =
          await supabase
              .from('profiles')
              .select()
              .eq('id', user.id)
              .single();
      return UserProfileModel
          .fromJson(data);
    } catch(e){
      throw Exception(
        "LOAD ERROR: $e"
      );
    }
  }

  // UPLOAD IMAGE
  Future<String?> uploadImage(
      File file
      ) async {

    try {

      final user =
          supabase.auth.currentUser;

      if(user == null){
        return null;
      }

      final fileName =
          "${user.id}.jpg";

      await supabase.storage
          .from('avatars')
          .upload(
            fileName,
            file,
            fileOptions:
            const FileOptions(
              upsert:true,
              contentType:
              'image/jpeg',
            ),
          );

      final publicUrl =
          supabase.storage
              .from('avatars')
              .getPublicUrl(fileName);

      return
      "$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}";

    }catch(e){

      print(
        "UPLOAD ERROR: $e"
      );
      return null;
    }
  }

  // UPDATE PROFILE
  Future<void> updateProfile(
      UserProfileModel profile
      ) async {

    final user =
        supabase.auth.currentUser;

    if(user == null){
      return;
    }

    await supabase
        .from('profiles')
        .update(
          profile.toUpdateJson()
        )
        .eq(
          'id',
          user.id
        )
        .select();
  }
}