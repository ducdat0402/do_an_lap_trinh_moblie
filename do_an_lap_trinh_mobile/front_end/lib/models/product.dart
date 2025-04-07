class Product {
  final String id;
  final String name;
  final String price;
  final String category;
  final String? image;
  final String? description; // Thêm trường description

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.image,
    this.description, // Thêm vào constructor
  });

  factory Product.fromJson(Map<String, dynamic> json, String id) {
    return Product(
      id: id,
      name: json['name'] ?? '',
      price: json['price']?.toString() ?? '0',
      category: json['category'] ?? '',
      image: json['image'],
      description: json['description'], // Lấy description từ JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'image': image,
      'description': description, // Lưu description vào JSON
    };
  }
}
