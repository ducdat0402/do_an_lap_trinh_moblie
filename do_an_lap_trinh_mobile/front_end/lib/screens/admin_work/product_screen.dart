import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // Import thư viện intl

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;
  List<String> _categories = [];
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      _categories = snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  String? _imageToBase64(File? image) {
    if (image == null) return null;
    final bytes = image.readAsBytesSync();
    return base64Encode(bytes);
  }

  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(amount);
  }

  void _addProduct() async {
    if (_nameController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _selectedCategory != null &&
        _imageFile != null) {
      String? imageBase64 = _imageToBase64(_imageFile);

      await FirebaseFirestore.instance.collection('products').add({
        'name': _nameController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'category': _selectedCategory,
        'image': imageBase64,
        'description': _descriptionController.text.trim(),
      });

      _nameController.clear();
      _priceController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedCategory = null;
        _imageFile = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin và chọn hình ảnh'),
        ),
      );
    }
  }

  void _updateProduct(
    String id,
    String newName,
    double newPrice,
    String newCategory,
    String newDescription,
  ) async {
    final updatedData = {
      'name': newName,
      'price': newPrice,
      'category': newCategory,
      'description': newDescription,
    };

    if (_imageFile != null) {
      String? imageBase64 = _imageToBase64(_imageFile);
      updatedData['image'] = imageBase64!;
    }

    await FirebaseFirestore.instance
        .collection('products')
        .doc(id)
        .update(updatedData);

    setState(() {
      _nameController.clear();
      _priceController.clear();
      _descriptionController.clear();
      _selectedCategory = null;
      _imageFile = null;
    });
  }

  void _deleteProduct(String id) {
    FirebaseFirestore.instance.collection('products').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Sản Phẩm')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên sản phẩm',
                    ),
                  ),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Giá sản phẩm',
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    hint: const Text('Chọn danh mục'),
                    items:
                        _categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Danh mục'),
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Mô tả sản phẩm',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  _imageFile != null
                      ? Image.file(
                        _imageFile!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      )
                      : const Text('Chưa chọn hình ảnh'),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Chọn hình ảnh'),
                  ),
                ],
              ),
            ),
            ElevatedButton(onPressed: _addProduct, child: const Text('Thêm')),
            SizedBox(
              height: 400,
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance
                        .collection('products')
                        .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView(
                    children:
                        snapshot.data!.docs.map((doc) {
                          return ListTile(
                            leading:
                                doc.data() != null &&
                                        (doc.data() as Map<String, dynamic>)
                                            .containsKey('image') &&
                                        (doc.data()
                                                as Map<
                                                  String,
                                                  dynamic
                                                >)['image'] !=
                                            null
                                    ? Image.memory(
                                      base64Decode(
                                        (doc.data()
                                            as Map<String, dynamic>)['image'],
                                      ),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return const Icon(
                                          Icons.broken_image,
                                          size: 50,
                                        );
                                      },
                                    )
                                    : const Icon(Icons.image, size: 50),
                            title: Text(doc['name']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Giá: ${formatCurrency(double.tryParse(doc['price'].toString()) ?? 0.0)} | Danh mục: ${(doc.data() as Map<String, dynamic>).containsKey('category') ? doc['category'] : 'Chưa có'}',
                                ),
                                Text(
                                  'Mô tả: ${(doc.data() as Map<String, dynamic>).containsKey('description') ? doc['description'] : 'Chưa có mô tả'}',
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _nameController.text = doc['name'];
                                    _priceController.text =
                                        doc['price'].toString();
                                    _descriptionController.text =
                                        (doc.data() as Map<String, dynamic>)
                                                .containsKey('description')
                                            ? doc['description']
                                            : '';
                                    _selectedCategory =
                                        (doc.data() as Map<String, dynamic>)
                                                .containsKey('category')
                                            ? doc['category']
                                            : null;
                                    setState(() {
                                      _imageFile = null;
                                    });
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: const Text(
                                              'Chỉnh sửa sản phẩm',
                                            ),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    controller: _nameController,
                                                    decoration:
                                                        const InputDecoration(
                                                          labelText:
                                                              'Tên sản phẩm',
                                                        ),
                                                  ),
                                                  TextField(
                                                    controller:
                                                        _priceController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration:
                                                        const InputDecoration(
                                                          labelText:
                                                              'Giá sản phẩm',
                                                        ),
                                                  ),
                                                  DropdownButtonFormField<
                                                    String
                                                  >(
                                                    value: _selectedCategory,
                                                    hint: const Text(
                                                      'Chọn danh mục',
                                                    ),
                                                    items:
                                                        _categories.map((
                                                          category,
                                                        ) {
                                                          return DropdownMenuItem<
                                                            String
                                                          >(
                                                            value: category,
                                                            child: Text(
                                                              category,
                                                            ),
                                                          );
                                                        }).toList(),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _selectedCategory =
                                                            value;
                                                      });
                                                    },
                                                    decoration:
                                                        const InputDecoration(
                                                          labelText: 'Danh mục',
                                                        ),
                                                  ),
                                                  TextField(
                                                    controller:
                                                        _descriptionController,
                                                    decoration:
                                                        const InputDecoration(
                                                          labelText:
                                                              'Mô tả sản phẩm',
                                                        ),
                                                    maxLines: 3,
                                                  ),
                                                  const SizedBox(height: 10),
                                                  _imageFile != null
                                                      ? Image.file(
                                                        _imageFile!,
                                                        height: 100,
                                                        width: 100,
                                                        fit: BoxFit.cover,
                                                      )
                                                      : (doc.data()
                                                              as Map<
                                                                String,
                                                                dynamic
                                                              >)
                                                          .containsKey('image')
                                                      ? Image.memory(
                                                        base64Decode(
                                                          (doc.data()
                                                              as Map<
                                                                String,
                                                                dynamic
                                                              >)['image'],
                                                        ),
                                                        height: 100,
                                                        width: 100,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return const Text(
                                                            'Lỗi tải hình ảnh',
                                                          );
                                                        },
                                                      )
                                                      : const Text(
                                                        'Chưa có hình ảnh',
                                                      ),
                                                  ElevatedButton(
                                                    onPressed: _pickImage,
                                                    child: const Text(
                                                      'Chọn hình ảnh',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () =>
                                                        Navigator.pop(context),
                                                child: const Text('Hủy'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  _updateProduct(
                                                    doc.id,
                                                    _nameController.text.trim(),
                                                    double.parse(
                                                      _priceController.text
                                                          .trim(),
                                                    ),
                                                    _selectedCategory ??
                                                        'Chưa chọn',
                                                    _descriptionController.text
                                                        .trim(),
                                                  );
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Lưu'),
                                              ),
                                            ],
                                          ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteProduct(doc.id),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
