import 'package:dio/dio.dart';
import 'package:mobile/config/config.dart';
import 'package:mobile/models/login_response.dart';
import 'package:mobile/models/auth_user.dart';
import 'package:mobile/repository/api/api.dart';
import 'package:logger/logger.dart';

class APIExtend extends API {
  Dio _dio;

  static const String BASE_URL = API_BASE_URL;

  APIExtend() : _dio = Dio();

  @override
  Future<LoginResponse> signIn(AuthUser user) {
    // Mock response
    return Future.delayed(Duration(seconds: 2))
        .then((value) => LoginResponse.just());

    return _dio
        .post(BASE_URL + "/auth/login", data: user.toMap())
        .then((response) => LoginResponse(response.data))
        .catchError((error) {
      Logger().e(error);
    });
  }
}
