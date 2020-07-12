import 'package:mobile/config/config.dart';
import 'package:mobile/models/user.dart';

class LoginResponse {
  User user;
  String token;

  LoginResponse(dynamic json) {
    this.user = User.fromJson(json['data']['user']);
    this.token = json['token'];
  }

  // Mock response
  LoginResponse.just() {
    this.user = User(USER_ID, USER_NAME, USER_PHONE_NUMBER);
    this.token = MOCK_TOKEN;
  }
}
