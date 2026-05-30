import 'package:flutter/material.dart';
import 'package:zi_core/zi_core_io.dart';

class ProductTile extends StatelessWidget {
  final String productName;

  final String productCode;

  final String qty;

  final String rack;

  final String saleRate;

  final String wholesaleRate;

  final String currentRate;
  final int count;

  const ProductTile({
    super.key,

    required this.productName,

    required this.productCode,

    required this.qty,

    required this.rack,

    required this.saleRate,

    required this.wholesaleRate,

    required this.currentRate,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: SelectionArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      productName,
          
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text("Qty: $qty"),
                ],
              ),
          
              const SizedBox(height: 6),
          
              Row(
                children: [
                  Expanded(child: Row(
                    children: [
                      Icon(Icons.qr_code, size: 16, color: ZiColors.primary,),
                      Text(" $productCode"),
                    ],
                  )),
                  Text("W-Rate: $wholesaleRate", style: ZiTypoStyles.noSm),
                ],
              ),
          
              const SizedBox(height: 8),
          
              Row(
                children: [
                  Expanded(child: Row(
                    children: [
                      Text("#$count  |  Rack: "),
                      Text(rack, style: ZiTypoStyles.titleSm,),
                    ],
                  )),
          
                  Row(
                    children: [
                      Text(
                        "Sale-Rs: ",
                        style: ZiTypoStyles.noMd.copyWith(color: ZiColors.gray),
                      ),
                      Text(
                        saleRate,
                        style: ZiTypoStyles.noMd.copyWith(color: ZiColors.gainG),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
