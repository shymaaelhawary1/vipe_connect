import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vipe_connect/models/user_model.dart';
import '../models/message_model.dart';

class ChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String getChatId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '$uid1\_$uid2' : '$uid2\_$uid1';
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> sendMessage(String chatId, MessageModel message) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());
  }

  Stream<List<UserModel>> getAllUsers(String currentUid) {
    return _firestore.collection('users').snapshots().map(
          (snapshot) => snapshot.docs
              .where((doc) => doc.id != currentUid)
              .map((doc) => UserModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<List<Map<String, dynamic>>> getUsersWithLastMessage(
      String currentUid) async {
    final snapshot = await _firestore.collection('users').get();
    List<Map<String, dynamic>> result = [];

    for (var doc in snapshot.docs) {
      if (doc.id == currentUid) continue;

      final otherUser = UserModel.fromMap(doc.data(), doc.id);
      final chatId = getChatId(currentUid, doc.id);

      final lastMsgSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      final lastMsg = lastMsgSnapshot.docs.isNotEmpty
          ? lastMsgSnapshot.docs.first.data()
          : null;

      result.add({
        'user': otherUser,
        'lastMessage': lastMsg,
      });
    }

    return result;
  }
}
