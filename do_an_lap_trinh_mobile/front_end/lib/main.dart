import 'package:do_an_lap_trinh_mobile/Provider/cart_provider.dart';
import 'package:do_an_lap_trinh_mobile/Provider/favorite_provider.dart';
import 'package:do_an_lap_trinh_mobile/screens/admin_work/account_screen.dart';

import 'package:do_an_lap_trinh_mobile/screens/admin_work/category_screen.dart';
// ignore: unused_import
import 'package:do_an_lap_trinh_mobile/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: unused_import
import 'screens/nav_bar_screen.dart';
import 'package:provider/provider.dart';

void main() {
  Get.put(ProductController()); // Đăng ký controller
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => CartProvider()),
      ChangeNotifierProvider(create: (_) => FavoriteProvider()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.mulishTextTheme()),
      home: BottomNavBar(),
      routes: {
        //   '/orders': (context) => OrdersScreen(),
        '/categories': (context) => CategoryScreen(),
        //   '/accounts': (context) => AccountsScreen(),
      },
    ),
  );
}
