import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';

class ProductModel {
  final String productId;
  final String productName;
  final String productCode;
  final String quantityInstock;
  final String currentRate;
  final String status;

  ProductModel({
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.quantityInstock,
    required this.currentRate,
    required this.status,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['product_id'].toString(),
      productName: json['product_name'].toString(),
      productCode: json['product_code'].toString(),
      quantityInstock: json['quantity_instock'].toString(),
      currentRate: json['current_rate'].toString(),
      status: json['status'].toString(),
    );
  }
}

class ProductsSocketScreen extends StatefulWidget {
  const ProductsSocketScreen({super.key});

  @override
  State<ProductsSocketScreen> createState() => _ProductsSocketScreenState();
}

class _ProductsSocketScreenState extends State<ProductsSocketScreen> {
  final TextEditingController urlController = TextEditingController(
    text: 'ws://192.168.1.25:8080',
  );

  final TextEditingController searchController = TextEditingController();

  WebSocket? socket;

  bool isConnected = false;

  bool isLoading = false;

  String statusText = '';

  List<ProductModel> allProducts = [];

  List<ProductModel> filteredProducts = [];

  // =========================
  // CONNECT
  // =========================

  void connectSocket() {
    try {
      debugPrint('================ CONNECT ================');

      socket = WebSocket(urlController.text.trim());

      socket!.onOpen.listen((event) {
        debugPrint('✅ SOCKET CONNECTED');

        setState(() {
          isConnected = true;
          statusText = 'Connected';
        });
      });

      socket!.onMessage.listen((event) {
        debugPrint('================ RESPONSE ================');

        debugPrint(event.data.toString());

        final decoded = jsonDecode(event.data.toString());

        if (decoded['action'] == 'get_products') {
          final List data = decoded['data'];

          final total = decoded['total'] ?? 0;

          final newProducts =
              data.map((e) => ProductModel.fromJson(e)).toList();

          allProducts.addAll(newProducts);
          filteredProducts = allProducts;

          // stop pagination if reached end
          if (allProducts.length >= total) {
            hasMore = false;
          }

          setState(() {
            isLoading = false;
            statusText = '${allProducts.length} / $total loaded';
          });
        }
      });

      socket!.onClose.listen((event) {
        debugPrint('❌ SOCKET CLOSED');

        setState(() {
          isConnected = false;
          statusText = 'Disconnected';
        });
      });

      socket!.onError.listen((event) {
        debugPrint('⚠ SOCKET ERROR');

        setState(() {
          statusText = 'Socket Error';
        });
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        statusText = e.toString();
      });
    }
  }

  // =========================
  // LOAD PRODUCTS
  // =========================
  int limit = 10;
  int offset = 0;
  bool hasMore = true;
  void loadProducts({bool loadMore = false}) {
    if (socket == null) return;

    if (!loadMore) {
      offset = 0;
      allProducts.clear();
      filteredProducts.clear();
      hasMore = true;
    } else {
      offset += limit;
    }

    setState(() {
      isLoading = true;
    });

    final request = {
      "action": "get_products",
      "limit": limit,
      "offset": offset,
    };

    debugPrint("================ SEND ================");
    debugPrint(jsonEncode(request));

    socket!.send(jsonEncode(request));
  }

  // =========================
  // SEARCH
  // =========================

  void searchProducts(String value) {
    final query = value.toLowerCase();

    filteredProducts =
        allProducts.where((product) {
          return product.productName.toLowerCase().contains(query) ||
              product.productCode.toLowerCase().contains(query);
        }).toList();

    setState(() {});
  }

  // =========================
  // CLEAR
  // =========================

  void clearProducts() {
    setState(() {
      allProducts.clear();
      filteredProducts.clear();
      statusText = 'Cleared';
    });
  }

  @override
  void dispose() {
    socket?.close();

    urlController.dispose();
    searchController.dispose();

    super.dispose();
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Socket Products'),

        actions: [
          IconButton(onPressed: clearProducts, icon: const Icon(Icons.refresh)),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // URL
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Socket URL',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // CONNECT
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isConnected ? null : connectSocket,

                child: const Text('Connect Socket'),
              ),
            ),

            const SizedBox(height: 12),

            // LOAD PRODUCTS
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isConnected ? loadProducts : null,

                child:
                    isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Get Products'),
              ),
            ),

            const SizedBox(height: 12),

            // SEARCH
            TextField(
              controller: searchController,
              onChanged: searchProducts,
              decoration: const InputDecoration(
                labelText: 'Search Product',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // STATUS
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                statusText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 12),

            // LIST
            Expanded(
              child:
                  filteredProducts.isEmpty
                      ? const Center(child: Text('No Products'))
                      : ListView.builder(
                        itemCount: filteredProducts.length,

                        itemBuilder: (_, index) {
                          final product = filteredProducts[index];

                          return Card(
                            child: ListTile(
                              title: Text(product.productName),

                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text('Barcode: ${product.productCode}'),

                                  Text('Stock: ${product.quantityInstock}'),
                                ],
                              ),

                              trailing: Text(
                                'Rs ${product.currentRate}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
            if (hasMore)
              Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton(
                  onPressed:
                      isLoading ? null : () => loadProducts(loadMore: true),
                  child: const Text("Load More"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
