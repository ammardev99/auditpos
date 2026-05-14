// FILE: lib/shell/products/data/p_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../../../shell/network/websocket_service.dart';
import 'product_model.dart';

final productProvider =
    StateNotifierProvider<ProductNotifier, ProductState>(
  (ref) => ProductNotifier(),
);

class ProductState {
  final bool loading;
  final List<ProductModel> data;
  final String? error;

  ProductState({
    this.loading = false,
    this.data = const [],
    this.error,
  });

  ProductState copyWith({
    bool? loading,
    List<ProductModel>? data,
    String? error,
  }) {
    return ProductState(
      loading: loading ?? this.loading,
      data: data ?? this.data,
      error: error,
    );
  }
}

class ProductNotifier extends StateNotifier<ProductState> {
  ProductNotifier() : super(ProductState()) {
    _listenWS();
  }

  /// FILE: p_provider.dart
  /// LISTEN ALL WS MESSAGES HERE
  void _listenWS() {
    WebSocketService.instance.onMessage = (data) {
      debugPrint("PRODUCT WS MESSAGE => $data");

      // case: get_products response
      if (data['action'] == 'get_products' ||
          data['type'] == 'products') {

        final List list = data['data'];

        final products =
            list.map((e) => ProductModel.fromJson(e)).toList();

        state = state.copyWith(
          loading: false,
          data: products,
        );

        debugPrint("PRODUCTS UPDATED => ${products.length}");
      }
    };
  }

  /// FILE: p_provider.dart
  /// TRIGGER REQUEST VIA WEBSOCKET
  void getProducts() {
    debugPrint("\n================ PRODUCT WS REQUEST ================");
    debugPrint("ACTION => get_products");
    debugPrint("====================================================");

    state = state.copyWith(loading: true, error: null);

    WebSocketService.instance.send({
      "action": "get_products",
      "payload": {}
    });
  }
}