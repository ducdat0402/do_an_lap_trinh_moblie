import 'package:do_an_lap_trinh_mobile/models/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartProvider extends ChangeNotifier {
  final List<Product> _cart = [];
  List<Product> get cart => _cart;

  void toggleFavorite(Product product) {
    if (_cart.contains(product)) {
      for (Product element in _cart) {
        element.quantity++;
      }
    } else {
      _cart.add(product);
    }
    notifyListeners();
  }

  void removeItem(int index) {
    cart.removeAt(index);
    notifyListeners(); // Thông báo UI cập nhật
  }

  void incrementQtn(int index) {
    _cart[index].quantity++;
    notifyListeners(); // Cập nhật lại giá và giao diện
  }

  void decrementQtn(int index) {
    if (_cart[index].quantity > 1) {
      _cart[index].quantity--;
      notifyListeners(); // Cập nhật lại giá và giao diện
    } else {
      _cart.removeAt(index); // Xóa sản phẩm nếu số lượng là 0
      notifyListeners();
    }
  }

  double totalPrice() {
    double total = 0.0;
    for (Product element in _cart) {
      total += element.price * element.quantity;
    }
    return total;
  }

  static CartProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<CartProvider>(context, listen: listen);
  }
}
