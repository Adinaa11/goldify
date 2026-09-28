import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/change_password_model.dart';

class ChangePasswordViewModel extends ChangeNotifier {

  bool isOldHidden = true;
  bool isNewHidden = true;
  bool isConfirmHidden = true;

  final TextEditingController oldPasswordController =
      TextEditingController();

  final TextEditingController newPasswordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  // 👁️ toggle visibility
  void toggleOldPassword(){
    isOldHidden = !isOldHidden;
    notifyListeners();
  }

  void toggleNewPassword(){
    isNewHidden = !isNewHidden;
    notifyListeners();
  }

  void toggleConfirmPassword(){
    isConfirmHidden = !isConfirmHidden;
    notifyListeners();
  }

  // 📦 ambil data
  ChangePasswordModel get passwordData {
    return ChangePasswordModel(
      oldPassword: oldPasswordController.text,
      newPassword: newPasswordController.text,
      confirmPassword: confirmPasswordController.text,
    );
  }

  // ✅ validasi input
  String? validatePassword(){
    final data = passwordData;

    final passwordRegex =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$');

    if(
      data.oldPassword.isEmpty ||
      data.newPassword.isEmpty ||
      data.confirmPassword.isEmpty
    ){
      return "Semua field harus diisi";
    }

    if(!passwordRegex.hasMatch(data.newPassword)){
      return "Password minimal 8 karakter, ada huruf besar, kecil, angka, dan simbol";
    }

    if(data.newPassword != data.confirmPassword){
      return "Konfirmasi password tidak sama";
    }

    return null;
  }

  // 🔥 FIX UTAMA (UPDATE + LOGOUT)
  Future<String?> changePassword() async {
    final validation = validatePassword();

    if (validation != null) return validation;

    try {
      final supabase = Supabase.instance.client;

      // 🔍 pastikan user login
      final user = supabase.auth.currentUser;
      if (user == null) {
        return "Session habis, silakan login ulang";
      }

      // 🔐 update password ke supabase
      await supabase.auth.updateUser(
        UserAttributes(
          password: newPasswordController.text,
        ),
      );

      // 🔥 logout otomatis
      await supabase.auth.signOut();

      return null; // sukses
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Terjadi kesalahan. Silakan coba lagi.";
    }
  }

  // 🧹 dispose
  void disposeController(){
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }
}