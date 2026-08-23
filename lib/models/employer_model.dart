class EmployerModel {
  final int id;
  final EmployerUser user;
  final String companyName;
  final String? contactPerson;
  final String email;
  final String phone;
  final String? country;
  final String? address;
  final String? registrationNumber;
  final String? description;
  final String status;
  final DateTime? createdAt;

  EmployerModel({
    required this.id,
    required this.user,
    required this.companyName,
    this.contactPerson,
    required this.email,
    required this.phone,
    this.country,
    this.address,
    this.registrationNumber,
    this.description,
    required this.status,
    this.createdAt,
  });

  factory EmployerModel.fromJson(Map<String, dynamic> json) {
    return EmployerModel(
      id: json['id'] ?? 0,

      user: EmployerUser.fromJson(
        json['user'] ?? {},
      ),

      companyName: json['companyName'] ?? '',

      contactPerson: json['contactPerson'],

      email: json['email'] ?? '',

      phone: json['phone'] ?? '',

      country: json['country'],

      address: json['address'],

      registrationNumber:
      json['registrationNumber'],

      description:
      json['description'],

      status: json['status'] ?? 'PENDING',

      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(
        json['createdAt'].toString(),
      )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'companyName': companyName,
      'contactPerson': contactPerson,
      'email': email,
      'phone': phone,
      'country': country,
      'address': address,
      'registrationNumber': registrationNumber,
      'description': description,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  bool get isApproved => status == 'APPROVED';

  bool get isPending => status == 'PENDING';

  bool get isRejected => status == 'REJECTED';
}


// =========================================================
// EMPLOYER USER
// =========================================================

class EmployerUser {
  final int id;
  final String username;
  final String role;

  EmployerUser({
    required this.id,
    required this.username,
    required this.role,
  });

  factory EmployerUser.fromJson(Map<String, dynamic> json) {
    return EmployerUser(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
    };
  }
}