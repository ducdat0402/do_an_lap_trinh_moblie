import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _nameController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Hàm chuyển hình ảnh thành Base64
  String? _imageToBase64(File? image) {
    if (image == null) return null;
    final bytes = image.readAsBytesSync();
    return base64Encode(bytes);
  }

  void _addCategory() async {
    if (_nameController.text.isNotEmpty && _imageFile != null) {
      String? imageBase64 = _imageToBase64(_imageFile);

      await FirebaseFirestore.instance.collection('categories').add({
        'name': _nameController.text.trim(),
        'image': imageBase64, // Lưu chuỗi Base64 trực tiếp vào Firestore
      });

      _nameController.clear();
      setState(() {
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

  void _updateCategory(String id, String newName) async {
    final updatedData = {'name': newName};

    if (_imageFile != null) {
      String? imageBase64 = _imageToBase64(_imageFile);
      updatedData['image'] = imageBase64!;
    }

    await FirebaseFirestore.instance
        .collection('categories')
        .doc(id)
        .update(updatedData);

    // Đặt lại các trường sau khi lưu
    setState(() {
      _nameController.clear();
      _imageFile = null;
    });
  }

  void _deleteCategory(String id) {
    FirebaseFirestore.instance.collection('categories').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Danh Mục')),
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
                      labelText: 'Tên danh mục',
                    ),
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
            ElevatedButton(onPressed: _addCategory, child: const Text('Thêm')),
            SizedBox(
              height: 400,
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance
                        .collection('categories')
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
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _nameController.text = doc['name'];
                                    setState(() {
                                      _imageFile = null;
                                    });
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: const Text(
                                              'Chỉnh sửa danh mục',
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
                                                              'Tên danh mục',
                                                        ),
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
                                                  _updateCategory(
                                                    doc.id,
                                                    _nameController.text.trim(),
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
                                  onPressed: () => _deleteCategory(doc.id),
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
