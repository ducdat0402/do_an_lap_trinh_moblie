import 'dart:convert';
import 'package:flutter/material.dart';

class MyImageSlider extends StatelessWidget {
  final List<String>? images;
  final int currentSlide;
  final ValueChanged<int> onChange;

  const MyImageSlider({
    super.key,
    required this.images,
    required this.currentSlide,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    if (images == null || images!.isEmpty) {
      return const Center(child: Icon(Icons.image, size: 100));
    }

    return SizedBox(
      height: 300,
      child: PageView.builder(
        itemCount: images!.length,
        onPageChanged: onChange,
        itemBuilder: (context, index) {
          return Image.memory(
            base64Decode(images![index]),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Icon(Icons.broken_image, size: 100));
            },
          );
        },
      ),
    );
  }
}
