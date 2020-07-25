import 'package:mobile/models/auth_user.dart';
import 'package:mobile/models/login_response.dart';

abstract class API {
  Future<LoginResponse> signIn(AuthUser user);
}
