import 'package:mobile/models/auth_user.dart';
import 'package:mobile/models/login_response.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/repository/api/api.dart';
import 'package:mobile/repository/api/api_extend.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Repository {
  API _api;

  String accessToken;

  // Server calls
  Future<LoginResponse> signIn(AuthUser user) {
    return _api.signIn(user).then((response) => _storeAccessToken(response));
  }

  Future<bool> signOut() {
    return SharedPreferences.getInstance().then((pref) => pref.clear());
  }

  // Save token in shared prefs
  LoginResponse _storeAccessToken(LoginResponse response) {
    if (response != null && response.token != null) {
      this.accessToken = response.token;
      SharedPreferences.getInstance().then((pref) {
        pref.setString("token", response.token);
        pref.setString("user_id", response.user.id);
        pref.setString("user_name", response.user.name);
        pref.setString("user_phone", response.user.phoneNumber);
      });
      return response;
    } else {
      return LoginResponse.just();
    }
  }

  // Check for active session
  Future<bool> checkToken() {
    return SharedPreferences.getInstance().then((pref) {
      String token = pref.getString("token");
      if (token != null) {
        this.accessToken = token;
        return true;
      } else {
        return false;
      }
    });
  }

  // Load local session data
  Future<User> loadLocalUser() {
    return SharedPreferences.getInstance().then((pref) {
      String id = pref.getString("user_id");
      String name = pref.getString("user_name");
      String phoneNumber = pref.getString("user_phone");
      return User(id, name, phoneNumber);
    });
  }

  // Singleton
  static final Repository _repository = Repository._internal();

  factory Repository() {
    return _repository;
  }

  Repository._internal() : _api = APIExtend();
}
