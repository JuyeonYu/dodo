import 'package:dodo/common/const/colors.dart';
import 'package:dodo/common/default_layout.dart';
import 'package:dodo/todo/todo_screen.dart';
import 'package:dodo/user/model/partner_provider.dart';
import 'package:dodo/user/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TodoTabScreen extends ConsumerStatefulWidget {
  const TodoTabScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TodoTabScreen> createState() => _TodoTabScreenState();
}

class _TodoTabScreenState extends ConsumerState<TodoTabScreen>
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
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TabBar(
                  labelColor: TEXT_COLOR,
                  indicatorColor: PRIMARY_COLOR,
                  isScrollable: true,
                  tabs: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text('나'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: ref.watch(partnerNotifierProvider.notifier).state == null ? Text('초대된 친구가 없습니다.') : Text(ref.watch(partnerNotifierProvider)!.name),
                    ),
                  ],
                  controller: _tabController),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          TodoScreen(
            isMine: true,
          ),
          TodoScreen(
            isMine: false,
          ),
        ],
      ),
    );
  }
}
