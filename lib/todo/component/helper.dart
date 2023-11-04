import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../common/const/colors.dart';
import '../../common/const/data.dart';
import '../create_todo.dart';
import '../model/todo.dart';

class TodoCell extends StatefulWidget {
  final List<DocumentSnapshot> todos;
  final String sectionName;

  const TodoCell({Key? key, required this.sectionName, required this.todos})
      : super(key: key);

  @override
  State<TodoCell> createState() => _TodoCellState();
}

class _TodoCellState extends State<TodoCell> {
  Widget actions(BuildContext context, Todo todo) {
    if (todo.isMine) {
      return myActions(context, todo);
    } else {
      return yourActions(context, todo);
    }
  }

  Widget myActions(BuildContext context, Todo todo) {
    if (todo.isDone) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('알림'),
                        content: const Text('삭제할까요?\n공유한 상대방도 할 일이 삭제됩니다.'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                '취소',
                                style: TextStyle(color: TEXT_COLOR),
                              )),
                          TextButton(
                              onPressed: () {
                                firestore
                                    .collection('todo')
                                    .doc(todo.id)
                                    .delete();
                                Navigator.pop(context);
                              },
                              child: const Text(
                                '삭제',
                                style: TextStyle(color: POINT_COLOR),
                              ))
                        ],
                      );
                    });
              },
              icon: const Icon(
                Icons.delete,
                color: POINT_COLOR,
              )),
          Checkbox(
            value: todo.isDone,
            onChanged: (value) {
              firestore.collection('todo').doc(todo.id).update(
                  {'isDone': !todo.isDone, 'timestamp': Timestamp.now()});
            },
          ),
        ],
      );
    } else {
      return Checkbox(
        value: todo.isDone,
        onChanged: (value) {
          firestore
              .collection('todo')
              .doc(todo.id)
              .update({'isDone': !todo.isDone, 'timestamp': Timestamp.now()});
        },
      );
    }
  }

  Widget yourActions(BuildContext context, Todo todo) {
    return IconButton(
      onPressed: () {
        firestore
            .collection('todo')
            .doc(todo.id)
            .update({'isLike': !todo.isLike});
        todo.isLike = !todo.isLike;
      },
      icon: Icon(todo.isLike ? Icons.favorite : Icons.favorite_border),
      color: POINT_COLOR,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                widget.sectionName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (widget.sectionName == 'Pending' &&
            widget.todos.isEmpty) const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('할 일이 없는 날입니다. 사랑한다고 말해볼까요?'),
        ) else
          ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: widget.todos.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = widget.todos[index];

              Map<String, dynamic> data =
              doc.data() as Map<String, dynamic>;
              Todo todo = Todo.fromJson(data);
              todo.id = doc.id;
              return ListTile(
                  selected: todo.isDone,
                  selectedColor: BODY_TEXT_COLOR,
                  selectedTileColor: Colors.white10,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                CreateTodo(
                                  todo: todo,
                                )));
                  },
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          color: labelColors[todo.type],
                          child: const SizedBox(
                            width: 10,
                            height: 500,
                          )),
                      todo.isMine && todo.isLike
                          ? const SizedBox(
                          width: 50,
                          child: Icon(
                            Icons.favorite,
                            color: POINT_COLOR,
                          ))
                          : Container()
                    ],
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Visibility(
                        visible: todo.expiration != null,
                        child: Text(
                          todo.expiration != null
                              ?
                          expirationDateFormat.format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  todo.expiration!.millisecondsSinceEpoch))
                              : '',
                          style: TextStyle(color: (todo.expiration
                              ?.millisecondsSinceEpoch ?? 0) > Timestamp
                              .now()
                              .millisecondsSinceEpoch ? BODY_TEXT_COLOR : BODY_TEXT_COLOR.withOpacity(0.5),
                              fontSize: 14),),
                      ),
                      Text(todo.title),
                    ],
                  ),
                  trailing: actions(context, todo));
            },
          ),
      ],
    );
  }
}
