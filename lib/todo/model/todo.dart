class Todo {
  String userId;
  String title;
  bool isMine;
  String section;

  Todo({
    required this.userId,
    required this.title,
    required this.isMine,
    required this.section,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      userId: json['userId'],
      title: json['title'],
      isMine: json['isMine'],
      section: json['section'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'isMine': isMine,
      'section': section,
    };
  }
}
