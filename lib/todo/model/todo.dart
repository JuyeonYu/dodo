import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Todo {
  String? id;
  String userId;
  String title;
  String content;
  bool isDone;
  bool isLike;
  int type;
  Timestamp timestamp;

  Todo({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.isDone,
    required this.isLike,
    required this.type,
    required this.timestamp,
  });

  bool get isMine => userId == FirebaseAuth.instance.currentUser?.email;

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      userId: json['userId'],
      title: json['title'],
      content: json['content'],
      isDone: json['isDone'],
      isLike: json['isLike'] ?? false,
      type: json['type'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'isDone': isDone,
      'isLike': isLike,
      'type': type,
      'timestamp': timestamp
    };
  }
}
