import 'package:do_an_lap_trinh_mobile/Provider/cart_provider.dart';
import 'package:do_an_lap_trinh_mobile/constants.dart';
import 'package:do_an_lap_trinh_mobile/models/product.dart';
import 'package:flutter/material.dart';

class AddToCart extends StatefulWidget {
  final Product product;
  const AddToCart({super.key, required this.product});

  @override
  State<AddToCart> createState() => _AddToCartState();
}

class _AddToCartState extends State<AddToCart> {
  int currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final provider = CartProvider.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10), // Giảm padding tổng thể
      child: Container(
        height: 70, // Giảm chiều cao (trước là 85)
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40), // Giảm bán kính bo tròn
          color: Colors.black,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
        ), // Giảm padding ngang
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Giảm kích thước -1 và +1
            Container(
              height: 35, // Giảm chiều cao của khung số lượng
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), // Giảm bo tròn
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ), // Giảm độ dày viền
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (currentIndex != 1) {
                        setState(() {
                          currentIndex--;
                        });
                      }
                    },
                    iconSize: 16, // Giảm kích thước icon
                    padding: EdgeInsets.zero, // Loại bỏ padding mặc định
                    constraints: BoxConstraints(), // Giúp giữ icon nhỏ gọn hơn
                    icon: const Icon(Icons.remove, color: Colors.white),
                  ),
                  Text(
                    currentIndex.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14, // Giảm font size
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        currentIndex++;
                      });
                    },
                    iconSize: 16, // Giảm kích thước icon
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    icon: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ),

            /// Giảm kích thước nút "Thêm vào giỏ hàng"
            GestureDetector(
              onTap: () {
                provider.toggleFavorite(widget.product);
                const snackBar = SnackBar(
                  content: Text(
                    "thêm vào giỏ hàng thành công",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                  duration: Duration(seconds: 1),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: Container(
                height: 45, // Giảm chiều cao (trước là 55)
                decoration: BoxDecoration(
                  color: kprimaryColor,
                  borderRadius: BorderRadius.circular(25), // Giảm bo tròn
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                ), // Giảm padding ngang
                child: Text(
                  "Thêm vào giỏ hàng",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14, // Giảm font size
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
