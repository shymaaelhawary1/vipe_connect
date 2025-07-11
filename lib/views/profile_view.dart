import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vipe_connect/controllers/PostController.dart';
import 'package:vipe_connect/models/PostModel.dart';
import 'package:vipe_connect/views/add_post_screen.dart';
import 'package:vipe_connect/widgets/PostCard.dart';
import '../controllers/profile_cubit.dart';
import '../controllers/profile_state.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final nameController = TextEditingController();
  final picker = ImagePicker();
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit()..getProfileData(),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddPostScreen()),
            );
          },
          backgroundColor: const Color.fromARGB(255, 136, 187, 245),
          child: const Icon(Icons.add),
        ),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is ProfileUpdated) {
              context.read<ProfileCubit>().getProfileData();
              setState(() => isEditing = false);
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProfileLoaded) {
              final user = state.user;
              nameController.text = user.name;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Header
                    ClipPath(
                      clipper: CurvedHeaderClipper(),
                      child: Container(
                        height: 220,
                        color: Colors.blue[800],
                      ),
                    ),

                    Transform.translate(
                      offset: const Offset(0, -50),
                      child: GestureDetector(
                        onTap: () async {
                          final picked = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (picked != null) {
                            await context
                                .read<ProfileCubit>()
                                .updateImage(File(picked.path));
                          }
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: user.image.isNotEmpty
                              ? NetworkImage(user.image)
                              : null,
                          child: user.image.isEmpty
                              ? const Icon(Icons.person,
                                  size: 50, color: Colors.grey)
                              : null,
                        ),
                      ),
                    ),

                    // Name + Edit
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isEditing
                            ? SizedBox(
                                width: 200,
                                child: TextField(
                                  controller: nameController,
                                  style: const TextStyle(fontSize: 20),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              )
                            : Text(
                                user.name,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                        IconButton(
                          icon: Icon(isEditing ? Icons.check : Icons.edit),
                          onPressed: () {
                            if (isEditing) {
                              context
                                  .read<ProfileCubit>()
                                  .updateName(nameController.text.trim());
                            } else {
                              setState(() => isEditing = true);
                            }
                          },
                        )
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Email
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // My Posts
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.lightBlue.shade50,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Center(
                            child: Text(
                              "My Posts",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          StreamBuilder<List<PostModel>>(
                            stream: PostController().getUserPosts(user.uid),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Text("You have no posts yet.");
                              }

                              final posts = snapshot.data!;
                              return Column(
                                children: posts.map((post) {
                                  return PostCard(
                                    post: post,
                                    onLikeTap: () async {
                                      await PostController()
                                          .likePost(post.id, post.likes);
                                    },
                                    currentUserName: user.name,
                                    currentUserImage: user.image,
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              );
            }

            return const Center(child: Text("Something went wrong"));
          },
        ),
      ),
    );
  }
}

class CurvedHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
        size.width / 2, size.height + 30, size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
