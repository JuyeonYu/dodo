import 'package:flutter/material.dart';

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
            // Navigator.of(context)
            //     .push(MaterialPageRoute(builder: (_) => CreatePostScreen())).then((value) => setState(() {}));
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
