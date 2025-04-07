import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  _SupportScreenState createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  // Gửi phản hồi
  Future<void> _submitFeedback() async {
    final String content = _feedbackController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung phản hồi!')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('feedbacks').add({
        'userEmail': user?.email ?? 'Khách vãng lai',
        'content': content,
        'createdAt': Timestamp.now(),
        'status': 'pending', // Trạng thái ban đầu
      });

      _feedbackController.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Phản hồi đã được gửi!')));
    } catch (e) {
      print('Lỗi khi gửi phản hồi: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lỗi khi gửi phản hồi!')));
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hỗ Trợ Khách Hàng')),
      body: SingleChildScrollView(
        // Thêm SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Liên hệ với chúng tôi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.blue),
              title: const Text('Hotline: 0983425129'),
              onTap: () {}, // Xử lý gọi điện thoại
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.red),
              title: const Text('Email: leducdat0402@gmail.com'),
              onTap: () {}, // Xử lý gửi email
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text('Zalo: 0983425129'),
              onTap: () {}, // Xử lý mở Zalo chat
            ),
            const SizedBox(height: 20),
            const Text(
              'Gửi phản hồi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nhập nội dung phản hồi...',
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitFeedback,
              child: const Text('Gửi phản hồi'),
            ),
          ],
        ),
      ),
    );
  }
}
