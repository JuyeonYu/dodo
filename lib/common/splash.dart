import 'package:dodo/common/default_layout.dart';
import 'package:dodo/common/screen/root_tab.dart';
import 'package:dodo/user/help.dart';
import 'package:dodo/user/model/nickname_provider.dart';
import 'package:dodo/user/model/partner_provider.dart';
import 'package:dodo/user/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../user/login_screen.dart';
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
    checkToken();
  }

  void deleteAll() async {
    await storage.deleteAll();
  }

  void checkToken() async {
    if (FirebaseAuth.instance.currentUser == null ||
        getUserId() == null ||
        getUserId() == '') {
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      return;
    }
    Map<String, dynamic>? myUserInfoJson =
        (await firestore.collection('user').doc(getUserId()).get()).data();

    String? nickname = myUserInfoJson?['nickname'];
    if (nickname == null || nickname!.isEmpty) {
      // await setNickname(context, ref);
    } else {
      ref.read(nicknameProvider.notifier).state = nickname;
    }

    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        if (myUserInfoJson == null) {
          goRoot();
          return;
        }
        if (myUserInfoJson?['partnerEmail'] == null) {
          ref.read(partnerNotifierProvider.notifier).state = null;
        } else {
          String yourEmail = myUserInfoJson!['partnerEmail'];
          Map<String, dynamic>? yourUserInfoJson =
              (await firestore.collection('user').doc(yourEmail).get()).data();
          ref.read(partnerNotifierProvider.notifier).state = UserDomain(
              email: yourEmail,
              name: yourUserInfoJson?['nickname'] ?? '',
              thumbnail: '');
        }
        var token = await FirebaseAuth.instance.currentUser?.getIdTokenResult();
        firestore
            .collection('user')
            .doc(FirebaseAuth.instance.currentUser?.email)
            .update({'pushToken': token?.token ?? ''});
        goRoot();
      }
    });
  }

  void goRoot() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RootTab()),
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
              const SizedBox(
                height: 16,
              ),
              const CircularProgressIndicator(
                color: Colors.white,
              )
            ],
          ),
        ));
  }
}
