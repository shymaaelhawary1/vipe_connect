import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vipe_connect/controllers/chat_controller.dart';
import 'package:vipe_connect/models/message_model.dart';
import 'package:vipe_connect/models/user_model.dart';

class ChatScreen extends StatefulWidget {
  final UserModel otherUser;

  const ChatScreen({super.key, required this.otherUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _chatController = ChatController();
  final _currentUser = FirebaseAuth.instance.currentUser!;
  final ScrollController _scrollController = ScrollController();

  late final String chatId;

  @override
  void initState() {
    super.initState();
    chatId = _chatController.getChatId(_currentUser.uid, widget.otherUser.uid);
  }

  void _sendMessage() {
    final msg = _controller.text.trim();
    if (msg.isEmpty) return;

    final message = MessageModel(
      senderId: _currentUser.uid,
      text: msg,
      timestamp: DateTime.now(),
      isRead: false,
    );

    _chatController.sendMessage(chatId, message);
    _controller.clear();

    // Scroll to bottom after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUser.name),
        backgroundColor: Colors.blue[800],
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatController.getMessages(chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                final reversed = messages.reversed.toList();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  itemCount: reversed.length,
                  itemBuilder: (context, index) {
                    final msg = reversed[index];
                    final isMe = msg.senderId == _currentUser.uid;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[300] : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: Radius.circular(isMe ? 12 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 12),
                          ),
                        ),
                        child: Text(
                          msg.text,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
