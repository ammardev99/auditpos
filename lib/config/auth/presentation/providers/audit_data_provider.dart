// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:auditpos/core/network/websocket_service.dart';

// // WebSocket provider
// final wsProvider = Provider<WebSocketService>((ref) {
//   return WebSocketService();
// });

// // Product Notifier (NEW STYLE)
// final productProvider =
//     NotifierProvider<ProductNotifier, List<dynamic>>(ProductNotifier.new);

// class ProductNotifier extends Notifier<List<dynamic>> {
//   late final WebSocketService ws;

//   @override
//   List<dynamic> build() {
//     ws = ref.read(wsProvider);
//     return [];
//   }

//   void getProducts() {
//     ws.send({"action": "get_products", "payload": {}});
//   }

//   void setProducts(List<dynamic> data) {
//     state = data;
//   }
// }