import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:do_an_lap_trinh_mobile/models/product.dart';
import 'package:intl/intl.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
    required this.onAddToCart,
  });

  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 70,
              width: double.infinity,
              child: _buildProductImage(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Giá: ${formatCurrency(double.tryParse(product.price) ?? 0.0)}',
                    style: const TextStyle(fontSize: 14, color: Colors.green),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.add_shopping_cart,
                          color: Colors.blue,
                          size: 20,
                        ),
                        onPressed: onAddToCart,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                          size: 20,
                        ),
                        onPressed: onFavoriteToggle, // Gọi callback toggle
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    if (product.image == null || product.image!.isEmpty) {
      return const Icon(Icons.image, size: 70);
    }

    try {
      final imageData = base64Decode(product.image!);
      return Image.memory(
        imageData,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 70,
        errorBuilder: (context, error, stackTrace) {
          print('Lỗi khi hiển thị hình ảnh: $error');
          return const Icon(Icons.broken_image, size: 70);
        },
      );
    } catch (e) {
      print('Lỗi khi giải mã Base64: $e');
      return const Icon(Icons.broken_image, size: 70);
    }
  }
}
