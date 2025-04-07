import 'package:do_an_lap_trinh_mobile/screens/profile/user_order_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:do_an_lap_trinh_mobile/screens/profile/user_order_screen.dart'; // Import màn hình đơn hàng

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hồ sơ')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Đăng nhập để tiếp tục'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị thông tin người dùng
            Text(
              'Email: ${user.email ?? 'N/A'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tên: ${user.displayName ?? 'Chưa đặt tên'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            // Nút xem đơn hàng
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserOrderScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('Xem đơn hàng của tôi'),
            ),
            const SizedBox(height: 16),
            // Nút đăng xuất (tùy chọn)
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('Đăng xuất'),
            ),
          ],
        ),
      ),
    );
  }
}
