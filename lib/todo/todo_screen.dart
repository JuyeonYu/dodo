import 'package:dodo/common/const/colors.dart';
import 'package:dodo/common/const/data.dart';
import 'package:dodo/common/screen/root_tab.dart';
import 'package:dodo/todo/create_todo.dart';
import 'package:dodo/user/invite_buttons.dart';
import 'package:dodo/user/model/nickname_provider.dart';
import 'package:dodo/user/model/partner_provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'component/helper.dart';
import 'model/todo.dart';

class TodoScreen extends ConsumerStatefulWidget {
  TodoScreen({Key? key, required this.isMine}) : super(key: key);

  final bool isMine;

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(currentOrderProvider);

    if (!widget.isMine &&
        ref.watch(partnerNotifierProvider.notifier).state == null) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            children: const [
              Text('초대된 사람이 없습니다.'),
              Padding(
                padding: EdgeInsets.all(50.0),
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
            .where('userId',
                isEqualTo: widget.isMine
                    ? getUserId()
                    : ref.watch(partnerNotifierProvider)!.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
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
            Todo aTodo = Todo.fromJson(a.data() as Map<String, dynamic>);
            Todo bTodo = Todo.fromJson(b.data() as Map<String, dynamic>);


            if (order == MenuType.priority) {
              // 1차 정렬: type 오름차순
              int typeComparison = bTodo.type.compareTo(aTodo.type);
              if (typeComparison != 0) {
                return typeComparison;
              }
            } else {
              // 1차 정렬: 날짜 오름차순

            int typeComparison = (aTodo.expiration ?? Timestamp(0, 0)).compareTo((bTodo.expiration ?? Timestamp(0, 0)));
              if (typeComparison != 0) {
                return typeComparison;
              }
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
          if (pendingTodos.isEmpty && completedTodos.isEmpty) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateTodo(
                                    todo: Todo(
                                      userId: getUserId()!,
                                      title: '',
                                      isDone: false,
                                      type: 0,
                                      timestamp: Timestamp.now(),
                                      content: '',
                                      isLike: false,
                                    ),
                                  )),
                        );
                      },
                      icon: const Icon(
                        Icons.add,
                        color: PRIMARY_COLOR,
                      )),
                ),
                const Text(
                  "할 일을 추가해볼까요? :)",
                  style: TextStyle(color: TEXT_COLOR),
                ),
              ],
            ));
          } else {
            return ListView(
              children: [
                TodoCell(sectionName: '진행중', todos: pendingTodos),
                TodoCell(sectionName: '완료됨', todos: completedTodos)
              ],
            );
          }
        });
  }
}
