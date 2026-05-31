import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:auditpos/shell/products/data/p_provider.dart';
import 'package:auditpos/shell/products/product_tile.dart';
import 'package:zi_core/zi_core_io.dart';
import '../../bar_code_scanner/bar_code_io.dart';
import '../network/websocket_service.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final searchController = TextEditingController();

  bool _requested = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(productProvider.notifier).reset();
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_requested) return;

      final connected = WebSocketService.instance.isConnectedNotifier.value;

      if (!connected) return;

      _requested = true;

      ref.read(productProvider.notifier).getProducts();
    });
  }

  Future<void> searchScan() async {
    final code = await ZiToBarCodeScanner.scan(context);

    if (code != null) {
      searchController.text = code;

      // FIX: Manually trigger the search in your provider
      // so the list updates immediately after the scan.
      ref.read(productProvider.notifier).searchProducts(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productProvider);

    return ValueListenableBuilder<bool>(
      valueListenable: WebSocketService.instance.isConnectedNotifier,
      builder: (context, connected, _) {
        return Scaffold(
          appBar: ZiAppBarB(title: "Products (${state.filteredData.length})"),

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
                        padding: const EdgeInsets.all(16),
                        child: ZiInput(
                          prefix: const Icon(Icons.search),
                          // label: "",
                          hint: "Search by name or barcode",
                          type: ZiInputType.search,
                          controller: searchController,

                          suffix:
                              searchController.text.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      searchController.clear();
                                      ref
                                          .read(productProvider.notifier)
                                          .searchProducts('');
                                      setState(() {});
                                    },
                                  )
                                  : IconButton(
                                    icon: const Icon(Icons.qr_code_scanner),
                                    onPressed: searchScan,
                                  ),
                          onChanged: (value) {
                            ref
                                .read(productProvider.notifier)
                                .searchProducts(value);
                          },
                        ),
                      ),

                      Expanded(
                        child: ListView.builder(
                          itemCount: state.filteredData.length,
                          itemBuilder: (context, index) {
                            final item = state.filteredData[index];
                            return ProductTile(
                              count: item.productId,
                              productName: item.productName,
                              productCode: item.productCode,
                              qty: item.quantityInstock.toString(),
                              rack: item.rack,
                              currentRate: item.currentRate.toString(),
                              saleRate: item.saleRate.toString(),
                              wholesaleRate: item.wholesaleRate.toString(),
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
