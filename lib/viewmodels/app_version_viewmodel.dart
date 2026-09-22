import '../models/app_version_model.dart';

class AppVersionViewModel {

  AppVersionModel get appVersion {

    return AppVersionModel(
      appName: "Goldify",
      description:
          "Aplikasi digital yang membantu pengguna "
          "melakukan perhitungan dan analisis terkait "
          "emas secara mudah dan efisien.",
    );
  }
}