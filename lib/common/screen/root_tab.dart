import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dodo/todo/create_todo.dart';
import 'package:dodo/todo/search_todo.dart';
import 'package:dodo/user/login_screen.dart';
import 'package:dodo/user/more_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../todo/model/todo.dart';
import '../../todo/todo_tab_screen.dart';
import '../../user/model/user.dart';
import '../const/colors.dart';
import '../default_layout.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
            // 프로젝트에 assets 폴더 생성 후 이미지 2개 넣기
            // pubspec.yaml 파일에 assets 주석에 이미지 추가하기
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                // 현재 계정 이미지 set
                backgroundImage: NetworkImage(UserDomain.myself.thumbnail),
                backgroundColor: Colors.white,
              ),
              otherAccountsPictures: <Widget>[
                // 다른 계정 이미지[] set
                CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/profile2.png'),
                ),
              ],
              accountName: Text(UserDomain.myself.name),
              accountEmail: Text(UserDomain.myself.email),
              // onDetailsPressed: () {
              //   print('arrow is clicked');
              // },
              decoration: BoxDecoration(
                  color: Colors.red[200],
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40.0),
                      bottomRight: Radius.circular(40.0))),
            ),
            ListTile(
              leading: Icon(
                Icons.share,
                color: Colors.grey[850],
              ),
              title: Text('할 일 공유하기'),
              onTap: () {
                print('Setting is clicked');
              },
              trailing: Icon(Icons.add),
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
