import 'package:mobile/models/auth_user.dart';
import 'package:mobile/models/elector.dart';
import 'package:mobile/models/info.dart';
import 'package:mobile/repository/dto/login_response.dart';

abstract class API {
  Future<LoginResponse> signIn(AuthUser user);

  Future<List<Info>> fetchMeta(String token, String election);
  Future<List<Elector>> fetcElectors(String token, String election,
      String district, String division, String station);
}
