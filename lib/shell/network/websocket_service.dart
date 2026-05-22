import 'dart:async';
import 'dart:convert';

import 'package:auditpos/shell/network/app_constants.dart';
import 'package:auditpos/shell/network/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketService._();

  static final WebSocketService instance = WebSocketService._();

  WebSocketChannel? _channel;

  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier(false);

  bool _manuallyDisconnected = false;
  bool _isConnecting = false;

  Timer? _reconnectTimer;

  /// BACKWARD COMPATIBLE SINGLE LISTENER
  Function(dynamic)? onMessage;

  bool get isConnected => _channel != null;

  /// CONNECT
  Future<void> connect() async {
    if (_isConnecting || _channel != null) {
      debugPrint("WS ALREADY CONNECTED / CONNECTING");
      return;
    }

    _isConnecting = true;
    _manuallyDisconnected = false;

    try {
      final token = await StorageService.getToken();

      if (token == null || token.isEmpty) {
        debugPrint("WS TOKEN NOT FOUND");
        _isConnecting = false;
        return;
      }

      final url = "${AppConstants.wsUrl}?token=$token";

      debugPrint("WS CONNECTING => $url");

      _channel = WebSocketChannel.connect(Uri.parse(url));

      _channel!.stream.listen(
        (event) {
          debugPrint("WS RAW => $event");

          /// SAFE GUARDS
          if (event == null) return;

          final raw = event.toString().trim();

          if (raw.isEmpty) return;

          try {
            final decoded = jsonDecode(raw);

            if (onMessage != null) {
              onMessage!(decoded);
            }
          } catch (e) {
            debugPrint("WS JSON ERROR => $e");
            debugPrint("RAW INVALID => $raw");
          }
        },

        onDone: () {
          debugPrint("WS DISCONNECTED");

          _cleanup();

          if (!_manuallyDisconnected) {
            _scheduleReconnect();
          }
        },

        onError: (e) {
          debugPrint("WS ERROR => $e");

          _cleanup();

          if (!_manuallyDisconnected) {
            _scheduleReconnect();
          }
        },

        cancelOnError: true,
      );

      debugPrint("WS CONNECTED");

      isConnectedNotifier.value = true;
    } catch (e) {
      debugPrint("WS CONNECT FAILED => $e");

      _cleanup();

      if (!_manuallyDisconnected) {
        _scheduleReconnect();
      }
    }

    _isConnecting = false;
  }

  /// SEND MESSAGE
  void send(Map<String, dynamic> data) {
    if (_channel == null) {
      debugPrint("WS NOT CONNECTED");
      return;
    }

    try {
      final msg = jsonEncode(data);

      debugPrint("WS SEND => $msg");

      _channel?.sink.add(msg);
    } catch (e) {
      debugPrint("WS SEND ERROR => $e");
    }
  }

  /// MANUAL DISCONNECT
  void disconnect() {
    debugPrint("WS MANUAL DISCONNECT");

    _manuallyDisconnected = true;

    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _channel?.sink.close();

    _cleanup();
  }

  /// CLEANUP
  void _cleanup() {
    _channel = null;
    _isConnecting = false;

    isConnectedNotifier.value = false;
  }

  /// AUTO RECONNECT
  void _scheduleReconnect() {
    /// FIX: correct null + active check
    if (_reconnectTimer?.isActive == true) {
      return;
    }

    debugPrint("WS RECONNECT IN 5 SEC");

    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      connect();
    });
  }
}
