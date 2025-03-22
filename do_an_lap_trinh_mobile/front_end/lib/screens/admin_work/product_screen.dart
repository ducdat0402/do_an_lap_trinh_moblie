import 'package:do_an_lap_trinh_mobile/screens/admin_work/account_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:do_an_lap_trinh_mobile/constants.dart';

class ProductsScreen extends StatelessWidget {
  final String category;
  final ProductController productController = Get.find();

  ProductsScreen({required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kcontentColor,
      appBar: AppBar(title: Text("Sản phẩm - $category"), centerTitle: true),
      body: Obx(() {
        if (productController.filteredProducts.isEmpty) {
          return Center(
            child: Text(
              "Không có sản phẩm nào trong danh mục này",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: productController.filteredProducts.length,
          itemBuilder: (context, index) {
            final product = productController.filteredProducts[index];
            return Padding(
              padding: const EdgeInsets.all(15),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      height: 85,
                      width: 85,
                      decoration: BoxDecoration(
                        color: kcontentColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        product.image,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error, color: Colors.red);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "\$${product.price}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
