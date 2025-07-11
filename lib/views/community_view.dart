import 'package:flutter/material.dart';
import 'package:vipe_connect/controllers/PostController.dart';
import 'package:vipe_connect/widgets/PostCard.dart';
import 'package:vipe_connect/models/PostModel.dart';

class CommunityView extends StatelessWidget {
  const CommunityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<PostModel>>(
          stream: PostController().getAllPosts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No posts yet"));
            }

            final posts = snapshot.data!;
            return Column(
              children: [
                const Text(
                  "Community Posts",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(221, 9, 20, 233),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return PostCard(
                        post: post,
                        onLikeTap: () async {
                          await PostController().likePost(post.id, post.likes);
                        },
                        currentUserName:
                            "Shaimaa El Hawary", // TODO: get actual user
                        currentUserImage:
                            "https://your-default-image.com/profile.png", // TODO: get actual image
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
