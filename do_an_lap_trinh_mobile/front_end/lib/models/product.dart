import 'package:flutter/material.dart';

class Product {
  final String title;
  final String description;
  final String image;
  final String review;
  final String seller;
  final double price;
  final List<Color> colors;
  final String category;
  final double rate;
  int quantity;

  Product({
    required this.title,
    required this.review,
    required this.description,
    required this.image,
    required this.price,
    required this.colors,
    required this.seller,
    required this.category,
    required this.rate,
    required this.quantity,
  });
}

final List<Product> Shoes = [
  Product(
    title: "Wireless Headphones",
    description:
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeqweqqewqewqewqeqweqweqweqweqweqeqewq..",
    image: "images/slider3.png",
    price: 120,
    seller: "Tariqul Islam",
    colors: [Colors.black, Colors.blue, Colors.orange],
    category: "Electronics",
    review: "(320 Reviews)",
    rate: 4.0,
    quantity: 1,
  ),
  Product(
    title: "Wireless Headphones",
    description:
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor...",
    image: "images/slider.png",
    price: 120,
    seller: "Tariqul Islam",
    colors: [Colors.black, Colors.blue, Colors.orange],
    category: "Shoes",
    review: "(320 Reviews)",
    rate: 4.0,
    quantity: 1,
  ),
  Product(
    title: "Wireless Headphones",
    description:
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor...",
    image: "images/slider2.png",
    price: 120,
    seller: "Tariqul Islam",
    colors: [Colors.black, Colors.blue, Colors.orange],
    category: "Beauty",
    review: "(320 Reviews)",
    rate: 4.0,
    quantity: 1,
  ),
];

final List<Product> all = [
  Product(
    title: "Smart Watch",
    description:
        "A stylish smart watch with various health tracking features...",
    image: "images/logo2.png",
    price: 150,
    seller: "John Doe",
    colors: [Colors.black, Colors.white, Colors.red],
    category: "Electronics",
    review: "(280 Reviews)",
    rate: 4.5,
    quantity: 1,
  ),
  Product(
    title: "Bluetooth Speaker",
    description:
        "A powerful Bluetooth speaker with deep bass and clear sound...",
    image: "images/logo3.png",
    price: 80,
    seller: "Jane Smith",
    colors: [Colors.black, Colors.blue, Colors.green],
    category: "Electronics",
    review: "(150 Reviews)",
    rate: 4.2,
    quantity: 1,
  ),
];
