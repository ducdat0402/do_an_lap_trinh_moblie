import 'package:do_an_lap_trinh_mobile/screens/admin_work/category_screen.dart';
import 'package:do_an_lap_trinh_mobile/screens/admin_work/product_screen.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quản lý Admin')),
      body: ListView(
        children: [
          _buildMenuItem(context, 'Đơn hàng', Icons.shopping_cart, () {}),
          _buildMenuItem(context, 'Sản phẩm', Icons.shopping_bag, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductsScreen(category: "all"),
              ),
            );
          }),
          _buildMenuItem(context, 'Danh mục', Icons.category, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CategoryScreen()),
            );
          }),
          _buildMenuItem(context, 'Tài khoản', Icons.person, () {}),
        ],
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
        leading: Icon(icon),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
