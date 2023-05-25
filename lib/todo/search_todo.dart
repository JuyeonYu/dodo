import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dodo/common/component/common_text_form_field.dart';
import 'package:dodo/common/const/data.dart';
import 'package:dodo/common/default_layout.dart';
import 'package:flutter/material.dart';

import 'component/helper.dart';
import 'model/todo.dart';

class Searchtodo extends StatefulWidget {
  const Searchtodo({Key? key}) : super(key: key);

  @override
  State<Searchtodo> createState() => _SearchtodoState();
}

class _SearchtodoState extends State<Searchtodo> {
  Timer? _debounceTimer;

  void _handleSearch(String searchTerm) {
    _debounceTimer?.cancel();

    // Debounce search by delaying the search action for 500 milliseconds
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      var test = await firestore
          .collection('todo')
          .where('title', isGreaterThanOrEqualTo: searchTerm)
          .get();
      setState(() {
        search = searchTerm;
      });
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  String search = '';

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back_ios)),
              Expanded(
                  child: CustomTextFormField(
                showCursorColor: false,
                borderColor: Colors.transparent,
                onChanged: (String value) {
                  _handleSearch(value);
                },
                autofocus: true,
                hintText: '검색어를 입력해주세요',
                contentPadding: EdgeInsets.fromLTRB(8, 0, 8, 0),
              ))
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: firestore
                .collection('todo')
                .where('userId', isEqualTo: 'remake382')
                .where('title', isEqualTo: search)
                // .where('title', isLessThan: search + 'z')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: Text('검색 결과가 없습니다.'),
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

              if (completedTodos.isEmpty && pendingTodos.isEmpty) {
                return Center(
                  child: Text('검색 결과가 없습니다.'),
                );
              } else {
                return ListView(
                  children: [
                    pendingTodos.isEmpty
                        ? Spacer()
                        : Helper.BuildSection('Pending', pendingTodos,
                            isSearching: true),
                    completedTodos.isEmpty
                        ? Spacer()
                        : Helper.BuildSection('Completed', completedTodos,
                            isSearching: true),
                  ],
                );
              }
            },
          ),
        )
      ]),
    );
  }
}
