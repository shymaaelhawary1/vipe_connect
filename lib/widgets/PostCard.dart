import 'package:flutter/material.dart';
import 'package:vipe_connect/controllers/PostController.dart';
import 'package:vipe_connect/models/PostModel.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onLikeTap;
  final String currentUserName;
  final String currentUserImage;

  const PostCard({
    super.key,
    required this.post,
    this.onLikeTap,
    required this.currentUserName,
    required this.currentUserImage,
  });

  void _showCommentsBottomSheet(BuildContext context) {
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
                          final newComment = {
                            "text": commentController.text.trim(),
                            "userName": currentUserName,
                            "userImage": currentUserImage,
                          };

                          if (newComment['text']!.isNotEmpty) {
                            post.comments.add(newComment);
                            await PostController().updateComments(
                              post.id,
                              post.comments,
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: const Text("Send"),
                      )
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Caption
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              post.caption,
              style: const TextStyle(fontSize: 16),
            ),
          ),

          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: Image.network(
              post.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Likes and Comments
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onLikeTap,
                  child: const Icon(Icons.favorite_border, color: Colors.red),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _showCommentsBottomSheet(context),
                  child: const Icon(Icons.comment_outlined, color: Colors.blue),
                ),
                const SizedBox(width: 10),
                Text("${post.likes} likes"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
