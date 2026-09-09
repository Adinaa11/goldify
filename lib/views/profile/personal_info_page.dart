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
  String phone = "+6281234567890";
  String birthDate = "01 Januari 1990";
  String gender = "Laki-laki";

  File? imageFile;
  final ImagePicker _picker = ImagePicker();

  /// ================= FORMAT PHONE =================
  String _formatPhone(String input) {
    String cleaned = input.replaceAll(RegExp(r'\s+'), '');

    if (cleaned.startsWith('08')) {
      return '+62${cleaned.substring(1)}';
    } else if (cleaned.startsWith('62')) {
      return '+$cleaned';
    }
    return cleaned;
  }

  /// ================= IMAGE =================
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

  /// ================= DATE =================
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        birthDate =
            "${picked.day} ${_monthName(picked.month)} ${picked.year}";
      });
    }
  }

  String _monthName(int month) {
    const months = [
      "Januari","Februari","Maret","April","Mei","Juni",
      "Juli","Agustus","September","Oktober","November","Desember"
    ];
    return months[month - 1];
  }

  /// ================= GENDER =================
  void _pickGender() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
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
              const Text("Pilih Jenis Kelamin",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ListTile(
                title: const Text("Laki-laki"),
                onTap: () {
                  setState(() => gender = "Laki-laki");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Perempuan"),
                onTap: () {
                  setState(() => gender = "Perempuan");
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// ================= EDIT FIELD =================
  void _editField(
    String title,
    String value,
    Function(String) onSave, {
    bool isEmail = false,
    bool isPhone = false,
  }) {
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// HANDLE
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                /// TITLE
                Text(
                  "Edit $title",
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                /// INPUT
                TextField(
                  controller: controller,
                  keyboardType:
                      isPhone ? TextInputType.phone : TextInputType.text,
                  onChanged: isPhone
                      ? (value) {
                          final formatted = _formatPhone(value);
                          if (formatted != value) {
                            controller.value = TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(
                                  offset: formatted.length),
                            );
                          }
                        }
                      : null,
                  decoration: InputDecoration(
                    hintText: isPhone
                        ? "Contoh: 081234567890"
                        : "Masukkan $title",
                    filled: true,
                    fillColor: const Color(0xFFF5F6F8),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                /// BUTTONS FIXED
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          "Batal",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

                          if (isEmail &&
                              !RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$')
                                  .hasMatch(input)) {
                            _msg("Email tidak valid");
                            return;
                          }

                          if (isPhone &&
                              !RegExp(r'^(?:\+62|08)[0-9]{8,11}$')
                                  .hasMatch(input)) {
                            _msg("Gunakan format 08xxxx atau +628xxxx");
                            return;
                          }

                          onSave(input);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF7931E),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: const Text(
                          "Simpan",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
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

  /// ================= SAVE =================
  void _save() {
    Navigator.pop(context, {
      "name": name,
      "email": email,
      "phone": phone,
      "image": imageFile,
    });
  }

  void _msg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
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
        elevation: 1,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// HEADER
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: imageFile != null
                              ? FileImage(imageFile!)
                              : const AssetImage(
                                      'assets/images/profile.png')
                                  as ImageProvider,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF7931E),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 14, color: Colors.white),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text("Tap foto untuk mengubah",
                      style:
                          TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),

            /// DATA CARD
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _item("Nama Lengkap", name,
                      () => _editField("Nama", name, (v) => setState(() => name = v))),
                  _divider(),
                  _item("Email", email,
                      () => _editField("Email", email, (v) => setState(() => email = v), isEmail: true)),
                  _divider(),
                  _item("Nomor Telepon", phone,
                      () => _editField("Telepon", phone, (v) => setState(() => phone = v), isPhone: true)),
                  _divider(),
                  _item("Tanggal Lahir", birthDate, _pickDate),
                  _divider(),
                  _item("Jenis Kelamin", gender, _pickGender),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// SAVE BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7931E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    "SIMPAN PERUBAHAN",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
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

  Widget _item(String title, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600)),
              ],
            ),
            const Icon(Icons.edit, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1);
}