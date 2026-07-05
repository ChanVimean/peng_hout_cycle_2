class RegisterRequest {
  final String firstname;
  final String lastname;
  final String email;
  final String phone;
  final String password;
  final String passwordConfirmation;

  const RegisterRequest({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() => {
    'firstname': firstname,
    'lastname': lastname,
    'email': email,
    'phone': phone,
    'password': password,
    'password_confirmation': passwordConfirmation,
  };
}