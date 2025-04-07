import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:do_an_lap_trinh_mobile/models/product.dart';
import 'package:intl/intl.dart';

class DetailScreen extends StatefulWidget {
  final Product product;

  const DetailScreen({super.key, required this.product});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final TextEditingController _reviewController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(amount);
  }

  String formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
  }

  // Gửi đánh giá
  Future<void> _submitReview() async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để đánh giá!')),
      );
      return;
    }

    final String comment = _reviewController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung đánh giá!')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id)
          .collection('reviews')
          .add({
            'userEmail': user!.email ?? 'N/A',
            'comment': comment,
            'createdAt': Timestamp.now(),
          });

      _reviewController.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đánh giá đã được gửi!')));
    } catch (e) {
      print('Lỗi khi gửi đánh giá: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lỗi khi gửi đánh giá!')));
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh sản phẩm
            Center(child: _buildProductImage(widget.product.image)),
            const SizedBox(height: 16),
            // Tên sản phẩm
            Text(
              widget.product.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Giá sản phẩm
            Text(
              'Giá: ${formatCurrency(double.tryParse(widget.product.price) ?? 0.0)}',
              style: const TextStyle(fontSize: 20, color: Colors.red),
            ),
            const SizedBox(height: 8),
            // Danh mục
            Text(
              'Danh mục: ${widget.product.category}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            // Mô tả
            Text(
              'Mô tả: ${widget.product.description}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // Phần đánh giá
            const Text(
              'Đánh giá sản phẩm',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // TextField để viết đánh giá
            TextField(
              controller: _reviewController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Viết đánh giá của bạn',
                hintText: 'Nhập nội dung đánh giá...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text('Gửi đánh giá'),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // Danh sách đánh giá
            const Text(
              'Danh sách đánh giá',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('products')
                      .doc(widget.product.id)
                      .collection('reviews')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Chưa có đánh giá nào'));
                }

                final reviewDocs = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviewDocs.length,
                  itemBuilder: (context, index) {
                    final reviewData =
                        reviewDocs[index].data() as Map<String, dynamic>;
                    final String userEmail = reviewData['userEmail'] ?? 'N/A';
                    final String comment = reviewData['comment'] ?? '';
                    final Timestamp createdAt =
                        reviewData['createdAt'] ?? Timestamp.now();

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Người dùng: $userEmail',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Thời gian: ${formatDate(createdAt)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(comment),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String? image) {
    if (image == null || image.isEmpty) {
      return const Icon(Icons.image, size: 150);
    }

    try {
      final imageData = base64Decode(image);
      return Image.memory(
        imageData,
        width: 150,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 150);
        },
      );
    } catch (e) {
      return const Icon(Icons.broken_image, size: 150);
    }
  }
}
