import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:do_an_lap_trinh_mobile/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Đăng ký người dùng bằng email/mật khẩu
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Tạo tài khoản với Firebase Authentication
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Xác định vai trò của người dùng
      UserRole role = email.contains('admin') ? UserRole.admin : UserRole.user;

      // Lưu thông tin người dùng vào Firestore
      UserModel userModel = UserModel(
        id: result.user!.uid,
        email: email,
        name: name,
        role: role,
      );

      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(userModel.toJson());

      return userModel;
    } catch (e) {
      print("Đăng ký thất bại: $e");
      return null;
    }
  }

  // Đăng nhập bằng email/mật khẩu
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) {
        print("Đăng nhập thất bại: Không tìm thấy user.");
        return null;
      }

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(result.user!.uid).get();

      final userData = userDoc.data();
      if (userData == null) {
        print(
          "Đăng nhập thất bại: Dữ liệu người dùng không tồn tại hoặc bị null.",
        );
        return null;
      }

      UserModel user = UserModel.fromJson(userData as Map<String, dynamic>);
      return {'user': user, 'role': user.role};
    } catch (e) {
      print("Đăng nhập thất bại: $e");
      return null;
    }
  }

  // Đăng nhập bằng Google
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // Khởi tạo Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn();
      // Đăng xuất Google trước khi đăng nhập mới
      await googleSignIn.signOut();
      // Yêu cầu người dùng đăng nhập
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // Người dùng hủy đăng nhập
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập với Firebase
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;

      if (user == null) {
        print("Đăng nhập Google thất bại: Không tìm thấy user.");
        return null;
      }

      // Kiểm tra xem email đã tồn tại trong Firestore chưa
      QuerySnapshot existingUsers =
          await _firestore
              .collection('users')
              .where('email', isEqualTo: user.email)
              .get();

      if (existingUsers.docs.isNotEmpty) {
        // Nếu email đã tồn tại, lấy thông tin người dùng từ Firestore
        DocumentSnapshot userDoc = existingUsers.docs.first;
        UserModel userModel = UserModel.fromJson(
          userDoc.data() as Map<String, dynamic>,
        );
        return {'user': userModel, 'role': userModel.role};
      }

      // Nếu chưa tồn tại, tạo bản ghi mới trong Firestore
      UserModel userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? 'Người dùng Google',
        role: user.email!.contains('admin') ? UserRole.admin : UserRole.user,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toJson());

      return {'user': userModel, 'role': userModel.role};
    } catch (e) {
      print("Đăng nhập Google thất bại: $e");
      return null;
    }
  }

  // Lấy vai trò của người dùng từ Firestore
  Future<String?> getUserRole(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        return userDoc['role'];
      }
      return null;
    } catch (e) {
      print("Lỗi khi lấy vai trò người dùng: $e");
      return null;
    }
  }

  // Kiểm tra trạng thái đăng nhập
  Stream<User?> get user => _auth.authStateChanges();

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut(); // Đăng xuất Google
    await FacebookAuth.instance.logOut(); // Đăng xuất Facebook
  }
}
