import 'dart:convert';
// ignore: deprecated_member_use
import 'dart:html';

import 'package:flutter/material.dart';

class ChatMessage {
  final String message;
  final bool isMe;

  ChatMessage({required this.message, required this.isMe});
}

class WebSocketChatScreen extends StatefulWidget {
  const WebSocketChatScreen({super.key});

  @override
  State<WebSocketChatScreen> createState() => _WebSocketChatScreenState();
}

class _WebSocketChatScreenState extends State<WebSocketChatScreen> {
  final urlController = TextEditingController(text: 'ws://192.168.1.25:8080');

  final messageController = TextEditingController();

  WebSocket? socket;

  final List<ChatMessage> messages = [];

  bool isConnected = false;

  // =========================
  // LOGGER
  // =========================

  void log(String msg) {
    debugPrint(msg);
  }

  // =========================
  // ADD MESSAGE
  // =========================

  void addMessage({required String message, required bool isMe}) {
    setState(() {
      messages.insert(0, ChatMessage(message: message, isMe: isMe));
    });
  }

  // =========================
  // CONNECT
  // =========================

  void connectSocket() {
    try {
      final url = urlController.text.trim();

      debugPrint('================ CONNECT ================');
      debugPrint('URL: $url');

      socket = WebSocket(url);

      socket!.onOpen.listen((event) {
        debugPrint('✅ CONNECTED');

        setState(() {
          isConnected = true;
        });

        addMessage(message: 'Connected to server', isMe: false);
      });

      socket!.onMessage.listen((event) {
        debugPrint('================ RECEIVE ================');
        debugPrint(event.data.toString());

        try {
          final data = jsonDecode(event.data);

          final message = data['message'].toString();

          addMessage(message: message, isMe: false);
        } catch (e) {
          addMessage(message: event.data.toString(), isMe: false);
        }
      });

      socket!.onClose.listen((event) {
        debugPrint('❌ CLOSED');

        setState(() {
          isConnected = false;
        });

        addMessage(message: 'Disconnected', isMe: false);
      });

      socket!.onError.listen((event) {
        debugPrint('⚠ SOCKET ERROR');

        addMessage(message: 'Socket Error', isMe: false);
      });
    } catch (e) {
      debugPrint('❌ CONNECTION FAILED');
      debugPrint(e.toString());

      addMessage(message: e.toString(), isMe: false);
    }
  }

  // =========================
  // SEND
  // =========================

  void sendMessage() {
    if (socket == null) {
      addMessage(message: 'Not connected', isMe: false);
      return;
    }

    final msg = messageController.text.trim();

    if (msg.isEmpty) return;

    debugPrint('================ SEND ================');
    debugPrint(msg);

    socket!.send(msg);

    addMessage(message: msg, isMe: true);

    messageController.clear();
  }

  // =========================
  // REFRESH CHAT
  // =========================

  void clearChat() {
    setState(() {
      messages.clear();
    });

    debugPrint('🧹 CHAT CLEARED');
  }

  // =========================
  // DISCONNECT
  // =========================

  void disconnectSocket() {
    socket?.close();

    setState(() {
      isConnected = false;
    });

    addMessage(message: 'Connection Closed', isMe: false);
  }

  @override
  void dispose() {
    socket?.close();

    urlController.dispose();
    messageController.dispose();

    super.dispose();
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter LAN Chat'),

        actions: [
          IconButton(onPressed: clearChat, icon: const Icon(Icons.refresh)),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'WebSocket URL',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isConnected ? null : connectSocket,
                    child: const Text('Connect'),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: isConnected ? disconnectSocket : null,
                    child: const Text('Disconnect'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (_, i) {
                  final chat = messages[i];

                  return Align(
                    alignment:
                        chat.isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,

                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),

                      padding: const EdgeInsets.all(12),

                      constraints: const BoxConstraints(maxWidth: 300),

                      decoration: BoxDecoration(
                        color: chat.isMe ? Colors.blue : Colors.grey.shade300,

                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Column(
                        crossAxisAlignment:
                            chat.isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,

                        children: [
                          Text(
                            chat.isMe ? 'You' : 'Client',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: chat.isMe ? Colors.white : Colors.black,
                            ),
                          ),

                          const SizedBox(height: 5),

                          SelectableText(
                            chat.message,
                            style: TextStyle(
                              color: chat.isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      border: OutlineInputBorder(),
                    ),

                    onSubmitted: (_) {
                      sendMessage();
                    },
                  ),
                ),

                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: sendMessage,
                  child: const Text('Send'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
