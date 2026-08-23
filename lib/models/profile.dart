class Profile {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String country;
  final String experience;
  final String skills;
  final String passportNumber;
  final String cvFileName;
  final String cvUrl;

  Profile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.country,
    required this.experience,
    required this.skills,
    required this.passportNumber,
    required this.cvFileName,
    required this.cvUrl,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json["id"] ?? 0,
      fullName: json["fullName"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      country: json["country"] ?? "",
      experience: json["experience"] ?? "",
      skills: json["skills"] ?? "",
      passportNumber: json["passportNumber"] ?? "",
      cvFileName: json["cvFileName"] ?? "",
      cvUrl: json["cvUrl"] ?? "",
    );
  }
}