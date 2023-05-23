import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String? id;
  String userId;
  String title;
  bool isMine;
  bool isDone;
  String section;
  String colorCode;
  Timestamp timestamp;

  Todo({
    this.id,
    required this.userId,
    required this.title,
    required this.isMine,
    required this.isDone,
    required this.section,
    required this.colorCode,
    required this.timestamp,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      userId: json['userId'],
      title: json['title'],
      isMine: json['isMine'],
      isDone: json['isDone'],
      section: json['section'],
      colorCode: json['colorCode'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'isMine': isMine,
      'isDone': isDone,

      'section': section,
      'colorCode': colorCode,
      'timestamp': timestamp
    };
  }
}
