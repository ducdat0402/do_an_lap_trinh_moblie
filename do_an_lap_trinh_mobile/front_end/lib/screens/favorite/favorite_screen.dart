import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:do_an_lap_trinh_mobile/models/product.dart';
import 'package:do_an_lap_trinh_mobile/screens/Detail/detail_screen.dart'; // Import DetailScreen
import 'package:intl/intl.dart'; // Import thư viện intl

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Vui lòng đăng nhập để xem danh sách yêu thích'),
        ),
      );
    }

    final userId = user.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách yêu thích')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('favorites')
                .where('userId', isEqualTo: userId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Không có sản phẩm yêu thích nào'));
          }

          final favoriteDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoriteDocs.length,
            itemBuilder: (context, index) {
              final data = favoriteDocs[index].data() as Map<String, dynamic>;
              final product = Product(
                id: data['productId'],
                name: data['productName'],
                price: data['productPrice'],
                category: data['productCategory'],
                image: data['productImage'],
                description: data['description'], // Thêm description nếu có
              );

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  onTap: () {
                    // Chuyển hướng đến DetailScreen khi nhấn vào sản phẩm
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(product: product),
                      ),
                    );
                  },
                  leading: _buildProductImage(product.image),
                  title: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Giá: ${formatCurrency(double.tryParse(product.price) ?? 0.0)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Xóa sản phẩm khỏi danh sách yêu thích
                      await FirebaseFirestore.instance
                          .collection('favorites')
                          .doc(favoriteDocs[index].id)
                          .delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã xóa khỏi mục yêu thích!'),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductImage(String? image) {
    if (image == null || image.isEmpty) {
      return const Icon(Icons.image, size: 50);
    }

    try {
      final imageData = base64Decode(image);
      return Image.memory(
        imageData,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 50);
        },
      );
    } catch (e) {
      return const Icon(Icons.broken_image, size: 50);
    }
  }
}
