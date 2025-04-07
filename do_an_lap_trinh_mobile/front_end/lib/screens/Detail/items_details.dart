import 'package:do_an_lap_trinh_mobile/constants.dart';
import 'package:do_an_lap_trinh_mobile/models/product.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemsDetails extends StatelessWidget {
  final Product product;
  const ItemsDetails({super.key, required this.product});
  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 25),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatCurrency(double.tryParse(product.price) ?? 0.0),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 25,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Mô tả sản phẩm:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 5),
        Text(
          product.description ?? 'Chưa có mô tả',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
