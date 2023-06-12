import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String? id;
  String userId;
  String title;
  String content;
  bool isMine;
  bool isDone;
  bool isLike;
  int type;
  Timestamp timestamp;

  Todo({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.isMine,
    required this.isDone,
    required this.isLike,
    required this.type,
    required this.timestamp,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      userId: json['userId'],
      title: json['title'],
      content: json['content'],
      isMine: json['isMine'],
      isDone: json['isDone'],
      isLike: json['isDone'] ?? false,
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
      'isMine': isMine,
      'isDone': isDone,
      'type': type,
      'timestamp': timestamp
    };
  }
}
