class Applicant {
  final int? id;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? country;
  final String? experience;
  final String? skills;
  final String? passportNumber;

  final String? cvFileName;
  final String? cvUrl;
  final DateTime? cvUploadedAt;

  Applicant({
    this.id,
    this.fullName,
    this.email,
    this.phone,
    this.country,
    this.experience,
    this.skills,
    this.passportNumber,
    this.cvFileName,
    this.cvUrl,
    this.cvUploadedAt,
  });


  factory Applicant.fromJson(Map<String, dynamic> json) {

    return Applicant(

      id: json['id'],

      fullName: json['fullName'],

      email: json['email'],

      phone: json['phone'],

      country: json['country'],

      experience: json['experience'],

      skills: json['skills'],

      passportNumber: json['passportNumber'],


      cvFileName: json['cvFileName'],

      cvUrl: json['cvUrl'],

      cvUploadedAt: json['cvUploadedAt'] != null
          ? DateTime.parse(json['cvUploadedAt'])
          : null,

    );

  }
}