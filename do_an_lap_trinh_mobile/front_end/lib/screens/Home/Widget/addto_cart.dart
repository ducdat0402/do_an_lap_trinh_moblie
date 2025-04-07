import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:do_an_lap_trinh_mobile/models/product.dart';

class AddToCart extends StatelessWidget {
  final Product product;

  const AddToCart({super.key, required this.product});

  Future<void> _addToCart(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để sử dụng tính năng này!'),
        ),
      );
      return;
    }

    final userId = user.uid;

    try {
      // Kiểm tra xem sản phẩm đã có trong giỏ hàng chưa
      final cartSnapshot =
          await FirebaseFirestore.instance
              .collection('cart')
              .where('userId', isEqualTo: userId)
              .where('productId', isEqualTo: product.id)
              .get();

      if (cartSnapshot.docs.isNotEmpty) {
        // Nếu sản phẩm đã có trong giỏ hàng, tăng số lượng
        final doc = cartSnapshot.docs.first;
        final currentQuantity = doc['quantity'] ?? 1;
        await doc.reference.update({'quantity': currentQuantity + 1});
      } else {
        // Nếu sản phẩm chưa có, thêm mới
        await FirebaseFirestore.instance.collection('cart').add({
          'userId': userId,
          'productId': product.id,
          'productName': product.name,
          'productPrice': product.price,
          'productCategory': product.category,
          'productImage': product.image,
          'quantity': 1,
        });
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã thêm vào giỏ hàng!')));
    } catch (e) {
      print('Lỗi khi thêm vào giỏ hàng: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi thêm vào giỏ hàng!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _addToCart(context),
      label: const Text('Thêm vào giỏ hàng'),
      icon: const Icon(Icons.shopping_cart),
    );
  }
}
