import 'package:dio/dio.dart';

class AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSource(this.dio);

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await dio.post(
      "http://192.168.1.25/fcc_pos_php/php_mart/api_login.php",
      data: {
        "username": username,
        "password": password,
      },
    );

    return response.data;
  }
}