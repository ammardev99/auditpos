import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: "token", value: token);
  }

  static Future<String?> getToken() async {
    return _storage.read(key: "token");
  }

  static Future<void> clear() async {
    return _storage.deleteAll();
  }
}