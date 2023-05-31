import 'package:dodo/common/default_layout.dart';
import 'package:dodo/common/screen/root_tab.dart';
import 'package:dodo/common/util/helper.dart';
import 'package:dodo/user/help.dart';
import 'package:dodo/user/model/nickname_provider.dart';
import 'package:dodo/user/model/partner_provider.dart';
import 'package:dodo/user/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../user/login_screen.dart';
import 'component/text_input_dialog.dart';
import 'const/colors.dart';
import 'const/data.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> {
  @override
  void initState() {
    super.initState();
    // deleteAll();
    checkToken();
  }

  void deleteAll() async {
    await storage.deleteAll();
  }

  void checkToken() async {
    String? nickname = await getNickName();
    if (nickname == null || nickname.isEmpty) {
      await setNickname(context, ref);
    } else {
      String? nickname = (await firestore
              .collection('user')
              .doc(FirebaseAuth.instance.currentUser!.email!)
              .get())
          .data()?['nickname'];
      ref.read(nicknameProvider.notifier).state = nickname;
    }

    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
        );
      } else {
        firestore
            .collection('user')
            .doc(FirebaseAuth.instance.currentUser!.email)
            .snapshots()
            .listen((event) {
          if (event.data() == null) {
            goRoot();
            return;
          }
          ref.read(partnerNotifierProvider.notifier).state = UserDomain(
              email: event.data()!['partnerEmail'],
              name: event.data()!['partnerName'],
              thumbnail: '');
          goRoot();
        });
      }
    });
  }

  void goRoot() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => RootTab()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
        backgroundColor: Colors.white,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.width / 2,
                  child: Image.asset('assets/images/logo.png')),
              SizedBox(
                height: 16,
              ),
              CircularProgressIndicator(
                color: Colors.white,
              )
            ],
          ),
        ));
  }
}
