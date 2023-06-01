import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dodo/common/component/custom_drawer.dart';
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
    controller = TabController(length: 2, vsync: this);
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
                            : state?.email ?? '',
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
        child: const Icon(Icons.add),
      ),
      drawer: CustomDrawer(),
      child: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller,
        children: const [TodoTabScreen()],
      )
    );
  }
}
