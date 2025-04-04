import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var _messageController = TextEditingController();
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
  final enterdMessage = _messageController.text;

  if (enterdMessage.trim().isEmpty) {
    return;
  }

  FocusScope.of(context).unfocus();
  _messageController.clear();

  final user = FirebaseAuth.instance.currentUser;

  // ตรวจสอบว่าผู้ใช้มีข้อมูลใน Firestore หรือไม่
  final userData = await FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid)
      .get();

  // ตรวจสอบว่า data() ไม่เป็น null และให้ค่าผลลัพธ์ที่เหมาะสม
  if (userData.exists) {
    final userMap = userData.data();
    final username = userMap?['username'] ?? 'Unknown User'; // ใช้ค่า default หากไม่พบ 'username'
    final userImage = userMap?['image_url'] ?? ''; // ใช้ค่า default หากไม่พบ 'image_url'

    // ส่งข้อมูลไปยัง collection 'chat'
    FirebaseFirestore.instance.collection('chat').add({
      'text': enterdMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': username, // ใช้ username จาก Firestore
      'userImage': userImage // ใช้ image_url จาก Firestore
    });
  } else {
    // หากไม่พบข้อมูลใน Firestore
    print('User data not found!');
  }

  
}


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            controller: _messageController,
            textCapitalization: TextCapitalization.sentences,
            autocorrect: true,
            enableSuggestions: true,
            decoration: InputDecoration(labelText: 'Send a message...'),
          )),
          IconButton(onPressed: _submitMessage, icon: Icon(Icons.send))
        ],
      ),
    );
  }
}
