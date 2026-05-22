import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:auditpos/shell/products/data/p_provider.dart';
import 'package:auditpos/shell/products/product_tile.dart';

import '../network/websocket_service.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      final connected = WebSocketService.instance.isConnectedNotifier.value;

      debugPrint("WS CONNECTED => $connected");

      // =========================================
      // CHECK WEBSOCKET BEFORE API CALL
      // =========================================
      if (!connected) {
        debugPrint("WEBSOCKET NOT CONNECTED");
        return;
      }

      debugPrint("CALLING PRODUCT PROVIDER FROM UI");

      ref.read(productProvider.notifier).getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productProvider);

    return ValueListenableBuilder<bool>(
      valueListenable: WebSocketService.instance.isConnectedNotifier,

      builder: (context, connected, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Products (${state.filteredData.length})"),

            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 14),

                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 14,
                      color: connected ? Colors.green : Colors.red,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      connected ? "WS Connected" : "WS Disconnected",

                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

          body:
              !connected
                  ? const Center(child: Text("WebSocket not connected"))
                  : state.loading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                  ? Center(child: Text("Error: ${state.error}"))
                  : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),

                        child: TextField(
                          controller: searchController,

                          onChanged: (value) {
                            ref
                                .read(productProvider.notifier)
                                .searchProducts(value);
                          },

                          decoration: InputDecoration(
                            hintText: "Search by name or barcode",

                            prefixIcon: const Icon(Icons.search),

                            suffixIcon:
                                searchController.text.isNotEmpty
                                    ? IconButton(
                                      icon: const Icon(Icons.clear),

                                      onPressed: () {
                                        searchController.clear();

                                        ref
                                            .read(productProvider.notifier)
                                            .searchProducts('');
                                      },
                                    )
                                    : null,

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: ListView.builder(
                          itemCount: state.filteredData.length,

                          itemBuilder: (context, index) {
                            final item = state.filteredData[index];

                            return ProductTile(
                              productName: item.productName,
                              productCode: item.productCode,
                              qty: item.quantityInstock.toString(),
                              price: item.currentRate.toString(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
        );
      },
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:auditpos/shell/products/data/p_provider.dart';
// import 'package:auditpos/shell/products/product_tile.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class ProductsScreen extends ConsumerStatefulWidget {
//   const ProductsScreen({super.key});

//   @override
//   ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
// }

// class _ProductsScreenState extends ConsumerState<ProductsScreen> {
//   @override
//   @override
//   // FILE: lib/shell/products/products_screen.dart
//   @override
//   void initState() {
//     super.initState();

//     Future.delayed(Duration.zero, () {
//       debugPrint("\nCALLING PRODUCT PROVIDER FROM UI");
//       ref.read(productProvider.notifier).getProducts();
//     });
//   }

//   final searchController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(productProvider);

//     if (state.loading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     if (state.error != null) {
//       return Scaffold(body: Center(child: Text("Error: ${state.error}")));
//     }

//     return Scaffold(
//       appBar: AppBar(title: Text("Products (${state.filteredData.length})")),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12),

//             child: TextField(
//               controller: searchController,

//               onChanged: (value) {
//                 ref.read(productProvider.notifier).searchProducts(value);
//               },

//               decoration: InputDecoration(
//                 hintText: "Search by name or barcode",

//                 prefixIcon: const Icon(Icons.search),

//                 suffixIcon:
//                     searchController.text.isNotEmpty
//                         ? IconButton(
//                           icon: const Icon(Icons.clear),
//                           onPressed: () {
//                             searchController.clear();
//                             ref
//                                 .read(productProvider.notifier)
//                                 .searchProducts('');
//                           },
//                         )
//                         : null,

//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ),

//           Expanded(
//             child: ListView.builder(
//               itemCount: state.filteredData.length,

//               itemBuilder: (context, index) {
//                 final item = state.filteredData[index];

//                 return ProductTile(
//                   productName: item.productName,
//                   productCode: item.productCode,
//                   qty: item.quantityInstock.toString(),
//                   price: item.currentRate.toString(),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
