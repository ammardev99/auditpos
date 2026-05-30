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

  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier(false);

  Function(dynamic)? onMessage;

  bool _isConnecting = false;
  bool _manuallyDisconnected = false;

  Timer? _reconnectTimer;

  bool get isConnected => isConnectedNotifier.value;

  Future<void> connect({String? token}) async {
    if (_isConnecting) {
      debugPrint("WS ALREADY CONNECTING");
      return;
    }

    if (isConnected) {
      debugPrint("WS ALREADY CONNECTED");
      return;
    }

    _isConnecting = true;
    _manuallyDisconnected = false;

    try {
      final finalToken = token ?? await StorageService.getToken();

      if (finalToken == null || finalToken.isEmpty) {
        debugPrint("WS TOKEN NOT FOUND");

        _isConnecting = false;

        return;
      }

      final url = "${AppConstants.wsUrl}?token=$finalToken";

      debugPrint("WS CONNECTING => $url");

      final channel = WebSocketChannel.connect(Uri.parse(url));

      _channel = channel;

      await channel.ready;

      debugPrint("WS CONNECTED");

      isConnectedNotifier.value = true;

      _isConnecting = false;

      _reconnectTimer?.cancel();

      channel.stream.listen(
        (event) {
          if (event == null) return;

          final raw = event.toString().trim();

          if (raw.isEmpty) return;

          debugPrint("WS RAW => $raw");

          try {
            final decoded = jsonDecode(raw);

            if (decoded is Map<String, dynamic>) {
              _messageController.add(decoded);
            }

            onMessage?.call(decoded);
          } catch (e) {
            debugPrint("WS JSON ERROR => $e");
          }
        },

        onDone: () {
          debugPrint("WS CLOSED");

          _handleDisconnect();
        },

        onError: (e) {
          debugPrint("WS ERROR => $e");

          _handleDisconnect();
        },

        cancelOnError: true,
      );
    } catch (e) {
      debugPrint("WS CONNECT FAILED => $e");

      _handleDisconnect();
    }
  }

  void send(Map<String, dynamic> data) {
    if (!isConnected || _channel == null) {
      debugPrint("WS NOT CONNECTED");
      return;
    }

    try {
      final encoded = jsonEncode(data);

      debugPrint("WS SEND => $encoded");

      _channel!.sink.add(encoded);
    } catch (e) {
      debugPrint("WS SEND ERROR => $e");
    }
  }

  void disconnect() {
    debugPrint("WS MANUAL DISCONNECT");

    _manuallyDisconnected = true;

    _reconnectTimer?.cancel();

    _channel?.sink.close();

    _cleanup();
  }

  void _handleDisconnect() {
    _cleanup();

    if (!_manuallyDisconnected) {
      _scheduleReconnect();
    }
  }

  void _cleanup() {
    _channel = null;

    _isConnecting = false;

    isConnectedNotifier.value = false;
  }

  void _scheduleReconnect() {
    if (_reconnectTimer?.isActive == true) {
      return;
    }

    debugPrint("WS RECONNECT IN 5 SEC");

    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      connect();
    });
  }
}

// import 'dart:async';
// import 'dart:convert';

// import 'package:auditpos/shell/network/app_constants.dart';
// import 'package:auditpos/shell/network/storage_service.dart';
// import 'package:flutter/foundation.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

// class WebSocketService {
//   WebSocketService._();

//   static final WebSocketService instance = WebSocketService._();

//   WebSocketChannel? _channel;
//   // --- ADD THIS BLOCK FOR BULLETPROOF STREAM BROADCASTING ---
//   final StreamController<Map<String, dynamic>> _messageController =
//       StreamController<Map<String, dynamic>>.broadcast();
//   Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
//   // ---------------------------------------------------------

//   final ValueNotifier<bool> isConnectedNotifier = ValueNotifier(false);

//   bool _manuallyDisconnected = false;
//   bool _isConnecting = false;

