import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vipe_connect/controllers/PostController.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final captionController = TextEditingController();
  final picker = ImagePicker();
  File? selectedImage;
  bool isLoading = false;
  final controller = PostController();

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  Future<void> submitPost() async {
    if (captionController.text.isEmpty || selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add caption and image")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await controller.addPost(
        caption: captionController.text.trim(),
        imageFile: selectedImage!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post added successfully")),
      );

      setState(() {
        captionController.clear();
        selectedImage = null;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Post")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: captionController,
              decoration: const InputDecoration(labelText: "Caption"),
            ),
            const SizedBox(height: 10),
            selectedImage != null
                ? Image.file(selectedImage!, height: 150)
                : const Text("No image selected"),
            TextButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Select Image"),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: submitPost,
                    child: const Text("Publish"),
                  )
          ],
        ),
      ),
    );
  }
}
