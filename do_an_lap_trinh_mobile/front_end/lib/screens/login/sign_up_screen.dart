import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:do_an_lap_trinh_mobile/screens/login/login_screen.dart';
import 'package:do_an_lap_trinh_mobile/screens/Home/Widget/app_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpState();
}

class _SignUpState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool _isLoading = false; // Thêm trạng thái loading

  // Xử lý đăng ký tài khoản
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true; // Hiển thị loading
    });

    try {
      // Tạo tài khoản trên Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      User? user = userCredential.user;

      if (user != null) {
        // Lưu thông tin người dùng vào Firestore
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "id": user.uid, // Lưu ID người dùng
          "name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "role": "user", // Mặc định user mới sẽ có role = "user"
          "createdAt": Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Đăng ký thành công! Vui lòng đăng nhập."),
            backgroundColor: Colors.green,
          ),
        );
        // Chuyển hướng đến LoginScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Đăng ký thất bại!";
      if (e.code == 'email-already-in-use') {
        message = "Email này đã được sử dụng.";
      } else if (e.code == 'weak-password') {
        message = "Mật khẩu quá yếu.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false; // Ẩn loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background Gradient
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFff5c30), Color(0xFFe74b1a)],
              ),
            ),
          ),

          /// White Box
          Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height / 3,
            ),
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
          ),

          /// Logo + Form
          Container(
            margin: EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  /// Logo
                  Center(
                    child: Image.asset(
                      "images/Login_logo.png",
                      width: MediaQuery.of(context).size.width / 1.5,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 50.0),

                  /// Form Box
                  Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            SizedBox(height: 10.0),
                            Text(
                              "Sign up",
                              style: AppWidget.HeadlineTextFeildStyle(),
                            ),
                            const SizedBox(height: 15.0),

                            /// Name Input
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                hintText: 'Name',
                                hintStyle: AppWidget.semiBoldTextFeildStyle(),
                                prefixIcon: Icon(Icons.person_outlined),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Vui lòng nhập tên.";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 15.0),

                            /// Email Input
                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                hintText: 'Email',
                                hintStyle: AppWidget.semiBoldTextFeildStyle(),
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (value) {
                                if (value!.isEmpty || !value.contains('@')) {
                                  return "Vui lòng nhập email hợp lệ.";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 15.0),

                            /// Password Input
                            TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: AppWidget.semiBoldTextFeildStyle(),
                                prefixIcon: Icon(Icons.key_off_sharp),
                              ),
                              validator: (value) {
                                if (value!.length < 6) {
                                  return "Mật khẩu phải có ít nhất 6 ký tự.";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 15.0),

                            /// Confirm Password Input
                            TextFormField(
                              controller: confirmPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: 'Confirm Password',
                                hintStyle: AppWidget.semiBoldTextFeildStyle(),
                                prefixIcon: Icon(Icons.password_outlined),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Vui lòng nhập xác nhận mật khẩu.";
                                } else if (value != passwordController.text) {
                                  return "Mật khẩu không khớp.";
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: 50.0),

                            /// Sign Up Button
                            GestureDetector(
                              onTap: _signUp,
                              child: Material(
                                elevation: 5.0,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  width: 200,
                                  decoration: BoxDecoration(
                                    color: Color(0Xffff5722),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child:
                                        _isLoading
                                            ? CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                            : Text(
                                              "SIGN UP",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 50.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text("Already have an account? Login"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
