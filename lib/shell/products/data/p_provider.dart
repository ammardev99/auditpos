// FILE: lib/shell/products/data/p_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../../../shell/network/websocket_service.dart';
import 'product_model.dart';

final productProvider = StateNotifierProvider<ProductNotifier, ProductState>(
  (ref) => ProductNotifier(),
);

class ProductState {
  final bool loading;

  final List<ProductModel> data;

  final List<ProductModel> filteredData;

  final String searchQuery;

  final String? error;

  ProductState({
    this.loading = false,
    this.data = const [],
    this.filteredData = const [],
    this.searchQuery = '',
    this.error,
  });

  ProductState copyWith({
    bool? loading,
    List<ProductModel>? data,
    List<ProductModel>? filteredData,
    String? searchQuery,
    String? error,
  }) {
    return ProductState(
      loading: loading ?? this.loading,
      data: data ?? this.data,
      filteredData: filteredData ?? this.filteredData,
      searchQuery: searchQuery ?? this.searchQuery,
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
      if (data['action'] == 'get_products' || data['type'] == 'products') {
        final List list = data['data'];

        final products = list.map((e) => ProductModel.fromJson(e)).toList();

        state = state.copyWith(
          loading: false,
          data: products,
          filteredData: products,
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

    WebSocketService.instance.send({"action": "get_products", "payload": {}});
  }

  void searchProducts(String query) {
    final q = query.toLowerCase().trim();

    if (q.isEmpty) {
      state = state.copyWith(searchQuery: '', filteredData: state.data);

      return;
    }

    final filtered =
        state.data.where((item) {
          final name = item.productName.toLowerCase();

          final code = item.productCode.toLowerCase();

          return name.contains(q) || code.contains(q);
        }).toList();

    state = state.copyWith(searchQuery: query, filteredData: filtered);
  }
}
