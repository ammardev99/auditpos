// ignore_for_file: avoid_print

import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = NotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = true;

    try {
      await Future.delayed(const Duration(seconds: 2));

      print("Login Success");
    } catch (e) {
      print(e);
    } finally {
      state = false;
    }
  }
}
