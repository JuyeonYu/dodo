import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dodo/todo/create_todo.dart';
import 'package:flutter/material.dart';

import '../../todo/model/todo.dart';
import '../../todo/todo_tab_screen.dart';
import '../const/colors.dart';
import '../default_layout.dart';

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
        title: 'lapine',
        actions: [
          IconButton(onPressed: () {
            // Navigator.of(context).push(
            //     MaterialPageRoute(builder: (_) => SearchScreen()));
          }, icon: Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
        ],
        floatingActionButton: FloatingActionButton(
          backgroundColor: PRIMARY_COLOR,
          onPressed: () {
            Navigator.push(
              context, MaterialPageRoute(builder: (context) => CreateTodo(todo: Todo(
              userId: 'remake382',
              title: '',
              isMine: true,
              isDone: false,
              type: 0,
              timestamp: Timestamp.now(),
              content: '',
            ),)),
            );
          },
          child: Icon(Icons.add),
        ),
        child: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          controller: controller,
          children: [
            TodoTabScreen(),
            TodoTabScreen()
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: PRIMARY_COLOR,
          unselectedItemColor: BODY_TEXT_COLOR,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          type: BottomNavigationBarType.fixed,
          onTap: (int index) {
            controller.animateTo(index);
          },
          currentIndex: index,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.task), label: '할일'),
            BottomNavigationBarItem(icon: Icon(Icons.post_add), label: '게시판'),
          ],
        ));
  }
}
