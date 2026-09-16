import 'package:flutter/material.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String selectedLanguage = "Indonesia";

  void _changeLanguage(String lang) {
    setState(() {
      selectedLanguage = lang;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          lang == "Indonesia"
              ? "Bahasa diubah ke Indonesia"
              : "Language changed to English",
        ),
        duration: const Duration(seconds: 1),
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) Navigator.pop(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFFF7931E)),
        title: Text(
          selectedLanguage == "Indonesia" ? "Bahasa" : "Language",
          style: const TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 20),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _item("Indonesia"),
                const Divider(height: 1),
                _item("English"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(String lang) {
    final isSelected = selectedLanguage == lang;

    return InkWell(
      onTap: () => _changeLanguage(lang),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              lang,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFF7931E)
                      : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: CircleAvatar(
                        radius: 5,
                        backgroundColor: Color(0xFFF7931E),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}