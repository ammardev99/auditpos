import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shell/network/websocket_service.dart';
import 'product_model.dart';

final productProvider =
    StateNotifierProvider<ProductNotifier, ProductState>(
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
  StreamSubscription? _wsSub;
  bool _isDisposed = false;

  ProductNotifier() : super(ProductState()) {
    _listenWS();
  }

  /// ✅ SINGLE SAFE LISTENER
  void _listenWS() {
    _wsSub?.cancel();

    _wsSub = WebSocketService.instance.messageStream.listen((data) {
      if (_isDisposed) return;
      // ignore: unnecessary_type_check
      if (data is! Map) return;

      debugPrint("PRODUCT WS MESSAGE => $data");

      /// ❌ Ignore system / ack messages
      if (data['message'] == 'Received') return;
      if (data['type'] == 'system') return;

      /// ✅ Handle product payload safely
      final rawList = data['data'];

      if (rawList is List) {
        final products =
            rawList.map((e) => ProductModel.fromJson(e)).toList();

        state = state.copyWith(
          loading: false,
          data: products,
          filteredData: products,
          error: null,
        );

        debugPrint("PRODUCTS UPDATED => ${products.length}");
      }
    });
  }

  /// ✅ RESET STATE (SAFE)
  void reset() {
    state = ProductState(
      loading: false,
      data: [],
      filteredData: [],
      searchQuery: '',
      error: null,
    );
  }

  /// ✅ REQUEST PRODUCTS
  void getProducts() {
    debugPrint("========== PRODUCT REQUEST ==========");

    state = state.copyWith(loading: true, error: null);

    WebSocketService.instance.send({
      "action": "get_products",
      "payload": {},
    });

    /// ⛑ SAFETY TIMEOUT
    Future.delayed(const Duration(seconds: 8), () {
      if (_isDisposed) return;

      if (state.loading) {
        state = state.copyWith(
          loading: false,
          error: "Request timeout (no WS response)",
        );
      }
    });
  }

  /// SEARCH
  void searchProducts(String query) {
    final q = query.toLowerCase().trim();

    if (q.isEmpty) {
      state = state.copyWith(
        searchQuery: '',
        filteredData: state.data,
      );
      return;
    }

    final filtered = state.data.where((item) {
      final name = item.productName.toLowerCase();
      final code = item.productCode.toLowerCase();

      return name.contains(q) || code.contains(q);
    }).toList();

    state = state.copyWith(
      searchQuery: query,
      filteredData: filtered,
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _wsSub?.cancel();
    super.dispose();
  }
}