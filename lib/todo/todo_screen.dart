import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'model/todo.dart';

class TodoScreen extends StatefulWidget {
  TodoScreen({Key? key, required this.isMine}) : super(key: key);

  final bool isMine;

  @override
  State<TodoScreen> createState() => _TodoScreenState();


}

class _TodoScreenState extends State<TodoScreen> {
  final List<Section> sections = [
    Section(
      title: 'Section 1',
      items: ['Item 1', 'Item 2', 'Item 3'],
    ),
    Section(
      title: 'Section 2',
      items: ['Item 4', 'Item 5'],
    ),
    Section(
      title: 'Section 3',
      items: ['Item 6', 'Item 7', 'Item 8'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('todo')
          .where('userId', isEqualTo: 'remake382')
          .where('isMine', isEqualTo: widget.isMine)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<Todo> todoList = [];
        snapshot.data!.docs.forEach((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          Todo todo = Todo.fromJson(data);
          todoList.add(todo);
        });

        return ListView.builder(
          itemCount: todoList.length,
          itemBuilder: (context, index) {
            Todo todo = todoList[index];
            return ListTile(
              title: Text(todo.title),
              subtitle: Text(todo.section),
              trailing: Checkbox(
                value: todo.isMine,
                onChanged: (value) {
                  // 체크박스 상태 변경 로직 작성
                },
              ),
            );
          },
        );
      },
    );
    return ListView.builder(
      itemCount: sections.length,
      itemBuilder: (context, sectionIndex) {
        final section = sections[sectionIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                section.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: section.items.length,
              itemBuilder: (context, itemIndex) {
                final item = section.items[itemIndex];
                return ListTile(
                  title: Text(item),
                );
              },
            ),
          ],
        );
      },
    );
  }
}


class SectionedListViewExample extends StatelessWidget {
  final List<Section> sections = [
    Section(
      title: 'Section 1',
      items: ['Item 1', 'Item 2', 'Item 3'],
    ),
    Section(
      title: 'Section 2',
      items: ['Item 4', 'Item 5'],
    ),
    Section(
      title: 'Section 3',
      items: ['Item 6', 'Item 7', 'Item 8'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sectioned ListView Example'),
      ),
      body: ListView.builder(
        itemCount: sections.length,
        itemBuilder: (context, sectionIndex) {
          final section = sections[sectionIndex];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  section.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: section.items.length,
                itemBuilder: (context, itemIndex) {
                  final item = section.items[itemIndex];
                  return ListTile(
                    title: Text(item),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class Section {
  final String title;
  final List<String> items;

  Section({
    required this.title,
    required this.items,
  });
}
