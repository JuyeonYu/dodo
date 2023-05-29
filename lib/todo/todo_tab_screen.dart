import 'package:dodo/common/const/colors.dart';
import 'package:dodo/common/default_layout.dart';
import 'package:dodo/todo/todo_screen.dart';
import 'package:dodo/user/model/user.dart';
import 'package:flutter/material.dart';

class TodoTabScreen extends StatefulWidget {
  const TodoTabScreen({Key? key}) : super(key: key);

  @override
  State<TodoTabScreen> createState() => _TodoTabScreenState();
}

class _TodoTabScreenState extends State<TodoTabScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(52),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: AppBar(
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TabBar(
                      labelColor: BODY_TEXT_COLOR,
                      indicatorColor: BODY_TEXT_COLOR,
                      isScrollable: true,
                      tabs: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text("Mine"),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: UserDomain.partner == null ? Text('공유한 친구가 없습니다.') : Text(UserDomain.partner!.name),
                        ),
                      ],
                      controller: _tabController),
                ),
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          TodoScreen(
            isMine: true,
          ),
          UserDomain.partner == null ? Spacer() : TodoScreen(
            isMine: false,
          ),
        ],
      ),
    );
  }
}
