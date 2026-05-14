import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';

class ProductWSService {
  WebSocketChannel? _channel;

  void attach(WebSocketChannel channel) {
    _channel = channel;
  }

  void getProducts() {
    if (_channel == null) {
      debugPrint("WS NOT CONNECTED");
      return;
    }

    final request = {
      "action": "get_products",
      "payload": {}
    };

    debugPrint("WS SEND => $request");

    _channel!.sink.add(jsonEncode(request));
  }
}