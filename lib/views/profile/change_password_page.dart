import 'package:flutter/material.dart';
import '../../viewmodels/change_password_viewmodel.dart';

class ChangePasswordPage extends StatefulWidget {

  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() =>
      _ChangePasswordPageState();

}

class _ChangePasswordPageState
    extends State<ChangePasswordPage> {
  late ChangePasswordViewModel viewModel;

  @override
  void initState() {

    super.initState();

    viewModel =
        ChangePasswordViewModel();
  }

  @override
  void dispose(){
    viewModel.disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Colors.white,

        elevation: 0,

        iconTheme:
        const IconThemeData(
          color: Color(0xFFF7931E),
        ),

        title:
        const Text(
          "Ubah Kata Sandi",

          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(

              width: double.infinity,

              padding:
              const EdgeInsets.symmetric(
                vertical: 28,
                horizontal:20,
              ),

              decoration:
              const BoxDecoration(
                color: Colors.white,

                borderRadius:
                BorderRadius.only(

                  bottomLeft:
                  Radius.circular(24),

                  bottomRight:
                  Radius.circular(24),
                ),
              ),

              child:
              const Column(
                children: [
                  Text(
                    "Ubah Kata Sandi",

                    style:
                    TextStyle(
                      fontSize:18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  SizedBox(height:8),

                  Text(

                    "Pastikan kata sandi Anda kuat dan tidak mudah ditebak.",

                    textAlign:
                    TextAlign.center,

                    style:
                    TextStyle(
                      fontSize:13,
                      color:Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height:20),

            _buildField(
              label:"Password Lama",

              controller:
              viewModel.oldPasswordController,

              isHidden:
              viewModel.isOldHidden,

              onToggle:
              viewModel.toggleOldPassword,
            ),

            _buildField(

              label:"Password Baru",

              controller:
              viewModel.newPasswordController,

              isHidden:
              viewModel.isNewHidden,

              onToggle:
              viewModel.toggleNewPassword,
            ),

            _buildField(

              label:"Konfirmasi Password",

              controller:
              viewModel.confirmPasswordController,

              isHidden:
              viewModel.isConfirmHidden,

              onToggle:
              viewModel.toggleConfirmPassword,
            ),

            const SizedBox(height:20),

            Padding(

              padding:
              const EdgeInsets.symmetric(
                horizontal:16,
              ),

              child:
              SizedBox(
                width:double.infinity,

                child:
                ElevatedButton(

                  onPressed: (){

                    final message =
                    viewModel.validatePassword();

                    if(message == null){

                      _showMessage(
                        "Kata sandi berhasil diperbarui",
                        true,
                      );
                    }
                    else{

                      _showMessage(
                        message,
                        false,
                      );
                    }
                  },

                  style:
                  ElevatedButton.styleFrom(

                    backgroundColor:
                    const Color(0xFFF7931E),

                    padding:
                    const EdgeInsets.symmetric(
                      vertical:14,
                    ),

                    shape:
                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                  ),

                  child:
                  const Text(

                    "Simpan Perubahan",

                    style:
                    TextStyle(
                      color:Colors.white,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height:20),

            Container(
              margin:
              const EdgeInsets.symmetric(
                horizontal:16,
              ),

              padding:
              const EdgeInsets.all(16),

              decoration:
              BoxDecoration(

                color:
                const Color(0xFFFFF3E6),

                borderRadius:
                BorderRadius.circular(16),

                border:
                Border.all(
                  color:
                  const Color(0xFFF5D2A9),
                ),
              ),

              child:
              const Row(

                children: [

                  Icon(
                    Icons.info_outline,
                    color:
                    Color(0xFFF7931E),
                  ),

                  SizedBox(width:10),

                  Expanded(

                    child:
                    Text(

                      "Gunakan minimal 8 karakter, kombinasi huruf besar, kecil, angka, dan simbol.",

                      style:
                      TextStyle(
                        fontSize:12,
                        color:Colors.grey,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool isHidden,
    required VoidCallback onToggle,
  }){

    return Container(

      margin:
      const EdgeInsets.symmetric(
        horizontal:16,
        vertical:6,
      ),

      padding:
      const EdgeInsets.symmetric(
        horizontal:12,
      ),

      decoration:
      BoxDecoration(
        color:Colors.white,

        borderRadius:
        BorderRadius.circular(14),
      ),

      child:
      TextField(
        controller:controller,

        obscureText:isHidden,

        decoration:
        InputDecoration(

          border:
          InputBorder.none,

          labelText:label,

          suffixIcon:
          IconButton(

            icon:
            Icon(

              isHidden
              ? Icons.visibility_off
              : Icons.visibility,
            ),

            onPressed:onToggle,
          ),
        ),
      ),
    );
  }

  void _showMessage(
      String message,
      bool success
      ){

    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(
        content:
        Text(message),

        backgroundColor:
        success
        ? Colors.green
        : Colors.red,
      ),
    );
  }
}