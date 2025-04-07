import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_an_lap_trinh_mobile/screens/Home/home_screen.dart';
import 'package:do_an_lap_trinh_mobile/screens/nav_bar_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:do_an_lap_trinh_mobile/screens/login/login_screen.dart';
import 'package:do_an_lap_trinh_mobile/screens/admin_work/controller_admin.dart';

enum UserRole { user, admin }

class RouteGuard extends StatelessWidget {
  final Widget child;

  const RouteGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;

          // Nếu chưa đăng nhập, chuyển đến LoginScreen
          if (user == null) return LoginScreen();

          // Kiểm tra vai trò user từ Firestore
          return FutureBuilder<DocumentSnapshot>(
            future:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ); // Loading
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Không tìm thấy dữ liệu người dùng!",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                          child: Text("Quay lại Đăng nhập"),
                        ),
                      ],
                    ),
                  ),
                );
              }

              String roleString = userSnapshot.data?['role'] ?? '';
              UserRole? role = UserRole.values.cast<UserRole?>().firstWhere(
                (e) => e.toString().split('.').last == roleString,
                orElse: () => null,
              );

              if (role == null) {
                return Scaffold(
                  body: Center(child: Text("Vai trò không hợp lệ")),
                );
              }

              return role == UserRole.admin ? AdminDashboard() : BottomNavBar();
            },
          );
        }

        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ); // Loading
      },
    );
  }
}
