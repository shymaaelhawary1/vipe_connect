import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:vipe_connect/controllers/chat_controller.dart';
import 'package:vipe_connect/models/user_model.dart';
import 'package:vipe_connect/views/chat_view.dart';

class ChatUsersScreen extends StatelessWidget {
  final _chatController = ChatController();
  final _currentUser = FirebaseAuth.instance.currentUser!;

  ChatUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text(
          "All Users",
          style: TextStyle(color: Colors.blue),
        )),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _chatController.getUsersWithLastMessage(_currentUser.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());

            final userList = snapshot.data!;
            if (userList.isEmpty)
              return const Center(child: Text("No users found"));

            return ListView.builder(
              itemCount: userList.length,
              itemBuilder: (context, index) {
                final user = userList[index]['user'] as UserModel;
                final lastMessage = userList[index]['lastMessage'];
                final isRead = lastMessage?['isRead'] ?? true;
                final timestamp = lastMessage?['timestamp']?.toDate();

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.image),
                  ),
                  title: Text(
                    user.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    lastMessage != null
                        ? lastMessage['text']
                        : "No messages yet",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      color: isRead ? Colors.grey[700] : Colors.black,
                    ),
                  ),
                  trailing: lastMessage != null
                      ? Text(
                          DateFormat.jm().format(timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: isRead ? Colors.grey : Colors.blueAccent,
                          ),
                        )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(otherUser: user),
                      ),
                    );
                  },
                );
              },
            );
          },
        ));
  }
}
