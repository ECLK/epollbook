class AuthUser {
  String phoneNumber;
  String password;

  AuthUser({this.phoneNumber, this.password});

  Map<String, dynamic> toMap() {
    return {
      "phone_number": phoneNumber,
      "password": password,
    };
  }
}
