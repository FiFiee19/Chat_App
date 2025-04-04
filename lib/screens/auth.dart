import 'dart:io';

import 'package:chat_app/screens/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  var _isLogin = true;
  var _enterdEmail = '';
  var _enterdPassword = '';
  File? _selectedImage;
  var _isAuthenticating = false;

  Future<void> _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid || (!_isLogin && _selectedImage == null)) {
      return;
    }

    _form.currentState!.save();
    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: _enterdEmail, password: _enterdPassword);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enterdEmail, password: _enterdPassword);

        // บันทึกรูปภาพหากผู้ใช้เลือก
        File? imageFile;
        if (_selectedImage != null) {
          final directory = await getApplicationDocumentsDirectory();
          final String fileName =
              userCredentials.user!.uid; // ใช้ UID ของผู้ใช้
          imageFile = await File(_selectedImage!.path)
              .copy('${directory.path}/$fileName');
        } else {
          // ใช้ default image path ที่เก็บไว้ใน assets
          imageFile = File('assets/images/default.png');
        }

        // ลองพิมพ์ไฟล์ที่ถูกเก็บไว้เพื่อดูผลลัพธ์
        print('Image saved at: ${imageFile.path}');

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': 'to be done ...',
          'email': _enterdEmail,
          'image_url': imageFile
        });
      }

      // แสดงข้อความหลังจากการสมัครสำเร็จ
      // ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Account created successfully!')));
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        // คุณสามารถแสดงข้อความที่เหมาะสมให้ผู้ใช้ทราบได้
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('This email is already in use.')));
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message ?? 'Authentication failed.')));
      }
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
                width: 200,
                child: Image.asset('assets/images/logo.png'),
              ),
              Card(
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            UserImagePicker(
                              onPickImage: (pickedImage) {
                                _selectedImage = pickedImage;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Email Address'),
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email address.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enterdEmail = value!;
                            },
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be at least 6 characters long.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enterdPassword = value!;
                            },
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          if (_isAuthenticating) CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: () {
                                _submit();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary),
                              child: Text(
                                _isLogin ? 'Login' : 'Signup',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(_isLogin
                                  ? 'Create an account'
                                  : 'I already have an account'))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
