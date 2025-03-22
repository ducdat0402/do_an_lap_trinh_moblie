import 'package:do_an_lap_trinh_mobile/constants.dart';
import 'package:do_an_lap_trinh_mobile/models/product.dart';
import 'package:do_an_lap_trinh_mobile/screens/Detail/detail_app_bar.dart';
import 'package:do_an_lap_trinh_mobile/screens/Detail/image_slider.dart';
import 'package:do_an_lap_trinh_mobile/screens/Detail/items_details.dart';
import 'package:do_an_lap_trinh_mobile/screens/Home/Widget/addto_cart.dart';
import 'package:do_an_lap_trinh_mobile/screens/Home/Widget/description.dart';
import 'package:flutter/material.dart';

class DetailScreen extends StatefulWidget {
  final Product product;
  const DetailScreen({super.key, required this.product});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int currentImage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kcontentColor,
      //thêm vào giỏ hàng
      floatingActionButton: AddToCart(product: widget.product),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: Column(
          children: [
            /// Back button
            DetailAppBar(product: widget.product),

            /// Image slider
            MyImageSlider(
              image: widget.product.image,
              onChange: (index) {
                setState(() {
                  currentImage = index;
                });
              },
            ),

            /// Image indicator dots
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 300,
                  ), // Sửa từ microseconds -> milliseconds
                  width: currentImage == index ? 15 : 8,
                  height: 8,
                  margin: EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:
                        currentImage == index
                            ? Colors.black
                            : Colors.transparent,
                    border: Border.all(color: Colors.black),
                  ),
                ),
              ),
            ),

            /// Nội dung cuộn được
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(40),
                    topLeft: Radius.circular(40),
                  ),
                ),
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 100,
                ),

                /// Dùng SingleChildScrollView để cuộn
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ItemsDetails(product: widget.product),
                      SizedBox(height: 20),
                      Description(description: widget.product.description),
                    ],
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
