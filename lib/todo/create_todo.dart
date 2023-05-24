import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../common/component/common_text_form_field.dart';
import '../common/const/colors.dart';
import '../common/const/data.dart';
import '../common/default_layout.dart';
import 'model/todo.dart';

class CreateTodo extends StatefulWidget {
  final Todo todo;
  const CreateTodo({Key? key, required this.todo}) : super(key: key);

  @override
  State<CreateTodo> createState() => _CreateTodoState();
}

class _CreateTodoState extends State<CreateTodo> {
  bool _isSaving = false;

  Future<void> _saveTodo() async {
    setState(() {
      _isSaving = true;
    });

    // Simulate a delay of 2 seconds for saving the todo
    await Future.delayed(Duration(seconds: 2));

    // Save the todo to Firestore or perform any other necessary actions
    firestore.collection('todo').doc().set(widget.todo.toJson());

    setState(() {
      _isSaving = false;
    });

    // Navigate back to the previous screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return DefaultLayout(
        title: '할 일 등록',
        actions: [
          TextButton(
              onPressed: ()  {
                if (widget.todo!.title.isEmpty) {
                  return;
                }
                print(widget.todo.toJson());
                // firestore.doc('todo').set(widget.todo.toJson());
                _saveTodo();
              },
              child: _isSaving ? CircularProgressIndicator() : Text(
                '작성',
                style: TextStyle(color: widget.todo!.title.isEmpty ? Colors.grey : PRIMARY_COLOR),
              ))
        ],
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextFormField(hintText: '제목', onChanged: (String value) {
                        setState(() {
                          widget.todo!.title = value;
                        });
                      }, contentPadding: EdgeInsets.fromLTRB(8, 0, 8, 0), backgroundColor: Colors.transparent, borderColor: Colors.transparent, autofocus: true,),
                      SizedBox(height: 15,),
                      Text('누가 할까요?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),),
                      Wrap(
                        spacing: 5.0,
                        children: List<Widget>.generate(
                          2,
                              (int index) {
                            var isMine = (index == 0 && widget.todo.isMine) || (index == 1 && !widget.todo.isMine);
                            return ChoiceChip(
                              shape: isMine ? StadiumBorder(side: BorderSide(width: 0.5)) : null,
                              label:  Text( index == 0 ? '나' : '너'),
                              selected: isMine,
                              onSelected: (bool selected) {
                                setState(() {
                                  widget.todo.isMine = index == 0 && selected;
                                });
                              },
                            );
                          },
                        ).toList(),
                      ),
                      SizedBox(height: 15,),
                      Text('이 일과 어울리는 색깔을 골라주세요', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),),
                      Wrap(
                        spacing: 5.0,
                        children: List<Widget>.generate(
                          labelColors.length,
                              (int index) {
                            return ChoiceChip(
                              shape: index == widget.todo.type ? StadiumBorder(side: BorderSide(width: 0.8)) : null,
                              backgroundColor: labelColors[index],
                              selectedColor: labelColors[index],
                              label:  SizedBox(width: 20),
                              selected: widget.todo.type == index,
                              onSelected: (bool selected) {
                                setState(() {
                                  print(selected);
                                  print(index);
                                  widget.todo.type = index;
                                });
                              },
                            );
                          },
                        ).toList(),
                      ),
                      SizedBox(height: 15,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextField(
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '메모',
                              hintStyle: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          onChanged: (value) {
                            setState(() {
                              widget.todo.content = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Row(
              children: [
                IconButton(onPressed: (){}, icon: Icon(Icons.info)),
              ],
            )
          ],
        ));
  }
}
