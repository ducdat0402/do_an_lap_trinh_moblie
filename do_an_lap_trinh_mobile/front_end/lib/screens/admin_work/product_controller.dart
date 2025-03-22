import 'package:get/get.dart';
import 'package:do_an_lap_trinh_mobile/models/product.dart';

class ProductController extends GetxController {
  var allProducts = <Product>[].obs;
  var filteredProducts = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts(); // Lấy dữ liệu ban đầu
  }

  void fetchProducts() {
    allProducts.assignAll(all); // all là danh sách sản phẩm có sẵn
    filteredProducts.assignAll(allProducts); // Mặc định hiển thị tất cả
  }

  void filterByCategory(String category) {
    if (category == "all") {
      filteredProducts.assignAll(allProducts); // Hiển thị tất cả
    } else {
      filteredProducts.assignAll(
        allProducts.where((product) => product.category == category).toList(),
      );
    }
  }
}
