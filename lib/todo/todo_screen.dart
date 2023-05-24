import 'package:dodo/common/const/colors.dart';
import 'package:dodo/common/const/data.dart';
import 'package:dodo/todo/create_todo.dart';
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
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
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

        List<DocumentSnapshot> todoDocs = snapshot.data!.docs;
        List<DocumentSnapshot> completedTodos = [];
        List<DocumentSnapshot> pendingTodos = [];
        for (var doc in todoDocs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          bool isDone = data['isDone'];
          if (isDone) {
            completedTodos.add(doc);
          } else {
            pendingTodos.add(doc);
          }
        }

        return ListView(
          children: [
            _buildSection('Pending', pendingTodos),
            _buildSection('Completed', completedTodos),
          ],
        );
      },
    );
  }
  Widget _buildSection(String sectionName, List<DocumentSnapshot> todos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            sectionName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
            return Dismissible(
              background: Container(
                color: Colors.red,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('to you'),
                  ),
                ),
              ),
              secondaryBackground: Container(
                color: Colors.green,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              key: Key(todo.id ?? ""),
              child: ListTile(
                selected: todo.isDone,
                selectedColor: BODY_TEXT_COLOR,
                selectedTileColor: Colors.white10,
                onTap: () {
                  if (todo.isDone) { return; }
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTodo(todo: todo,)));
                  // setState(() {
                  //
                  //   // todo.isDone = !todo.isDone;
                  // });
                },
                leading: Container(color: labelColors[todo.type], child: SizedBox(width: 10, height: 500,)),

                title: Text(todo.title),
                trailing: Checkbox(
                  value: todo.isDone,
                  onChanged: (value) {
                    firestore.collection('todo').doc(todo.id).update({
                      'isDone': !todo.isDone
                    });
                  },
                ),
              ),
              onDismissed: (direction) {
                if (direction == DismissDirection.startToEnd) {
                  // 좌측에서 우측으로 스와이프됨 (삭제 액션)
                  // _deleteTodoItem(todo);
                } else if (direction == DismissDirection.endToStart) {
                  // 우측에서 좌측으로 스와이프됨 (완료 액션)
                  // _completeTodoItem(todo);
                }
              },

            );
          },
        ),
      ],
    );
  }
}