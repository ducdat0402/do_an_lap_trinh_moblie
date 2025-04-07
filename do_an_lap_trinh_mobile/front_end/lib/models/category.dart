class Category {
  final String id;
  final String name; // Thay title thành name
  final String? image;

  Category({required this.id, required this.name, this.image});

  factory Category.fromJson(Map<String, dynamic> json, String docId) {
    return Category(
      id: docId,
      name: json['name'] ?? '', // Sử dụng name thay vì title
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'image': image};
  }
}
