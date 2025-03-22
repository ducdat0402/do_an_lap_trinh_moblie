class Category {
  final String title;
  final String image;

  Category({required this.title, required this.image});
}

final List<Category> categories = [
  Category(title: "Shoes", image: "images/logo3.png"),
  Category(title: "Beauty", image: "images/logo2.png"),
  Category(title: "women's\nFashion", image: "images/logo7.jpg"),
  Category(title: "man's\nFashion", image: "images/logo7.jpg"),
  Category(title: "man's\nShoes", image: "images/logo7.jpg"),
];
