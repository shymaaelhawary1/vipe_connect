import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:vipe_connect/models/PostModel.dart';

class PostController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<String?> uploadImageToImgbb(File imageFile) async {
    const apiKey = '956cd61c1ed32989fb0fd47e0bea22ca'; // ✅ حطي API Key هنا
    const url = 'https://api.imgbb.com/1/upload';

    try {
      final formData = FormData.fromMap({
        'key': apiKey,
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: path.basename(imageFile.path),
        ),
      });

      final response = await Dio().post(url, data: formData);

      if (response.statusCode == 200) {
        return response.data['data']['url'];
      }
    } catch (e) {
      print("Upload error: $e");
    }
    return null;
  }

  Future<void> addPost({
    required String caption,
    required File imageFile,
  }) async {
    final userId = _auth.currentUser!.uid;
    final imageUrl = await uploadImageToImgbb(imageFile);

    if (imageUrl == null) throw Exception("Image upload failed");

    final newPost = PostModel(
      id: '',
      userId: userId,
      caption: caption,
      imageUrl: imageUrl,
      likes: 0,
      comments: <Map<String, dynamic>>[],
    );

    await _firestore.collection('posts').add(newPost.toMap());
  }

  Stream<List<PostModel>> getUserPosts(String userId) {
    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<PostModel>> getAllPosts() {
    return _firestore.collection('posts').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => PostModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<void> likePost(String postId, int currentLikes) async {
    await FirebaseFirestore.instance
        .collection("posts")
        .doc(postId)
        .update({"likes": currentLikes + 1});
  }

  Future<void> addComment(String postId, String comment) async {
    final docRef = _firestore.collection('posts').doc(postId);
    final doc = await docRef.get();

    if (doc.exists) {
      List<dynamic> currentComments = doc['comments'] ?? [];
      currentComments.add(comment);

      await docRef.update({'comments': currentComments});
    }
  }

  Future<void> updateComments(String postId, List<dynamic> comments) async {
    await FirebaseFirestore.instance
        .collection("posts")
        .doc(postId)
        .update({"comments": comments});
  }
}
