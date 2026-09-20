import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final supabase = Supabase.instance.client;

  String name = "";
  String email = "";
  String phone = "";
  String? avatarUrl;

  File? imageFile;
  final ImagePicker _picker = ImagePicker();

  bool isLoading = true;
  bool isSaving = false;

  /// ================= LOAD PROFILE =================
  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      setState(() {
        name = data['name'] ?? '';
        email = data['email'] ?? '';
        phone = data['phone'] ?? '';
        avatarUrl = data['avatar_url'];
        isLoading = false;
      });
    } catch (e) {
      debugPrint("LOAD ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  /// ================= UPLOAD IMAGE =================
  Future<String?> _uploadImage(File file) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final fileName = "${user.id}.jpg";

      await supabase.storage.from('avatars').remove([fileName]);

      await supabase.storage.from('avatars').upload(
        fileName,
        file,
      );

      final publicUrl =
          supabase.storage.from('avatars').getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      debugPrint("UPLOAD ERROR: $e");
      return null;
    }
  }

  /// ================= UPDATE PROFILE =================
  Future<void> _updateProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    setState(() => isSaving = true);

    try {
      String? uploadedUrl = avatarUrl;

      /// upload foto jika ada
      if (imageFile != null) {
        final result = await _uploadImage(imageFile!);

        if (result == null) {
          _msg("Upload foto gagal");
          setState(() => isSaving = false);
          return;
        }

        uploadedUrl = result;
      }

      debugPrint("FINAL AVATAR URL: $uploadedUrl");

      final response = await supabase
          .from('profiles')
          .update({
            'name': name,
            'phone': phone,
            'avatar_url': uploadedUrl,
          })
          .eq('id', user.id)
          .select();

      debugPrint("UPDATE RESULT: $response");

      if (!mounted) return;

      _msg("Berhasil diperbarui");

      Navigator.pop(context, true);

    } catch (e) {
      debugPrint("ERROR UPDATE: $e");
      _msg("Gagal update data");
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  /// ================= PICK IMAGE =================
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  /// ================= EDIT FIELD =================
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
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Text(
                  "Edit $title",
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: "Masukkan $title",
                    filled: true,
                    fillColor: const Color(0xFFF5F6F8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text("Batal",
                            style: TextStyle(color: Colors.red)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final input = controller.text.trim();

                          if (input.isEmpty) {
                            _msg("Tidak boleh kosong");
                            return;
                          }

                          onSave(input);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFF7931E),
                        ),
                        child: const Text(
                          "Simpan",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _msg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text("Informasi Pribadi"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 20),

                /// FOTO
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage: imageFile != null
                        ? FileImage(imageFile!)
                        : (avatarUrl != null &&
                                avatarUrl!.isNotEmpty)
                            ? NetworkImage(avatarUrl!)
                            : const AssetImage(
                                    'assets/images/profile.png')
                                as ImageProvider,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 20),

                /// CARD
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _item("Nama", name,
                          () => _editField("Nama", name,
                              (v) => setState(() => name = v))),
                      _divider(),
                      _item("Email", email, null),
                      _divider(),
                      _item("Telepon", phone,
                          () => _editField("Telepon", phone,
                              (v) => setState(() => phone = v))),
                    ],
                  ),
                ),

                /// BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFF7931E),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      child: isSaving
                          ? const CircularProgressIndicator(
                              color: Colors.white)
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
                )
              ],
            ),
    );
  }

  Widget _item(String title, String value, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey)),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600)),
              ],
            ),
            if (onTap != null)
              const Icon(Icons.edit, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _divider() =>
      const Divider(height: 1);
}