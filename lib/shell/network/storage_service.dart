import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // ---------------- TOKEN ----------------
  static Future<void> saveToken(String token) async {
    await _storage.write(key: "token", value: token);
  }

  static Future<String?> getToken() async {
    return _storage.read(key: "token");
  }

  // ---------------- USER ----------------
  static Future<void> saveUser({
    required String name,
    required String email,
    String? userId,
  }) async {
    await _storage.write(key: "user_name", value: name);
    await _storage.write(key: "user_email", value: email);

    if (userId != null) {
      await _storage.write(key: "user_id", value: userId);
    }
  }

  static Future<String?> getUserName() {
    return _storage.read(key: "user_name");
  }

  static Future<String?> getUserEmail() {
    return _storage.read(key: "user_email");
  }

  static Future<String?> getUserId() {
    return _storage.read(key: "user_id");
  }

  // ---------------- CLEAR ----------------
  static Future<void> clear() async {
    return _storage.deleteAll();
  }
}
