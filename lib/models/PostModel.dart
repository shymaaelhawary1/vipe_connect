class PostModel {
  final String id;
  final String userId;
  final String caption;
  final String imageUrl;
  final int likes;
  final List<Map<String, dynamic>> comments;

  PostModel({
    required this.id,
    required this.userId,
    required this.caption,
    required this.imageUrl,
    required this.likes,
    required this.comments,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'caption': caption,
      'imageUrl': imageUrl,
      'likes': likes,
      'comments': comments,
    };
  }
factory PostModel.fromMap(Map<String, dynamic> map, String id) {
  final rawComments = map['comments'] as List? ?? [];

  final safeComments = rawComments.map((comment) {
    if (comment is Map<String, dynamic>) {
      return comment;
    } else if (comment is Map) {
      return Map<String, dynamic>.from(comment);
    } else {
      return {
        'text': '',
        'userName': 'Unknown',
        'userImage': '',
      };
    }
  }).toList();

  return PostModel(
    id: id,
    userId: map['userId'] ?? '',
    caption: map['caption'] ?? '',
    imageUrl: map['imageUrl'] ?? '',
    likes: map['likes'] ?? 0,
    comments: safeComments,
  );
}

}