//   Timer? _reconnectTimer;

//   /// BACKWARD COMPATIBLE SINGLE LISTENER
//   Function(dynamic)? onMessage;

//   bool get isConnected => _channel != null;

//   /// CONNECT
//   Future<void> connect({String? token}) async {
//     if (_isConnecting || _channel != null) {
//       debugPrint("WS ALREADY CONNECTED / CONNECTING");
//       return;
//     }

//     _isConnecting = true;
//     _manuallyDisconnected = false;

//     try {
//       final finalToken = token ?? await StorageService.getToken();

//       if (finalToken == null || finalToken.isEmpty) {
//         debugPrint("WS TOKEN NOT FOUND");
//         _isConnecting = false;
//         return;
//       }

//       final url = "${AppConstants.wsUrl}?token=$finalToken";

//       debugPrint("WS CONNECTING => $url");

//       _channel = WebSocketChannel.connect(Uri.parse(url));

//       _channel!.ready
//           .then((_) {
//             debugPrint("WS CONNECTED");
//             isConnectedNotifier.value = true;
//           })
//           .catchError((e) {
//             debugPrint("WS HANDSHAKE FAILED => $e");

//             _cleanup();

//             if (!_manuallyDisconnected) {
//               _scheduleReconnect();
//             }
//           });

//       _channel!.stream.listen(
//         (event) {
//           debugPrint("WS RAW => $event");

//           if (event == null) return;

//           final raw = event.toString().trim();
//           if (raw.isEmpty) return;

//           try {
//             final decoded = jsonDecode(raw);

//             if (decoded is Map<String, dynamic>) {
//               _messageController.add(decoded);
//             }

//             if (onMessage != null) {
//               onMessage!(decoded);
//             }
//           } catch (e) {
//             debugPrint("WS JSON ERROR => $e");
//             debugPrint("RAW INVALID => $raw");
//           }
//         },
//         onDone: () {
//           debugPrint("WS DISCONNECTED");
//           _cleanup();

//           if (!_manuallyDisconnected) {
//             _scheduleReconnect();
//           }
//         },
//         onError: (e) {
//           debugPrint("WS ERROR => $e");
//           _cleanup();

//           if (!_manuallyDisconnected) {
//             _scheduleReconnect();
//           }
//         },
//         cancelOnError: true,
//       );

//       debugPrint("WS CONNECTED");
//       isConnectedNotifier.value = true;
//     } catch (e) {
//       debugPrint("WS CONNECT FAILED => $e");
//       _cleanup();

//       if (!_manuallyDisconnected) {
//         _scheduleReconnect();
//       }
//     }

//     _isConnecting = false;
//   }

//   /// SEND MESSAGE
//   void send(Map<String, dynamic> data) {
//     if (_channel == null) {
//       debugPrint("WS NOT CONNECTED");
//       return;
//     }

//     try {
//       final msg = jsonEncode(data);

//       debugPrint("WS SEND => $msg");

//       _channel?.sink.add(msg);
//     } catch (e) {
//       debugPrint("WS SEND ERROR => $e");
//     }
//   }

//   /// MANUAL DISCONNECT
//   void disconnect() {
//     debugPrint("WS MANUAL DISCONNECT");

//     _manuallyDisconnected = true;

//     _reconnectTimer?.cancel();
//     _reconnectTimer = null;

//     _channel?.sink.close();

//     _cleanup();
//   }

//   /// CLEANUP
//   void _cleanup() {
//     _channel = null;
//     _isConnecting = false;

//     isConnectedNotifier.value = false;
//   }

//   /// AUTO RECONNECT
//   void _scheduleReconnect() {
//     /// FIX: correct null + active check
//     if (_reconnectTimer?.isActive == true) {
//       return;
//     }

//     debugPrint("WS RECONNECT IN 5 SEC");

//     _reconnectTimer = Timer(const Duration(seconds: 5), () {
//       connect();
//     });
//   }
// }
