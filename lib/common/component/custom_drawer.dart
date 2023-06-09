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
  const CustomDrawer({super.key});

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
            decoration: const BoxDecoration(
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
                    Text(
                      FirebaseAuth.instance.currentUser?.email == null ? '게스트 모드' : '',
                      style: const TextStyle(color: TEXT_COLOR),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('같이 하는 사람'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StreamBuilder<DocumentSnapshot>(
                  stream: firestore
                      .collection('user')
                      .doc(getUserId())
                      .snapshots(), // 구독할 스트림을 지정
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    Map<String, dynamic>? data =
                        snapshot.data?.data() as Map<String, dynamic>?;
                    if (data?['partnerEmail'] != null) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('${state?.name}'),
                          ElevatedButton(
                            onPressed: () {
                              showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                        title: const Text('알림'),
                                        content: const Text(
                                            '상대방의 할일 목록이 모두 사라집니다. 그래도 진행할까요?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              '취소',
                                              style: TextStyle(
                                                  color: BACKGROUND_COLOR),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await firestore
                                                  .collection('user')
                                                  .doc(getUserId())
                                                  .update({
                                                'partnerEmail': null,
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
                                              });
                                              ref
                                                  .read(partnerNotifierProvider
                                                      .notifier)
                                                  .delete();
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              '공유 중단',
                                              style: TextStyle(
                                                  color: PRIMARY_COLOR),
                                            ),
                                          ),
                                        ]);
                                  });
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: BACKGROUND_COLOR),
                            child: const Text('공유 중단'),
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
                        children: const [
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
            title: const Text('문의하기'),
            onTap: () {
              FlutterEmailSender.send(Email(
                  subject: '[dodo 문의]', recipients: ['2x2isfor@gmail.com']));
            },
          ),
          ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.grey[850],
              ),
              title: const Text('로그아웃'),
              onTap: () async {
                setState(() {
                  inSignout = true;
                });
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false);
              },
              trailing: inSignout ? const CircularProgressIndicator() : null),
          ListTile(
              leading: Icon(
                Icons.exit_to_app,
                color: BACKGROUND_COLOR,
              ),
              title: const Text('회원탈퇴', style: TextStyle(color: BACKGROUND_COLOR),),
              onTap: () async {
                if (getUserId() == null) {
                  return;
                }
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('회원탈퇴'),
                        content: const Text('회원탈퇴 시 모든 데이터가 삭제됩니다.'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('취소', style: TextStyle(color: BACKGROUND_COLOR),)),
                          TextButton(
                              onPressed: () async {
                                setState(() {
                                  inSignout = true;
                                });
                                String? userId = getUserId();
                                if (userId == null) {
                                  return;
                                }
                                await firestore
                                    .collection('user')
                                    .doc(userId)
                                    .delete();
                                await (firestore
                                        .collection('todo')
                                        .where('userId', isEqualTo: userId))
                                    .get()
                                    .then((value) =>
                                        value.docs.forEach((element) {
                                          element.reference.delete();
                                        }));
                                await FirebaseAuth.instance.currentUser
                                    ?.delete();
                                await FirebaseAuth.instance.signOut();
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (_) => const LoginScreen()),
                                    (route) => false);
                              },
                              child: const Text('탈퇴', style: TextStyle(color: POINT_COLOR),))
                        ],
                      );
                    });
              },
              trailing: inSignout ? const CircularProgressIndicator() : null),
        ],
      ),
    );
  }
}
