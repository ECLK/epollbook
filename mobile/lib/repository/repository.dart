import 'package:mobile/models/auth_user.dart';
import 'package:mobile/models/elector.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/models/info.dart';
import 'package:mobile/repository/api/api.dart';
import 'package:mobile/repository/api/api_extend.dart';
import 'package:mobile/repository/dto/instance_data.dart';
import 'package:mobile/repository/dto/login_response.dart';
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

  Future<List<Info>> fetchMeta(String election) {
    return _api.fetchMeta(accessToken, election);
  }

  Future<List<Elector>> fetchElectors(
      String election, String district, String division, String station) {
    return _api.fetchElectors(
        accessToken, election, district, division, station);
  }

  Future<List<String>> fetchInQueue(
      String election, String district, String division, String station) {
    return _api.fetchInQueue(
        accessToken, election, district, division, station);
  }

  Future<bool> updateToQueued(String election, String district, String division,
      String station, String voterId, DateTime timestamp) {
    return _api.updateToQueued(
        accessToken, election, district, division, station, voterId, timestamp);
  }

  Future<bool> updateToVoted(String election, String district, String division,
      String station, String voterId, DateTime timestamp) {
    return _api.updateToVoted(
        accessToken, election, district, division, station, voterId, timestamp);
  }

  void saveInstanceData(
      String election, String district, String division, String station) {
    SharedPreferences.getInstance().then((pref) {
      pref.setString("election", election);
      pref.setString("district", district);
      pref.setString("division", division);
      pref.setString("station", station);
    });
  }

  Future<bool> checkInstanceData() {
    return SharedPreferences.getInstance().then((pref) {
      String division = pref.getString("division");
      String station = pref.getString("station");

      return (division != null && station != null);
    });
  }

  Future<InstanceData> loadInstanceData() {
    return SharedPreferences.getInstance().then((pref) {
      String division = pref.getString("division");
      String station = pref.getString("station");

      return InstanceData(division, station);
    });
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
