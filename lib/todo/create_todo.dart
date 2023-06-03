import 'package:dodo/user/model/partner_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/component/common_text_form_field.dart';
import '../common/const/colors.dart';
import '../common/const/data.dart';
import '../common/default_layout.dart';
import 'model/todo.dart';

class CreateTodo extends ConsumerStatefulWidget {
  final Todo todo;

  const CreateTodo({Key? key, required this.todo}) : super(key: key);

  @override
  ConsumerState<CreateTodo> createState() => _CreateTodoState();
}

class _CreateTodoState extends ConsumerState<CreateTodo> {
  late bool _isEditing;
  bool _isSaving = false;
  bool _isDeleting = false;
  late final TextEditingController _memoController =
      TextEditingController(text: widget.todo.content);

  @override
  void initState() {
    super.initState();
    _isEditing = widget.todo.title.isNotEmpty;
  }

  Future<void> _saveTodo() async {
    setState(() {
      _isSaving = true;
    });
    Map<String, dynamic>? userJson = (await firestore
            .collection('user')
            .doc(FirebaseAuth.instance.currentUser!.email)
            .get())
        .data();
    String? serverPartnerEmail = userJson?['partnerEmail'];

    if (serverPartnerEmail == null && !widget.todo.isMine) {
      ref.read(partnerNotifierProvider.notifier).state = null;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('상대방 정보가 없습니다. 상대방이 공유 중단했습니다.'),
        action: SnackBarAction(
          textColor: PRIMARY_COLOR,
          label: '나가기',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ));
      // Navigator.pop(context);
      return;
    }

    if (_isEditing) {
      firestore
          .collection('todo')
          .doc(widget.todo.id)
          .update(widget.todo.toJson());
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
              onPressed: () {
                if (widget.todo!.title.isEmpty) {
                  return;
                }
                _saveTodo();
              },
              child: _isSaving
                  ? const CircularProgressIndicator(
                      color: PRIMARY_COLOR,
                    )
                  : Text(
                      _isEditing ? '수정' : '작성',
                      style: TextStyle(
                          color: widget.todo!.title.isEmpty
                              ? Colors.grey
                              : PRIMARY_COLOR),
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
                      CustomTextFormField(
                        maxLength: 24,
                        initialValue: widget.todo.title,
                        hintText: '제목',
                        onChanged: (String value) {
                          setState(() {
                            widget.todo!.title = value;
                          });
                        },
                        contentPadding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                        backgroundColor: Colors.transparent,
                        borderColor: Colors.transparent,
                        autofocus: true,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        '누가 할까요?',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      Wrap(
                        spacing: 5.0,
                        children: List<Widget>.generate(
                          2,
                          (int index) {
                            var isMine = (index == 0 && widget.todo.isMine) ||
                                (index == 1 && !widget.todo.isMine);
                            return ChoiceChip(
                              backgroundColor: BACKGROUND_COLOR,
                              selectedColor: PRIMARY_COLOR,
                              label: Text(
                                index == 0
                                    ? '나'
                                    : ref
                                            .watch(partnerNotifierProvider)
                                            ?.name ??
                                        '초대된 사람이 없습니다.',
                                style: TextStyle(color: Colors.white),
                              ),
                              selected: isMine,
                              onSelected: (bool selected) {
                                if (ref
                                        .read(partnerNotifierProvider.notifier)
                                        .state ==
                                    null) {
                                  return;
                                }
                                setState(() {
                                  widget.todo.isMine = index == 0 && selected;
                                  widget.todo.userId = ((index == 0 && selected)
                                      ? FirebaseAuth.instance.currentUser!.email
                                      : ref
                                          .read(partnerNotifierProvider)
                                          ?.email)!;
                                });
                              },
                            );
                          },
                        ).toList(),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: const [
                          Text(
                            '이 일의 중요도를 선택해주세요.',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          Tooltip(
                            message: '중요도 순으로 할일이 자동 정렬됩니다.',
                            triggerMode: TooltipTriggerMode.tap,
                            child: Icon(Icons.info),
                          )
                        ],
                      ),
                      Wrap(
                        spacing: 5.0,
                        children: List<Widget>.generate(
                          labelColors.length,
                          (int index) {
                            return ChoiceChip(
                              shape: index == widget.todo.type
                                  ? const StadiumBorder(
                                      side: BorderSide(width: 0.8))
                                  : null,
                              backgroundColor: labelColors[index],
                              selectedColor: labelColors[index],
                              label: SizedBox(width: 20),
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
                      const SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextField(
                          maxLength: 60,
                          controller: _memoController,
                          decoration: const InputDecoration(
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
                Spacer(),
                _isEditing
                    ? (_isDeleting
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          )
                        : IconButton(
                            onPressed: () async {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('알림'),
                                      content: const Text(
                                          '삭제할까요?\n공유한 상대방도 할 일이 삭제됩니다.'),
                                      actions: [
                                        TextButton(
                                            onPressed: () {},
                                            child: const Text(
                                              '취소',
                                              style:
                                                  TextStyle(color: TEXT_COLOR),
                                            )),
                                        TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _isDeleting = true;
                                              });

                                              firestore
                                                  .collection('todo')
                                                  .doc(widget.todo.id)
                                                  .delete();
                                              setState(() {
                                                _isDeleting = false;
                                              });
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              '삭제',
                                              style: TextStyle(
                                                  color: Colors.redAccent),
                                            ))
                                      ],
                                    );
                                  });
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: POINT_COLOR,
                            )))
                    : const Spacer()
              ],
            )
          ],
        ));
  }
}
