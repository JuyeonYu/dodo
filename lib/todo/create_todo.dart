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
  late bool _isEditing;
  bool _isSaving = false;
  bool _isDeleting = false;
  late final TextEditingController _memoController = TextEditingController(text: widget.todo.content);

  @override
  void initState() {
    super.initState();
    _isEditing = widget.todo.title.isNotEmpty;
  }


  Future<void> _saveTodo() async {
    setState(() {
      _isSaving = true;
    });

    if (_isEditing) {
      firestore.collection('todo').doc(widget.todo.id).update(widget.todo.toJson());
    } else {
      firestore.collection('todo').doc().set(widget.todo.toJson());
    }

    setState(() {
      _isSaving = false;
    });

    // Navigate back to the previous screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return DefaultLayout(
        title: _isEditing ? '할 일 편집' : '할 일 등록',
        actions: [
          TextButton(
              onPressed: ()  {
                if (widget.todo!.title.isEmpty) {
                  return;
                }
                _saveTodo();
              },
              child: _isSaving ? CircularProgressIndicator() : Text(
                _isEditing ? '수정' : '작성',
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
                      CustomTextFormField(initialValue: widget.todo.title, hintText: '제목', onChanged: (String value) {
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
                        controller: _memoController,
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
                Spacer(),
                _isDeleting ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ) :
                IconButton(onPressed: () async {
                  setState(() {
                    _isDeleting = true;
                  });
                  
                  firestore.collection('todo').doc(widget.todo.id).delete();
                  setState(() {
                    _isDeleting = false;
                  });
                  Navigator.pop(context);
                }, icon: Icon(Icons.delete, color: Colors.redAccent,))
              ],
            )
          ],
        ));
  }
}
