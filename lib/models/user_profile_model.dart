class UserProfileModel {

  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;

  UserProfileModel({
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
  });

  factory UserProfileModel.fromJson(
      Map<String, dynamic> json) {
    return UserProfileModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'phone': phone,
      'avatar_url': avatarUrl,
    };
  }
}