import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:do_an_lap_trinh_mobile/models/product.dart';
import 'package:do_an_lap_trinh_mobile/screens/Detail/detail_screen.dart';
import 'package:intl/intl.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(amount);
  }

  // Hàm gộp các mục trùng lặp trong giỏ hàng
  Future<void> _mergeDuplicateItems(String userId) async {
    try {
      final cartSnapshot =
          await FirebaseFirestore.instance
              .collection('cart')
              .where('userId', isEqualTo: userId)
              .get();

      final Map<String, List<DocumentSnapshot>> groupedItems = {};

      for (var doc in cartSnapshot.docs) {
        final data = doc.data();
        final productId = data['productId'] as String;
        if (groupedItems.containsKey(productId)) {
          groupedItems[productId]!.add(doc);
        } else {
          groupedItems[productId] = [doc];
        }
      }

      for (var productId in groupedItems.keys) {
        final items = groupedItems[productId]!;
        if (items.length > 1) {
          int totalQuantity = 0;
          for (var item in items) {
            final quantity = item['quantity'];
            totalQuantity +=
                (quantity is num
                    ? quantity.toInt()
                    : int.tryParse(quantity.toString()) ?? 1);
          }

          final firstItem = items.first;
          await firstItem.reference.update({'quantity': totalQuantity});

          for (var i = 1; i < items.length; i++) {
            await items[i].reference.delete();
          }
        }
      }
    } catch (e) {
      print('Lỗi khi gộp các mục trùng lặp: $e');
    }
  }

  // Hàm xử lý thanh toán
  Future<void> _processPayment(
    BuildContext context,
    String userId,
    List<DocumentSnapshot> cartDocs,
    double totalPrice,
    List<Map<String, dynamic>> cartItems,
  ) async {
    // Hiển thị hộp thoại xác nhận
    bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận thanh toán'),
            content: const Text(
              'Bạn có chắc chắn muốn thanh toán đơn hàng này?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // Hủy
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true), // Xác nhận
                child: const Text('Xác nhận'),
              ),
            ],
          ),
    );

    // Nếu người dùng xác nhận
    if (confirm == true) {
      try {
        // Tạo orderId duy nhất
        final String orderId = "ORDER_${DateTime.now().millisecondsSinceEpoch}";

        // Lưu đơn hàng vào Firestore
        await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
          'orderId': orderId,
          'userId': userId,
          'items': cartItems,
          'totalPrice': totalPrice,
          'status': 'pending', // Trạng thái ban đầu
          'createdAt': Timestamp.now(),
        });

        // Xóa giỏ hàng
        for (var doc in cartDocs) {
          await doc.reference.delete();
        }

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thanh toán thành công! Đơn hàng đã được tạo.'),
          ),
        );
      } catch (e) {
        print('Lỗi khi xử lý thanh toán: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi xử lý đơn hàng!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Vui lòng đăng nhập để xem giỏ hàng')),
      );
    }

    final userId = user.uid;

    _mergeDuplicateItems(userId);

    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('cart')
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
            return const Center(child: Text('Giỏ hàng trống'));
          }

          final cartDocs = snapshot.data!.docs;

          double totalPrice = 0;
          List<Map<String, dynamic>> cartItems = [];
          for (var doc in cartDocs) {
            final data = doc.data() as Map<String, dynamic>;
            // Xử lý productPrice
            final priceValue = data['productPrice'];
            final price =
                priceValue is num
                    ? priceValue.toDouble()
                    : double.tryParse(priceValue.toString()) ?? 0.0;
            // Xử lý quantity
            final quantityValue = data['quantity'];
            final quantity =
                quantityValue is num
                    ? quantityValue.toInt()
                    : int.tryParse(quantityValue.toString()) ?? 1;

            totalPrice += price * quantity;

            cartItems.add({
              'productId': data['productId'],
              'productName': data['productName'],
              'productPrice': price, // Lưu dưới dạng số
              'productCategory': data['productCategory'],
              'productImage': data['productImage'],
              'quantity': quantity, // Lưu dưới dạng số
              'subtotal': price * quantity,
            });
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartDocs.length,
                  itemBuilder: (context, index) {
                    final data = cartDocs[index].data() as Map<String, dynamic>;
                    final product = Product(
                      id: data['productId'],
                      name: data['productName'],
                      price: data['productPrice'].toString(),
                      category: data['productCategory'],
                      image: data['productImage'],
                      description: data['description'],
                    );
                    final quantityValue = data['quantity'];
                    final quantity =
                        quantityValue is num
                            ? quantityValue.toInt()
                            : int.tryParse(quantityValue.toString()) ?? 1;

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => DetailScreen(product: product),
                            ),
                          );
                        },
                        leading: _buildProductImage(product.image),
                        title: Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Giá: ${formatCurrency(double.tryParse(product.price) ?? 0.0)}',
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 20),
                                  onPressed: () async {
                                    if (quantity > 1) {
                                      await FirebaseFirestore.instance
                                          .collection('cart')
                                          .doc(cartDocs[index].id)
                                          .update({'quantity': quantity - 1});
                                    } else {
                                      await FirebaseFirestore.instance
                                          .collection('cart')
                                          .doc(cartDocs[index].id)
                                          .delete();
                                    }
                                  },
                                ),
                                Text('$quantity'),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 20),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('cart')
                                        .doc(cartDocs[index].id)
                                        .update({'quantity': quantity + 1});
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('cart')
                                .doc(cartDocs[index].id)
                                .delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã xóa khỏi giỏ hàng!'),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('cart')
                .where('userId', isEqualTo: userId)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const SizedBox.shrink();
          }

          final cartDocs = snapshot.data!.docs;

          double totalPrice = 0;
          List<Map<String, dynamic>> cartItems = [];
          for (var doc in cartDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final priceValue = data['productPrice'];
            final price =
                priceValue is num
                    ? priceValue.toDouble()
                    : double.tryParse(priceValue.toString()) ?? 0.0;
            final quantityValue = data['quantity'];
            final quantity =
                quantityValue is num
                    ? quantityValue.toInt()
                    : int.tryParse(quantityValue.toString()) ?? 1;

            totalPrice += price * quantity;

            cartItems.add({
              'productId': data['productId'],
              'productName': data['productName'],
              'productPrice': price,
              'productCategory': data['productCategory'],
              'productImage': data['productImage'],
              'quantity': quantity,
              'subtotal': price * quantity,
            });
          }

          return Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng tiền: ${formatCurrency(totalPrice)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _processPayment(
                      context,
                      userId,
                      cartDocs,
                      totalPrice,
                      cartItems,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Thanh toán'),
                ),
              ],
            ),
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
