import 'package:do_an_lap_trinh_mobile/Provider/favorite_provider.dart';
import 'package:do_an_lap_trinh_mobile/route-guard.dart';
import 'package:do_an_lap_trinh_mobile/screens/admin_work/controller_admin.dart';
import 'package:do_an_lap_trinh_mobile/screens/nav_bar_screen.dart';
import 'package:do_an_lap_trinh_mobile/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Đảm bảo Flutter đã khởi tạo

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    FacebookAuth.instance;
    print("FacebookAuth initialized successfully in main.dart");
  } catch (e) {
    print("Failed to initialize FacebookAuth in main.dart: $e");
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      // ChangeNotifierProvider(create: (_) => CartProvider()),
      ChangeNotifierProvider(create: (_) => FavoriteProvider()),
    ],
    child: GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.mulishTextTheme()),
      home: RouteGuard(
        child: BottomNavBar(),

        // Màn hình chính của ứng dụng
      ),
      routes: {
        "/home": (context) => BottomNavBar(),
        "/admin": (context) => AdminDashboard(),
        "/login": (context) => LoginScreen(),
      },
    ),
  );
}
