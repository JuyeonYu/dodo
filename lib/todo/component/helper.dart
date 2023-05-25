import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../common/const/colors.dart';
import '../../common/const/data.dart';
import '../create_todo.dart';
import '../model/todo.dart';

class Helper {
  static Widget BuildSection(String sectionName, List<DocumentSnapshot> todos, {bool isSearching = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                sectionName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Tooltip(message: sectionName == 'Pending' ? '할 일은 최대 10개 까지 추가됩니다.' : '완료 시점 기준 24시간 후에 자동으로 사라집니다.',  triggerMode: TooltipTriggerMode.tap,child: Icon(Icons.info),
              )
            ],
          ),
        ),
        sectionName == 'Pending' && todos.isEmpty ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(isSearching ? '검색 결과가 없습니다.' : '할 일이 없는 날입니다. 사랑한다고 말해볼까요?'),
        ) :
        ListView.builder(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount: todos.length,
          itemBuilder: (context, index) {
            DocumentSnapshot doc = todos[index];

            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            Todo todo = Todo.fromJson(data);
            todo.id = doc.id;
            return ListTile(
              selected: todo.isDone,
              selectedColor: BODY_TEXT_COLOR,
              selectedTileColor: Colors.white10,
              onTap: () {
                if (todo.isDone) { return; }
                Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTodo(todo: todo,)));
              },
              leading: Container(color: labelColors[todo.type], child: SizedBox(width: 10, height: 500,)),

              title: Text(todo.title),
              trailing: isSearching ? null : Checkbox(
                value: todo.isDone,
                onChanged: (value) {
                  firestore.collection('todo').doc(todo.id).update({
                    'isDone': !todo.isDone,
                    'timestamp': Timestamp.now()
                  });
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
Widget _buildSection(String sectionName, List<DocumentSnapshot> todos) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Text(
              sectionName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            sectionName == 'Pending' ? Spacer() :

            Tooltip(message: '완료 시점 기준 내일 자동으로 사라집니다.', triggerMode: TooltipTriggerMode.tap,child: Icon(Icons.info),
            )
          ],
        ),
      ),
      sectionName == 'Pending' && todos.isEmpty ? Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('할 일이 없는 날입니다. 사랑한다고 말해볼까요?'),
      ) :
      ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: todos.length,
        itemBuilder: (context, index) {
          DocumentSnapshot doc = todos[index];

          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          Todo todo = Todo.fromJson(data);
          todo.id = doc.id;
          return ListTile(
            selected: todo.isDone,
            selectedColor: BODY_TEXT_COLOR,
            selectedTileColor: Colors.white10,
            onTap: () {
              if (todo.isDone) { return; }
              Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTodo(todo: todo,)));
            },
            leading: Container(color: labelColors[todo.type], child: SizedBox(width: 10, height: 500,)),

            title: Text(todo.title),
            trailing: Checkbox(
              value: todo.isDone,
              onChanged: (value) {
                firestore.collection('todo').doc(todo.id).update({
                  'isDone': !todo.isDone,
                  'timestamp': Timestamp.now()
                });
              },
            ),
          );
        },
      ),
    ],
  );
}