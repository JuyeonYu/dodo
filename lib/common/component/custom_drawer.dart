import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../user/help.dart';
import '../../user/login_screen.dart';
import '../../user/model/nickname_provider.dart';
import '../../user/model/partner_provider.dart';
import '../../user/model/user.dart';
import '../const/colors.dart';
import '../const/data.dart';

class CustomDrawer extends ConsumerStatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends ConsumerState<CustomDrawer> {
  Map<String, dynamic>? userJson;
  bool inSignout = false;

  @override
  void initState() {
    super.initState();
    fetchData(); // 초기화 시 API 호출
  }

  Future<void> fetchData() async {
    Map<String, dynamic>? json = await resetPartner(ref);
    setState(() {
      userJson = json;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(partnerNotifierProvider);
    return Drawer(
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
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: ref.watch(nicknameProvider) == null
                                  ? 15
                                  : 25),
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
                    Map<String, dynamic>? data =
                        snapshot.data?.data() as Map<String, dynamic>?;
                    if (data?['partnerEmail'] != null) {
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
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('취소', style: TextStyle(color: BACKGROUND_COLOR),),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await firestore
                                                  .collection('user')
                                                  .doc(FirebaseAuth.instance
                                                          .currentUser?.email ??
                                                      '')
                                                  .update({
                                                'partnerEmail': null,
                                                'partnerName': null
                                              });
                                              print(ref
                                                      .read(
                                                          partnerNotifierProvider)
                                                      ?.email ??
                                                  '');
                                              await firestore
                                                  .collection('user')
                                                  .doc(ref
                                                          .read(
                                                              partnerNotifierProvider)
                                                          ?.email ??
                                                      '')
                                                  .update({
                                                'partnerEmail': null,
                                                'partnerName': null
                                              });
                                              ref
                                                  .read(partnerNotifierProvider
                                                      .notifier)
                                                  .delete();
                                              Navigator.pop(context);
                                            },
                                            child: const Text('공유 중단', style: TextStyle(color: PRIMARY_COLOR),),
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
    );
  }
}
