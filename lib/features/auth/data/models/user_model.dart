class UserModel {
  final int id;
  final String firstName;
  final String secondName;
  final String thirdName;
  final String lastName;
  final String gender;
  final String countryCode;
  final String phone;
  final String? email;
  final String role;
  final String status;

  UserModel({
    required this.id,
    required this.firstName,
    required this.secondName,
    required this.thirdName,
    required this.lastName,
    required this.gender,
    required this.countryCode,
    required this.phone,
    this.email,
    required this.role,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      secondName: json['second_name'] ?? '',
      thirdName: json['third_name'] ?? '',
      lastName: json['last_name'] ?? '',
      gender: json['gender'] ?? '',
      countryCode: json['country_code'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      role: json['role'] ?? '',
      status: json['status'] ?? '',
    );
  }
}