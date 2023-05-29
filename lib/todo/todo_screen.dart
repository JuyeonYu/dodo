import 'package:dodo/common/const/colors.dart';
import 'package:dodo/common/const/data.dart';
import 'package:dodo/todo/create_todo.dart';
import 'package:dodo/user/invite_buttons.dart';
import 'package:dodo/user/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'component/helper.dart';
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
    if (!widget.isMine && UserDomain.partner == null) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text('초대된 사람이 없습니다.'),
              SizedBox(width: 100, height: 100, child: Icon(Icons.accessibility)),
              Padding(
                padding: const EdgeInsets.all(50.0),
                child: InviteButtons(),
              ),
            ],
          ),
        ),
      );
    }
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('todo')
          .where('userId', isEqualTo: widget.isMine ? FirebaseAuth.instance.currentUser!.email : UserDomain.partner!.email)
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
        pendingTodos.sort((a, b) {
          // 1차 정렬: type 오름차순
          Todo aTodo = Todo.fromJson(a.data() as Map<String, dynamic>);
          Todo bTodo = Todo.fromJson(b.data() as Map<String, dynamic>);
          int typeComparison = bTodo.type.compareTo(aTodo.type);
          if (typeComparison != 0) {
            return typeComparison;
          }

          // 2차 정렬: timestamp 오름차순
          return bTodo.timestamp.compareTo(aTodo.timestamp);
        });

        completedTodos.sort((a, b) {
          // 1차 정렬: type 오름차순
          Todo aTodo = Todo.fromJson(a.data() as Map<String, dynamic>);
          Todo bTodo = Todo.fromJson(b.data() as Map<String, dynamic>);
          int typeComparison = bTodo.type.compareTo(aTodo.type);
          if (typeComparison != 0) {
            return typeComparison;
          }

          // 2차 정렬: timestamp 오름차순
          return bTodo.timestamp.compareTo(aTodo.timestamp);
        });
        return ListView(
          children: [
            Helper.BuildSection('Pending', pendingTodos),
            Helper.BuildSection('Completed', completedTodos),
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
          child: Row(
            children: [
              Text(
                sectionName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        sectionName == 'Pending' && todos.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('할 일이 없는 날입니다. 사랑한다고 말해볼까요?'),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot doc = todos[index];
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  Todo todo = Todo.fromJson(data);
                  todo.id = doc.id;
                  return ListTile(
                    selected: todo.isDone,
                    selectedColor: BODY_TEXT_COLOR,
                    selectedTileColor: Colors.white10,
                    onTap: () {
                      if (todo.isDone) {
                        return;
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateTodo(
                                    todo: todo,
                                  )));
                    },
                    leading: Container(
                        color: labelColors[todo.type],
                        child: SizedBox(
                          width: 10,
                          height: 500,
                        )),
                    title: Text(todo.title),
                    trailing: Checkbox(
                      value: todo.isDone,
                      activeColor: PRIMARY_COLOR,
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
