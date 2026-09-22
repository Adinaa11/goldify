import 'package:flutter/material.dart';
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

  ChangePasswordModel get passwordData {
    return ChangePasswordModel(

      oldPassword:
          oldPasswordController.text,

      newPassword:
          newPasswordController.text,

      confirmPassword:
          confirmPasswordController.text,
    );
  }

  String? validatePassword(){
    final data = passwordData;

    final passwordRegex =
        RegExp(
          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$'
        );

    if(
      data.oldPassword.isEmpty ||
      data.newPassword.isEmpty ||
      data.confirmPassword.isEmpty
    ){

      return "Semua field harus diisi";
    }

    if(!passwordRegex.hasMatch(data.newPassword)){

      return
      "Password minimal 8 karakter, ada huruf besar, kecil, angka, dan simbol";
    }

    if(data.newPassword != data.confirmPassword){

      return
      "Konfirmasi password tidak sama";
    }
    return null;
  }
  void disposeController(){

    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }
}