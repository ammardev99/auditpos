import 'package:dio/dio.dart';

class DioClient {
  static final Dio dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(minutes: 1),
        receiveTimeout: const Duration(minutes: 1),
        sendTimeout: const Duration(minutes: 1),

        headers: {"Content-Type": "application/json"},
      ),
    )
    ..interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
}
