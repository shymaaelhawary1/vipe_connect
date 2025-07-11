// class UserModel {
//   final String uid;
//   final String name;
//   final String email;
//   final String image;

//   UserModel({
//     required this.uid,
//     required this.name,
//     required this.email,
//     required this.image,
//   });

//   factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
//     return UserModel(
//       uid: uid,
//       name: map['name'] ?? '',
//       email: map['email'] ?? '',
//       image: map['image'] ?? '',
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'email': email,
//       'image': image,
//     };
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String image;
  final bool isOnline;
  final DateTime lastSeen;
  final String bio;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.image,
    required this.isOnline,
    required this.lastSeen,
    required this.bio,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      image: map['image'] ?? '',
      isOnline: map['isOnline'] ?? false,
      lastSeen: (map['lastSeen'] as Timestamp?)?.toDate() ?? DateTime.now(),
      bio: map['bio'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'image': image,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'bio': bio,
    };
  }
}
