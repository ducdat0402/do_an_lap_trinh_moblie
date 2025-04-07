import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void _updateUser(String id, String newName, String newEmail) async {
    final updatedData = {'name': newName, 'email': newEmail};
    await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .update(updatedData);
    setState(() {
      _nameController.clear();
      _emailController.clear();
    });
  }

  void _deleteUser(String id) {
    FirebaseFirestore.instance.collection('users').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Người Dùng')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            children:
                snapshot.data!.docs.map((doc) {
                  return ListTile(
                    title: Text(doc['name']),
                    subtitle: Text(doc['email']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _nameController.text = doc['name'];
                            _emailController.text = doc['email'];
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Chỉnh sửa người dùng'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: _nameController,
                                          decoration: const InputDecoration(
                                            labelText: 'Tên người dùng',
                                          ),
                                        ),
                                        TextField(
                                          controller: _emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: const InputDecoration(
                                            labelText: 'Email',
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Hủy'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _updateUser(
                                            doc.id,
                                            _nameController.text.trim(),
                                            _emailController.text.trim(),
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
                          onPressed: () => _deleteUser(doc.id),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }
}
