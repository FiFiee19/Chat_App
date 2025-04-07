import 'package:chat_app/screens/chat_messages.dart';
import 'package:chat_app/screens/new_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setupPushNotifications() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    fcm.subscribeToTopic('chat');
  }

  @override
  void initState() {
    super.initState();

    setupPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'ChitChat',
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 25, color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 142, 114, 158),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
          backgroundColor: Color.fromARGB(255, 228, 155, 179),
        ),
        body: Column(
          children: [Expanded(child: ChatMessages()), NewMessage()],
        ));
  }
}
