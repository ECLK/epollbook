import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class AuthService {
  static final AuthService _authService = AuthService._internal();

  factory AuthService() {
    return _authService;
  }

  AuthService._internal();

  Future<bool> signIn() {
    return SharedPreferences.getInstance().then((instance) {
      return instance
          .setString('token', 'token')
          .then((success) => true)
          .catchError((error) => false);
    });
  }

  Future<bool> signOut() {
    return SharedPreferences.getInstance().then((instance) {
      return instance
          .setString('token', null)
          .then((success) => true)
          .catchError((error) => false);
    });
  }

  Future<bool> isSignedIn() {
    return SharedPreferences.getInstance()
        .then(
            (instance) => (instance.getString('token') != null) ? true : false)
        .catchError((error) => Logger().e(error));
  }
}
