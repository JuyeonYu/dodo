import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dodo/common/const/data.dart';
import 'package:dodo/todo/create_todo.dart';
import 'package:dodo/todo/search_todo.dart';
import 'package:dodo/user/help.dart';
import 'package:dodo/user/invite_buttons.dart';
import 'package:dodo/user/login_screen.dart';
import 'package:dodo/user/model/nickname_provider.dart';
import 'package:dodo/user/model/partner_provider.dart';
import 'package:dodo/user/more_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../todo/model/todo.dart';
import '../../todo/todo_tab_screen.dart';
import '../../user/model/user.dart';
import '../component/text_input_dialog.dart';
import '../const/colors.dart';
import '../default_layout.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../util/helper.dart';

class RootTab extends ConsumerStatefulWidget {
  const RootTab({Key? key}) : super(key: key);

  @override
  ConsumerState<RootTab> createState() => _RootTabState();
}

class _RootTabState extends ConsumerState<RootTab>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController controller;
  int index = 0;
  int? _value = 1;
  bool inSignout = false;
  bool inInvitated = false;
  bool showIndicator = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    controller.addListener(() {
      setState(() {
        index = controller.index;
      });
    });
  }

  @override
  void dispose() {
    controller.removeListener(tabListener);
    super.dispose();
  }

  void tabListener() {
    setState(() {
      index = controller.index;
    });
  }

  Widget build(BuildContext context) {
    final state = ref.watch(partnerNotifierProvider);
    return DefaultLayout(
      title: '두두',
      floatingActionButton: FloatingActionButton(
        backgroundColor: PRIMARY_COLOR,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CreateTodo(
                      todo: Todo(
                        userId: index == 0
                            ? FirebaseAuth.instance.currentUser!.email!
                            : ref.read(partnerNotifierProvider)?.email ?? '',
                        title: '',
                        isMine: index == 0,
                        isDone: false,
                        type: 0,
                        timestamp: Timestamp.now(),
                        content: '',
                      ),
                    )),
          );
        },
        child: Icon(Icons.add),
      ),
      child: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: controller,
        children: [TodoTabScreen()],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: PRIMARY_COLOR,
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            ref.watch(nicknameProvider) ?? '설정된 닉네임이 없습니다.',
                            style: TextStyle(color: Colors.white, fontSize:ref.watch(nicknameProvider) == null ? 15 : 25),
                            maxLines: 2,
                          ),
                          IconButton(
                            onPressed: () async {
                              await setNickname(context, ref);
                            },
                            icon: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: MediaQuery.of(context).size.height * 0.037,
                            ),
                          )
                        ],
                      ),
                      Container(
                        child: Text(
                          FirebaseAuth.instance.currentUser?.email ?? '',
                          style: TextStyle(color: TEXT_COLOR),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('같이 하는 사람'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StreamBuilder<DocumentSnapshot>(
                    stream: firestore
                        .collection('user')
                        .doc(FirebaseAuth.instance.currentUser?.email ?? '')
                        .snapshots(), // 구독할 스트림을 지정
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.data?.data() != null) {
                        Map<String, dynamic> data =
                            snapshot.data?.data() as Map<String, dynamic>;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('${state?.name}(${state?.email}}'),
                            ElevatedButton(
                              onPressed: () {
                                showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                          title: Text('알림'),
                                          content: const Text(
                                              '상대방의 할일 목록이 모두 사라집니다. 그래도 진행할까요?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () async {
                                                await firestore
                                                    .collection('user')
                                                    .doc(FirebaseAuth
                                                            .instance
                                                            .currentUser
                                                            ?.email ??
                                                        '')
                                                    .delete();
                                                await firestore
                                                    .collection('user')
                                                    .doc(ref
                                                            .read(
                                                                partnerNotifierProvider)
                                                            ?.email ??
                                                        '')
                                                    .delete();
                                                ref
                                                    .read(
                                                        partnerNotifierProvider
                                                            .notifier)
                                                    .delete();
                                                Navigator.pop(context);
                                              },
                                              child: const Text('공유 중단'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('취소'),
                                            ),
                                          ]);
                                    });
                              },
                              child: Text('공유 중단'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: BACKGROUND_COLOR),
                            ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        // 에러가 발생한 경우 UI 업데이트
                        return Text('Error: ${snapshot.error}');
                      } else {
                        // 데이터가 없는 경우 UI 업데이트
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('초대된 사람이 없습니다.'),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
              onTap: () {
                print('Setting is clicked');
              },
            ),
            ListTile(
              leading: Icon(
                Icons.question_mark_outlined,
                color: Colors.grey[850],
              ),
              title: Text('문의하기'),
              onTap: () {
                FlutterEmailSender.send(Email(
                    subject: '[dodo 문의]', recipients: ['remake382@gmail.com']));
              },
            ),
            ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Colors.grey[850],
                ),
                title: Text('로그아웃'),
                onTap: () async {
                  setState(() {
                    inSignout = true;
                  });
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                      (route) => false);
                },
                trailing: inSignout ? CircularProgressIndicator() : null),
          ],
        ),
      ),
    );
  }
}
