import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:do_an_lap_trinh_mobile/models/category.dart';
import 'package:do_an_lap_trinh_mobile/models/product.dart';
import 'package:do_an_lap_trinh_mobile/screens/Detail/detail_screen.dart';
import 'package:do_an_lap_trinh_mobile/screens/Home/Widget/product_cart.dart';
import 'package:do_an_lap_trinh_mobile/screens/Home/Widget/search_bar.dart';
import 'Widget/home_app_bar.dart';
import 'Widget/image_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentSlider = 0;
  int selectedIndex = 0;
  List<Category> categories = [];
  List<Product> products = [];
  List<Product> filteredProducts = [];
  List<String> favoriteProductIds = [];
  String? userId; // Lưu userId của người dùng hiện tại

  @override
  void initState() {
    super.initState();
    _getUserId(); // Lấy userId khi khởi tạo
    print('Bắt đầu tải danh mục...');
    _fetchCategories();
    print('Bắt đầu tải danh sách yêu thích...');
    _fetchFavorites();
  }

  Future<void> _getUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    } else {
      print('Không tìm thấy người dùng hiện tại. Vui lòng đăng nhập.');
      // Bạn có thể chuyển hướng đến màn hình đăng nhập nếu cần
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final categorySnapshot =
          await FirebaseFirestore.instance.collection('categories').get();
      print('Số danh mục tìm thấy: ${categorySnapshot.docs.length}');
      setState(() {
        categories =
            categorySnapshot.docs
                .map((doc) => Category.fromJson(doc.data(), doc.id))
                .toList();
        print('Danh mục: ${categories.map((c) => c.name).toList()}');
        if (categories.isNotEmpty) {
          print('Tải sản phẩm cho danh mục: ${categories.first.name}');
          _fetchProducts(categories.first.name);
        } else {
          print('Không có danh mục nào để tải sản phẩm.');
        }
      });
    } catch (e) {
      print('Lỗi khi lấy danh mục: $e');
    }
  }

  Future<void> _fetchProducts(String categoryName) async {
    try {
      print('Truy vấn sản phẩm với category: $categoryName');
      final productSnapshot =
          await FirebaseFirestore.instance
              .collection('products')
              .where('category', isEqualTo: categoryName)
              .get();
      print('Số sản phẩm tìm thấy: ${productSnapshot.docs.length}');
      if (productSnapshot.docs.isNotEmpty) {
        print(
          'Dữ liệu sản phẩm: ${productSnapshot.docs.map((doc) => doc.data()).toList()}',
        );
      }
      setState(() {
        products =
            productSnapshot.docs
                .map((doc) => Product.fromJson(doc.data(), doc.id))
                .toList();
        filteredProducts = products;
        print('Số sản phẩm sau khi parse: ${products.length}');
      });
    } catch (e) {
      print('Lỗi khi lấy sản phẩm: $e');
    }
  }

  Future<void> _fetchFavorites() async {
    if (userId == null) return; // Đảm bảo userId đã được lấy

    try {
      final favoriteSnapshot =
          await FirebaseFirestore.instance
              .collection('favorites')
              .where('userId', isEqualTo: userId) // Lọc theo userId
              .get();
      print('Số sản phẩm yêu thích tìm thấy: ${favoriteSnapshot.docs.length}');
      setState(() {
        favoriteProductIds =
            favoriteSnapshot.docs
                .map((doc) => doc['productId'] as String)
                .toList();
        print('Danh sách productId yêu thích: $favoriteProductIds');
      });
    } catch (e) {
      print('Lỗi khi lấy danh sách yêu thích: $e');
    }
  }

  Future<void> _toggleFavorite(Product product) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để sử dụng tính năng này!'),
        ),
      );
      return;
    }

    try {
      if (favoriteProductIds.contains(product.id)) {
        // Nếu sản phẩm đã được yêu thích, xóa khỏi danh sách yêu thích
        final favoriteSnapshot =
            await FirebaseFirestore.instance
                .collection('favorites')
                .where('productId', isEqualTo: product.id)
                .where('userId', isEqualTo: userId) // Lọc theo userId
                .get();

        for (var doc in favoriteSnapshot.docs) {
          await doc.reference.delete();
        }

        setState(() {
          favoriteProductIds.remove(product.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa khỏi mục yêu thích!')),
        );
      } else {
        // Nếu sản phẩm chưa được yêu thích, thêm vào danh sách yêu thích
        await FirebaseFirestore.instance.collection('favorites').add({
          'userId': userId, // Thêm userId
          'productId': product.id,
          'productName': product.name,
          'productPrice': product.price,
          'productCategory': product.category,
          'productImage': product.image,
        });
        setState(() {
          favoriteProductIds.add(product.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm vào mục yêu thích!')),
        );
      }
    } catch (e) {
      print('Lỗi khi toggle yêu thích: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi thay đổi mục yêu thích!')),
      );
    }
  }

  Future<void> _addToCart(Product product) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để sử dụng tính năng này!'),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('cart').add({
        'userId': userId, // Thêm userId
        'productId': product.id,
        'productName': product.name,
        'productPrice': product.price,
        'productCategory': product.category,
        'productImage': product.image,
        'quantity': 1,
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã thêm vào giỏ hàng!')));
    } catch (e) {
      print('Lỗi khi thêm vào giỏ hàng: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi thêm vào giỏ hàng!')),
      );
    }
  }

  void _onCategorySelected(int index) {
    setState(() {
      selectedIndex = index;
    });
    print('Chọn danh mục: ${categories[index].name}');
    _fetchProducts(categories[index].name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:
          userId == null
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Đợi lấy userId
              : categories.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 35),
                      const CustomAppBar(),
                      const SizedBox(height: 20),
                      const MySearchBar(),
                      const SizedBox(height: 20),
                      ImageSlider(
                        currentSlide: currentSlider,
                        onChange: (value) {
                          setState(() {
                            currentSlider = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildCategoryList(),
                      const SizedBox(height: 20),
                      _buildProductList(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _onCategorySelected(index),
            child: Container(
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color:
                    selectedIndex == index
                        ? Colors.blue[200]
                        : Colors.transparent,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 65,
                    width: 65,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child:
                        categories[index].image != null &&
                                categories[index].image!.isNotEmpty
                            ? ClipOval(
                              child: Image.memory(
                                base64Decode(categories[index].image!),
                                fit: BoxFit.cover,
                                width: 65,
                                height: 65,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.broken_image,
                                    size: 65,
                                  );
                                },
                              ),
                            )
                            : const Icon(Icons.image, size: 65),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 65,
                    child: Text(
                      categories[index].name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Sản phẩm nổi bật",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Text("Xem tất cả", style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
        filteredProducts.isEmpty
            ? const Center(child: Text("Không có sản phẩm nào"))
            : GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(
                  product: filteredProducts[index],
                  isFavorite: favoriteProductIds.contains(
                    filteredProducts[index].id,
                  ),
                  onFavoriteToggle:
                      () => _toggleFavorite(filteredProducts[index]),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                DetailScreen(product: filteredProducts[index]),
                      ),
                    );
                  },
                  onAddToCart: () => _addToCart(filteredProducts[index]),
                );
              },
            ),
      ],
    );
  }
}
