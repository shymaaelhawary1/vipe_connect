import 'package:flutter/material.dart';
import 'package:vipe_connect/controllers/PostController.dart';
import 'package:vipe_connect/models/PostModel.dart';

void showCommentsBottomSheet({
  required BuildContext context,
  required PostModel post,
  required String currentUserName,
  required String currentUserImage,
}) {
  final TextEditingController commentController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  "Comments",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: post.comments.length,
                    itemBuilder: (context, index) {
                      final comment = post.comments[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: comment['userImage'] != null
                              ? NetworkImage(comment['userImage'])
                              : null,
                          child: comment['userImage'] == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(
                          comment['userName'] ?? 'Anonymous',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(comment['text'] ?? ''),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: "Write a comment...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final text = commentController.text.trim();
                        if (text.isNotEmpty) {
                          final newComment = {
                            "text": text,
                            "userName": currentUserName,
                            "userImage": currentUserImage,
                          };
                          post.comments.add(newComment);
                          await PostController()
                              .updateComments(post.id, post.comments);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Send"),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
