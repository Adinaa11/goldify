import 'package:flutter/material.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  final TextEditingController searchController = TextEditingController();

  String selectedLanguage = "Indonesia";

  List<String> allLanguages = [
    "Indonesia",
    "English",
    "Arabic",
    "Japanese",
    "Korean",
    "Chinese",
    "French",
    "German",
    "Spanish",
    "Russian",
    "Hindi",
    "Thai",
  ];

  List<String> filteredLanguages = [];

  @override
  void initState() {
    super.initState();
    filteredLanguages = allLanguages;
  }

  void _filterLanguage(String query) {
    setState(() {
      filteredLanguages = allLanguages
          .where((lang) =>
              lang.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _saveLanguage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Bahasa $selectedLanguage berhasil disimpan"),
        backgroundColor: Colors.green,
      ),
    );
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
          "Bahasa",
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [

          // ================= SEARCH =================
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: _filterLanguage,
              decoration: InputDecoration(
                hintText: "Cari bahasa...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ================= LIST =================
          Expanded(
            child: ListView.builder(
              itemCount: filteredLanguages.length,
              itemBuilder: (context, index) {
                String lang = filteredLanguages[index];

                return RadioListTile(
                  title: Text(lang),
                  value: lang,
                  groupValue: selectedLanguage,
                  activeColor: const Color(0xFFF7931E),
                  onChanged: (value) {
                    setState(() {
                      selectedLanguage = value.toString();
                    });
                  },
                );
              },
            ),
          ),

          // ================= BUTTON =================
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveLanguage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF7931E),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Simpan Bahasa",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}