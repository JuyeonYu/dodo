import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dodo/common/component/custom_drawer.dart';
import 'package:dodo/todo/create_todo.dart';
import 'package:dodo/user/model/partner_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../todo/model/todo.dart';
import '../../todo/todo_tab_screen.dart';
import '../const/colors.dart';
import '../default_layout.dart';

class RootTab extends ConsumerStatefulWidget {
  const RootTab({Key? key}) : super(key: key);

  @override
  ConsumerState<RootTab> createState() => _RootTabState();
}

class _RootTabState extends ConsumerState<RootTab>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController? controller;
  int index = 0;
  bool inSignout = false;
  bool inInvitated = false;
  bool showIndicator = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 1, vsync: this);
    controller!.addListener(() {
      setState(() {
        index = controller!.index;
      });
    });
  }

  @override
  void dispose() {
    controller!.removeListener(tabListener);
    super.dispose();
  }

  void tabListener() {
    setState(() {
      index = controller!.index;
    });
  }

  Widget build(BuildContext context) {
    final state = ref.watch(partnerNotifierProvider);
    return DefaultLayout(
        title: '두두',
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FirebaseAuth.instance.currentUser?.email == null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Tooltip(
                          message: "할 일 저장의 영구저장, 초대 기능이 제한됩니다.",
                          triggerMode: TooltipTriggerMode.tap,
                          child: Row(
                            children: const [
                              Text(
                                '게스트 모드',
                                style: TextStyle(color: TEXT_COLOR),
                              ),
                              Icon(Icons.info)
                            ],
                          ),
                        ),
                      ),
                    )
                  : const Spacer(),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateTodo(
                                  todo: Todo(
                                    userId: index == 0
                                        ? FirebaseAuth
                                            .instance.currentUser!.email!
                                        : state?.email ?? '',
                                    title: '',
                                    isDone: false,
                                    type: 0,
                                    timestamp: Timestamp.now(),
                                    content: '',
                                    isLike: false,
                                  ),
                                )),
                      );
                    },
                    child: const Text(
                      '할 일 추가',
                      style: TextStyle(color: PRIMARY_COLOR),
                    )),
              ),
            ],
          ),
        ),
        drawer: const CustomDrawer(),
        child: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: controller,
          children: const [TodoTabScreen()],
        ));
  }
}
