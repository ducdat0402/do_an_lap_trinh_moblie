import 'package:do_an_lap_trinh_mobile/screens/admin_work/AdminFeedbackScreen.dart';
import 'package:do_an_lap_trinh_mobile/screens/admin_work/order_screen.dart';
import 'package:flutter/material.dart';
import 'category_screen.dart';
import 'product_screen.dart';
import 'account_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý Admin'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            _buildMenuItem(context, 'Đơn hàng', Icons.shopping_cart, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminOrderScreen()),
              );
            }),
            _buildMenuItem(context, 'Sản phẩm', Icons.shopping_bag, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProductScreen()),
              );
            }),
            _buildMenuItem(context, 'Danh mục', Icons.category, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoryScreen()),
              );
            }),
            _buildMenuItem(context, 'Tài khoản', Icons.person, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountScreen()),
              );
            }),
            _buildMenuItem(context, 'Phản hồi', Icons.comment, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminFeedbackScreen()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Xác nhận'),
            content: Text('Bạn có chắc chắn muốn đăng xuất?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Đóng hộp thoại
                child: Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Đóng hộp thoại
                  Navigator.pushReplacementNamed(
                    context,
                    '/login',
                  ); // Điều hướng về trang đăng nhập
                },
                child: Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
