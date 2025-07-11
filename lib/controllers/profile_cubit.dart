import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import 'profile_state.dart';
import 'package:path/path.dart' as path;

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  final user = FirebaseAuth.instance.currentUser;
 String imgbbApiKey = '956cd61c1ed32989fb0fd47e0bea22ca';

  Future<void> getProfileData() async {
    try {
      emit(ProfileLoading());
      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      final userModel = UserModel.fromMap(doc.data()!, user!.uid);
      emit(ProfileLoaded(userModel));
    } catch (e) {
      emit(ProfileError('Failed to fetch profile data'));
    }
  }
Future<void> updateName(String name) async {
  try {
    emit(ProfileLoading());
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .update({'name': name});
    
    // Get updated data
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    final updatedUser = UserModel.fromMap(doc.data()!, user!.uid);

    emit(ProfileLoaded(updatedUser));
  } catch (e) {
    emit(ProfileError('Failed to update name'));
  }
}

Future<void> updateImage(File file) async {
  try {
    emit(ProfileLoading());

    final dio = Dio();

    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await dio.post(
      'https://api.imgbb.com/1/upload?key=$imgbbApiKey',
      data: formData,
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final imageUrl = response.data['data']['url'];

      // تحديث رابط الصورة في Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'image': imageUrl});

      await getProfileData();
      emit(ProfileUpdated());
    } else {
      emit(ProfileError('Upload failed: ${response.data['error']['message']}'));
    }
  } catch (e) {
    emit(ProfileError('Failed to upload image: $e'));
  }
}
}
