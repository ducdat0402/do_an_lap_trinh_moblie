import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminFeedbackScreen extends StatelessWidget {
  const AdminFeedbackScreen({super.key});

  String formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
  }

  String getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xử lý';
      case 'resolved':
        return 'Đã xử lý';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách phản hồi')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('feedbacks')
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
            return const Center(child: Text('Không có phản hồi nào'));
          }

          final feedbackDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: feedbackDocs.length,
            itemBuilder: (context, index) {
              final feedbackData =
                  feedbackDocs[index].data() as Map<String, dynamic>;
              final String feedbackId = feedbackDocs[index].id;
              final String userEmail = feedbackData['userEmail'] ?? 'N/A';
              final String content = feedbackData['content'] ?? '';
              final Timestamp createdAt =
                  feedbackData['createdAt'] ?? Timestamp.now();
              final String status = feedbackData['status'] ?? 'pending';

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ExpansionTile(
                  title: Text(
                    'Phản hồi từ: $userEmail',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        'Time: ${formatDate(createdAt)} | ',
                        style: const TextStyle(fontSize: 10),
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
                          const Text(
                            'Nội dung phản hồi:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(content),
                          const Divider(),
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                await FirebaseFirestore.instance
                                    .collection('feedbacks')
                                    .doc(feedbackId)
                                    .update({
                                      'status':
                                          status == 'pending'
                                              ? 'resolved'
                                              : 'pending',
                                    });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Cập nhật trạng thái thành công!',
                                    ),
                                  ),
                                );
                              } catch (e) {
                                print('Lỗi khi cập nhật trạng thái: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Lỗi khi cập nhật trạng thái!',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              status == 'pending'
                                  ? 'Đánh dấu đã xử lý'
                                  : 'Đặt lại thành chờ xử lý',
                            ),
                          ),
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
