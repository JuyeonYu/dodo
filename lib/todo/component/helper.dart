import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../common/const/colors.dart';
import '../../common/const/data.dart';
import '../create_todo.dart';
import '../model/todo.dart';

class Helper {
  static Widget BuildSection(String sectionName, List<DocumentSnapshot> todos,
      {bool isSearching = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                sectionName,
                style: const TextStyle(
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
                child: Text(isSearching
                    ? '검색 결과가 없습니다.'
                    : '할 일이 없는 날입니다. 사랑한다고 말해볼까요?'),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
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
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateTodo(
                                    todo: todo,
                                  )));
                    },
                    leading: Container(
                        color: labelColors[todo.type],
                        child: const SizedBox(
                          width: 10,
                          height: 500,
                        )),
                    title: Text(todo.title),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        todo.isDone
                            ? IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('알림'),
                                      content: const Text(
                                          '삭제할까요?\n공유한 상대방도 할 일이 삭제됩니다.'),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              '취소',
                                              style: TextStyle(
                                                  color: TEXT_COLOR),
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
                                              style: TextStyle(
                                                  color: POINT_COLOR),
                                            ))
                                      ],
                                    );
                                  });
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: POINT_COLOR,
                            ))
                            : Container(),
                        Checkbox(
                          value: todo.isDone,
                          onChanged: (value) {
                            firestore
                                .collection('todo')
                                .doc(todo.id)
                                .update({
                              'isDone': !todo.isDone,
                              'timestamp': Timestamp.now()
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }
}
