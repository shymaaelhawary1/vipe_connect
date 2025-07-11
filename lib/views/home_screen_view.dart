import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vipe_connect/views/add_post_screen.dart';
import 'package:vipe_connect/models/PostModel.dart';
import 'package:vipe_connect/widgets/PostCard.dart';
import 'package:vipe_connect/controllers/PostController.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String userName = "";

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    setState(() {
      userName = doc.data()?['name'] ?? '';
    });
  }

  final List<String> carouselImages = [
    'https://img.freepik.com/free-vector/chat-concept-illustration_114360-1630.jpg',
    'https://img.freepik.com/free-vector/share-concept-illustration_114360-555.jpg',
    'https://img.freepik.com/free-vector/hello-concept-illustration_114360-1183.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome
          Text(
            "Welcome, $userName 👋",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 10),

          // Carousel Slider
          CarouselSlider(
            options: CarouselOptions(
              height: 180,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.85,
              autoPlayInterval: const Duration(seconds: 3),
            ),
            items: carouselImages.map((imageUrl) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Add Post Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPostScreen()),
                );
              },
              icon: const Icon(Icons.add , color: Colors.white  ),
              label: const Text(
                "Add a New Post",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: const Color.fromARGB(255, 92, 157, 232),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // My Recent Posts
          const Text(
            "My Recent Posts",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(221, 9, 20, 233),
            ),
          ),
          const SizedBox(height: 10),

          StreamBuilder<List<PostModel>>(
            stream: PostController().getUserPosts(user!.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text("You haven't posted anything yet."),
                );
              }

              final posts = snapshot.data!;
              return Column(
                children: posts.map((post) {
                  return PostCard(
                    post: post,
                    onLikeTap: () async {
                      await PostController().likePost(post.id, post.likes);
                    },
                    currentUserName: userName,
                    currentUserImage:
                        "https://cdn-icons-png.flaticon.com/512/149/149071.png", // يمكن تغييره بصورة المستخدم الفعلية
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
