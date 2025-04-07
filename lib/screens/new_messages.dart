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

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (userData.exists) {
      final userMap = userData.data();
      final username = userMap?['username'] ?? 'Unknown User';
      final userImage = userMap?['image_url'] ?? '';

      FirebaseFirestore.instance.collection('chat').add({
        'text': enterdMessage,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'username': username,
        'userImage': userImage
      });
    } else {
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
            decoration: const InputDecoration(
              fillColor: Color.fromARGB(255, 228, 228, 228),
              filled: true,
              labelText: 'Send a message...',
              labelStyle: TextStyle(
                  fontSize: 14, color: Color.fromARGB(255, 126, 126, 126)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
            ),
          )),
          IconButton(
              onPressed: _submitMessage,
              icon: Icon(Icons.send),
              color: const Color.fromARGB(
                255,
                142,
                114,
                158,
              ))
        ],
      ),
    );
  }
}
