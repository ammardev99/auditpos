import 'package:auditpos/shell/products/data/p_provider.dart';
import 'package:auditpos/shell/products/product_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  @override
  @override
  // FILE: lib/shell/products/products_screen.dart
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      debugPrint("\nCALLING PRODUCT PROVIDER FROM UI");
      ref.read(productProvider.notifier).getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productProvider);

    if (state.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.error != null) {
      return Scaffold(body: Center(child: Text("Error: ${state.error}")));
    }

    return Scaffold(
      appBar: AppBar(title: Text("Products (${state.data.length})")),
      body: ListView.builder(
        itemCount: state.data.length,
        itemBuilder: (context, index) {
          final item = state.data[index];

          return ProductTile(
            productName: item.productName,
            productCode: item.productCode,
            qty: item.quantityInstock.toString(),
            price: item.currentRate.toString(),
          );
        },
      ),
    );
  }
}
