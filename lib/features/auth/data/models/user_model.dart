class UserModel {
  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final String phone;
  final String role;

  const UserModel({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.role,
  });

  String get fullName => '$firstname $lastname';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      firstname: json['firstname'] as String? ?? '',
      lastname: json['lastname'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',

      // register response has no `role` — default to customer
      role: json['role'] as String? ?? 'customer',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstname': firstname,
    'lastname': lastname,
    'email': email,
    'phone': phone,
    'role': role,
  };
}
