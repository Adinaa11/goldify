import '../main.dart';

class AppText {

  static bool get isID => appLocale.value.languageCode == 'id';

  static String get profile => isID ? "Profil" : "Profile";

  static String get personalInfo =>
      isID ? "Informasi Pribadi" : "Personal Information";

  static String get security =>
      isID ? "Keamanan" : "Security";

  static String get notification =>
      isID ? "Notifikasi" : "Notifications";

  static String get language =>
      isID ? "Bahasa" : "Language";

  static String get logout =>
      isID ? "Keluar Akun" : "Logout";

  static String get account =>
      isID ? "PENGATURAN AKUN" : "ACCOUNT SETTINGS";

  static String get appInfo =>
      isID ? "INFORMASI APLIKASI" : "APP INFO";


  /// TAMBAHAN (BIAR HOME GA ERROR)
  static String get home => isID ? "Beranda" : "Home";
  static String get calculator => isID ? "Kalkulator" : "Calculator";
  static String get history => isID ? "Riwayat" : "History";

  static String get welcome => isID ? "Selamat Datang" : "Welcome";
  static String get mainFeatures => isID ? "Fitur Utama" : "Main Features";
}