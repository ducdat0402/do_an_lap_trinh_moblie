import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserOrderScreen extends StatelessWidget {
  const UserOrderScreen({super.key});

  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(amount);
  }

  String formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
  }

  String getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xử lý';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Đơn hàng của tôi')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Đăng nhập để xem đơn hàng'),
          ),
        ),
      );
    }

    final userId = user.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Đơn hàng của tôi')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('orders')
                .where('userId', isEqualTo: userId)
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
            return const Center(child: Text('Bạn chưa có đơn hàng nào'));
          }

          final orderDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orderDocs.length,
            itemBuilder: (context, index) {
              final orderData = orderDocs[index].data() as Map<String, dynamic>;
              final String orderId = orderData['orderId'] ?? 'N/A';
              final totalPriceValue = orderData['totalPrice'];
              final double totalPrice =
                  totalPriceValue is num
                      ? totalPriceValue.toDouble()
                      : double.tryParse(totalPriceValue.toString()) ?? 0.0;
              final String status = orderData['status'] ?? 'pending';
              final Timestamp createdAt =
                  orderData['createdAt'] ?? Timestamp.now();
              final List<dynamic> items = orderData['items'] ?? [];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ExpansionTile(
                  title: Text(
                    'Đơn hàng #$orderId',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        'Tổng tiền: ${formatCurrency(totalPrice)} | ',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Status: ${getStatusText(status)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: getStatusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Thời gian: ${formatDate(createdAt)}'),
                          const Divider(),
                          const Text(
                            'Chi tiết sản phẩm:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...items.map((item) {
                            final String productName =
                                item['productName'] ?? 'N/A';
                            final productPriceValue = item['productPrice'];
                            final double productPrice =
                                productPriceValue is num
                                    ? productPriceValue.toDouble()
                                    : double.tryParse(
                                          productPriceValue.toString(),
                                        ) ??
                                        0.0;
                            final quantityValue = item['quantity'];
                            final int quantity =
                                quantityValue is num
                                    ? quantityValue.toInt()
                                    : int.tryParse(quantityValue.toString()) ??
                                        1;
                            final subtotalValue = item['subtotal'];
                            final double subtotal =
                                subtotalValue is num
                                    ? subtotalValue.toDouble()
                                    : double.tryParse(
                                          subtotalValue.toString(),
                                        ) ??
                                        0.0;

                            return ListTile(
                              title: Text(productName),
                              subtitle: Text(
                                'Giá: ${formatCurrency(productPrice)} | Số lượng: $quantity | Thành tiền: ${formatCurrency(subtotal)}',
                              ),
                            );
                          }).toList(),
                          if (status == 'pending') ...[
                            const Divider(),
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('orders')
                                      .doc(orderId)
                                      .update({'status': 'cancelled'});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đã hủy đơn hàng!'),
                                    ),
                                  );
                                } catch (e) {
                                  print('Lỗi khi hủy đơn hàng: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Lỗi khi hủy đơn hàng!'),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Hủy đơn hàng'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
