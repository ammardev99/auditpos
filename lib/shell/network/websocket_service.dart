import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketService._();
  static final WebSocketService instance = WebSocketService._();

  WebSocketChannel? _channel;
  String? _token;

  Function(dynamic)? onMessage;

  void connect(String token) {
    _token = token;

    final url = "ws://192.168.1.11:8080?token=$token";

    debugPrint("WS CONNECTING => $url");

    _channel = WebSocketChannel.connect(Uri.parse(url));

    _channel!.stream.listen(
      (event) {
        debugPrint("WS MESSAGE => $event");

        if (onMessage != null) {
          onMessage!(jsonDecode(event));
        }
      },
      onDone: () {
        debugPrint("WS DISCONNECTED");
        _channel = null;
      },
      onError: (e) {
        debugPrint("WS ERROR => $e");
      },
    );

    debugPrint("WS CONNECTED");
  }

  void send(Map<String, dynamic> data) {
    final msg = jsonEncode(data);

    debugPrint("WS SEND => $msg");

    _channel?.sink.add(msg);
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _token = null;
  }
}
