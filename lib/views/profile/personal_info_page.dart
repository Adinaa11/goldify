import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {

  String name = "John Doe";
  String email = "johndoe@email.com";
  String phone = "+62 812 xxxx xxxx";

  File? imageFile;

  final ImagePicker _picker = ImagePicker();

  // ================= PICK IMAGE =================
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFF7931E)),
        title: const Text(
          'Informasi Pribadi',
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            // ================= HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [

                  // ✅ FOTO PROFIL (BISA DIKLIK)
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: imageFile != null
                          ? FileImage(imageFile!)
                          : const AssetImage('assets/images/profile.png')
                              as ImageProvider,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "Member sejak 2025",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= DATA =================
            _buildItem(
              icon: Icons.person,
              title: 'Nama Lengkap',
              value: name,
              onTap: () => _showEditDialog("Nama Lengkap", name, (val) {
                setState(() => name = val);
              }),
            ),

            _buildItem(
              icon: Icons.email,
              title: 'Email',
              value: email,
              onTap: () => _showEditDialog("Email", email, (val) {
                setState(() => email = val);
              }, isEmail: true),
            ),

            _buildItem(
              icon: Icons.phone,
              title: 'No. HP',
              value: phone,
              onTap: () => _showEditDialog("No. HP", phone, (val) {
                setState(() => phone = val);
              }, isPhone: true),
            ),

            const SizedBox(height: 20),

            // ================= BUTTON =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _validateAndSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7931E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Simpan Perubahan",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ================= VALIDASI =================
  void _validateAndSave() {
    final emailRegex =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');

    final phoneRegex =
        RegExp(r'^[0-9+]{10,15}$');

    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      _showMessage("Semua data harus diisi", false);
      return;
    }

    if (!emailRegex.hasMatch(email)) {
      _showMessage("Format email tidak valid", false);
      return;
    }

    if (!phoneRegex.hasMatch(phone)) {
      _showMessage("Nomor HP tidak valid", false);
      return;
    }

    _showMessage("Informasi berhasil diperbarui", true);
  }

  // ================= EDIT DIALOG =================
  void _showEditDialog(
    String title,
    String value,
    Function(String) onSave, {
    bool isEmail = false,
    bool isPhone = false,
  }) {
    TextEditingController controller =
        TextEditingController(text: value);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $title"),
        content: TextField(
          controller: controller,
          keyboardType:
              isPhone ? TextInputType.phone : TextInputType.text,
          decoration: InputDecoration(
            hintText: "Masukkan $title",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              String input = controller.text;

              if (isEmail) {
                final emailRegex =
                    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');
                if (!emailRegex.hasMatch(input)) {
                  _showMessage("Email tidak valid", false);
                  return;
                }
              }

              if (isPhone) {
                final phoneRegex =
                    RegExp(r'^[0-9+]{10,15}$');
                if (!phoneRegex.hasMatch(input)) {
                  _showMessage("No HP tidak valid", false);
                  return;
                }
              }

              onSave(input);
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // ================= POPUP =================
  void _showMessage(String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isSuccess ? "Berhasil" : "Gagal"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // ================= ITEM =================
  Widget _buildItem({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFF7931E),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}