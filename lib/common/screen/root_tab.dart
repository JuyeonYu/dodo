import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dodo/common/const/data.dart';
import 'package:dodo/todo/create_todo.dart';
import 'package:dodo/todo/search_todo.dart';
import 'package:dodo/user/login_screen.dart';
import 'package:dodo/user/more_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

class RootTab extends StatefulWidget {
  const RootTab({Key? key}) : super(key: key);

  @override
  State<RootTab> createState() => _RootTabState();
}

class _RootTabState extends State<RootTab>
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
    controller.addListener(tabListener);
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
    return DefaultLayout(
      title: 'dodo',
      actions: [
        IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
      ],
      floatingActionButton: FloatingActionButton(
        backgroundColor: PRIMARY_COLOR,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CreateTodo(
                      todo: Todo(
                        userId: 'remake382',
                        title: '',
                        isMine: true,
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
        children: [TodoTabScreen(), ConfigScreen()],
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   selectedItemColor: PRIMARY_COLOR,
      //   unselectedItemColor: BODY_TEXT_COLOR,
      //   selectedFontSize: 10,
      //   unselectedFontSize: 10,
      //   type: BottomNavigationBarType.fixed,
      //   onTap: (int index) {
      //     controller.animateTo(index);
      //   },
      //   currentIndex: index,
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.task), label: '할일'),
      //     BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
      //   ],
      // ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                // 현재 계정 이미지 set
                backgroundImage: NetworkImage(
                    FirebaseAuth.instance.currentUser?.photoURL ?? ''),
                backgroundColor: Colors.white,
              ),
              accountName:
                  Text(FirebaseAuth.instance.currentUser?.displayName ?? ''),
              accountEmail:
                  Text(FirebaseAuth.instance.currentUser?.email ?? ''),
              decoration: BoxDecoration(
                  color: Colors.red[200],
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40.0),
                      bottomRight: Radius.circular(40.0))),
            ),
            ListTile(
              title: Text('같이 하는 사람'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StreamBuilder<DocumentSnapshot>(
                    stream: firestore
                        .collection('host_guest')
                        .doc(FirebaseAuth.instance.currentUser?.email ?? '')
                        .snapshots(), // 구독할 스트림을 지정
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.data?.data() != null) {
                        Map<String, dynamic> data =
                            snapshot.data?.data() as Map<String, dynamic>;
                        return Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Text('${data['partnerName']}(${data['partnerEmail']}}'),
                            Text('${UserDomain.partner!.name}(${UserDomain.partner!.email}}'),
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
                                                onPressed: () {
                                                  firestore.collection('host_guest').doc(FirebaseAuth.instance.currentUser?.email ?? '').delete();
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
                                child: Text('공유 중단')),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        // 에러가 발생한 경우 UI 업데이트
                        return Text('Error: ${snapshot.error}');
                      } else {
                        // 데이터가 없는 경우 UI 업데이트
                        return Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('초대된 사람이 없습니다.'),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      String shareCode =
                                          generateShortHashFromUUID();
                                      firestore
                                          .collection('invitation')
                                          .doc(FirebaseAuth.instance.currentUser?.email ?? '')
                                          .set({
                                        'code': shareCode,
                                        'hostEmail': FirebaseAuth.instance.currentUser?.email ?? '',
                                        'hostName': FirebaseAuth.instance.currentUser?.displayName ?? '',
                                        'timestamp': Timestamp.now()
                                      }, SetOptions(merge: true));
                                      showDialog<String>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                                title: Text(shareCode),
                                                content: const Text(
                                                    '위 코드를 상대방에게 공유하세요.'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      Share.share(
                                                          '두두 초대 코드: $shareCode');
                                                    },
                                                    child: const Text('공유'),
                                                  ),
                                                ]);
                                          });
                                    },
                                    child: Text('초대하기')),
                                ElevatedButton(
                                    onPressed: () async {
                                      String? enteredText =
                                          await showDialog<String>(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return TextInputDialog(
                                                  title: '초대코드',
                                                  hint: '초대코드를 입력해주세요(숫자, 소문자)',
                                                );
                                              });

                                      if (enteredText == null) {
                                        return;
                                      }
                                      var snapshots = firestore
                                          .collection('invitation')
                                          .where('code', isEqualTo: enteredText)
                                          .snapshots();
                                      snapshots.listen((event) {
                                        if (event.docs.length == 1) {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                Map<String, dynamic> json = event
                                                    .docs.first
                                                    .data();
                                                String hostName = json['hostName'];
                                                String hostEmail = json['hostEmail'];
                                                Timestamp timestamp = json['timestamp'];
                                                int diff = Timestamp.now().compareTo(timestamp);
                                                print(diff);
                                                return AlertDialog(
                                                    title: Text('알림'),
                                                    content: Text(
                                                        '초대한 사람의 정보가 맞습니까?\n이름: ${hostName}\nemail: ${hostEmail}'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                    title: Text(
                                                                        '알림'),
                                                                    content:
                                                                        const Text(
                                                                            '해당 초대 코드에 문제가 있습니다. 코대 코드 생성을 다시 한번 부탁드립니다.'),
                                                                    actions: <
                                                                        Widget>[
                                                                      TextButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        child: const Text(
                                                                            '닫기'),
                                                                      ),
                                                                    ]);
                                                              });
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child:
                                                            const Text('아니오'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          setState(() {
                                                            inInvitated = true;
                                                          });
                                                          await firestore
                                                              .collection(
                                                                  'host_guest')
                                                              .doc(FirebaseAuth.instance.currentUser?.email ?? '')
                                                              .set({
                                                            'partnerEmail':
                                                                hostEmail,
                                                            'partnerName':
                                                                hostName,
                                                          });
                                                          await firestore
                                                              .collection(
                                                                  'host_guest')
                                                              .doc(hostEmail)
                                                              .set({
                                                            'partnerEmail':
                                                            FirebaseAuth.instance.currentUser?.email ?? '',
                                                            'partnerName':
                                                            FirebaseAuth.instance.currentUser?.displayName ?? '',
                                                          });
                                                          UserDomain.partner = UserDomain(email: hostEmail, name: hostName, thumbnail: '');
                                                          setState(() {
                                                            inInvitated = false;
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text('네'),
                                                      ),
                                                    ]);
                                              });
                                        } else if (event.docs.length > 1) {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                    title: Text('알림'),
                                                    content: const Text(
                                                        '??해당 초대 코드에 문제가 있습니다. 코대 코드 생성을 다시 한번 부탁드립니다.'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text('닫기'),
                                                      ),
                                                    ]);
                                              });
                                        } else {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                    title: Text('없는 초대코드입니다.'),
                                                    // content: const Text('초대한 사람 email: $'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text('닫기'),
                                                      ),
                                                    ]);
                                              });
                                        }
                                      });
                                    },
                                    child: inInvitated
                                        ? CircularProgressIndicator()
                                        : Text('초대받기')),
                              ],
                            )
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
                print('Q&A is clicked');
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
