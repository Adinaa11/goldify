import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user_profile_model.dart';
import '../../repositories/profile_repository.dart';
import '../../viewmodels/personal_info_viewmodel.dart';

class PersonalInfoPage extends StatefulWidget {

  const PersonalInfoPage({
    super.key,
  });

  @override
  State<PersonalInfoPage> createState()
      => _PersonalInfoPageState();
}

class _PersonalInfoPageState
    extends State<PersonalInfoPage> {

  late PersonalInfoViewModel viewModel;

  final ImagePicker picker =
      ImagePicker();

  @override
  void initState(){
    super.initState();

    viewModel =
        PersonalInfoViewModel(
          ProfileRepository(),
        );

    viewModel.loadProfile();
  }

  void _editField(
    String title,
    String value,
    Function(String) onSave,
  ) {
    final controller = TextEditingController(text: value);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Edit $title",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(controller: controller),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isEmpty) {
                      _msg("Tidak boleh kosong");
                      return;
                    }
                    onSave(controller.text.trim());
                    Navigator.pop(context);
                  },
                  child: const Text("Simpan"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F6F8),
          appBar: AppBar(
            title: const Text("Informasi Pribadi"),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          body: viewModel.isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
  final profile = viewModel.profile!;

  return Column(
    children: [
      const SizedBox(height: 20),

      // FOTO PROFIL
      GestureDetector(
        onTap: () async {
          final picked = await picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 70,
          );

          if (picked != null) {
            viewModel.setImage(File(picked.path));
          }
        },
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundImage:
                  viewModel.imageFile != null
                      ? FileImage(viewModel.imageFile!)
                      : (profile.avatarUrl != null &&
                              profile.avatarUrl!.isNotEmpty)
                          ? NetworkImage(profile.avatarUrl!)
                          : const AssetImage(
                              'assets/images/profile.png',
                            ) as ImageProvider,
            ),

            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFF7931E),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 17,
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 10),

      Text(
        profile.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),

      const SizedBox(height: 20),

      // DATA PROFILE
      Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            _item(
              "Nama",
              profile.name,
              () {
                _editField("Nama", profile.name, (v) {
                  setState(() {
                    viewModel.profile = UserProfileModel(
                      name: v,
                      email: profile.email,
                      phone: profile.phone,
                      avatarUrl: profile.avatarUrl,
                    );
                  });
                });
              },
            ),

            _divider(),

            _item(
              "Email",
              profile.email,
              null,
            ),

            _divider(),

            _item(
              "Telepon",
              profile.phone,
              () {
                _editField("Telepon", profile.phone, (v) {
                  setState(() {
                    viewModel.profile = UserProfileModel(
                      name: profile.name,
                      email: profile.email,
                      phone: v,
                      avatarUrl: profile.avatarUrl,
                    );
                  });
                });
              },
            ),
          ],
        ),
      ),

      // BUTTON SIMPAN
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: viewModel.isSaving
                ? null
                : () async {
                    final success = await viewModel.updateProfile(
                      name: viewModel.profile!.name,
                      phone: viewModel.profile!.phone,
                    );

                    if (!mounted) return;

                    _msg(
                      success
                          ? "Berhasil diperbarui"
                          : "Gagal update data",
                    );

                    if (success) {
                      Navigator.pop(context, true);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF7931E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: viewModel.isSaving
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : const Text(
                    "Simpan Perubahan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    ],
  );
}

  Widget _item(
      String title,
      String value,
      VoidCallback? onTap,
      ){

    return InkWell(
      onTap:onTap,

      child:
      Padding(

        padding:
        const EdgeInsets.symmetric(
          vertical:12,
        ),

        child:
        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  style:
                  const TextStyle(
                    fontSize: 12,
                    color:
                    Colors.grey,
                  ),
                ),

                Text(
                  value,
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),

            if(onTap != null)
              const Icon(
                Icons.edit,
                size:16,
              )
          ],
        ),
      ),
    );
  }

  Widget _divider(){
    return const Divider(
      height:1,
    );
  }

  void _msg(String msg){
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
        Text(msg),
      ),
    );
  }
}