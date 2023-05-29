import 'package:dodo/common/default_layout.dart';
import 'package:dodo/common/screen/root_tab.dart';
import 'package:dodo/user/model/partner_provider.dart';
import 'package:dodo/user/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../user/login_screen.dart';
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
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
        );
      } else {
        firestore.collection('host_guest').doc(FirebaseAuth.instance.currentUser!.email).snapshots().listen((event) {
          if (event.data() == null) {
            goRoot();
            return ;
          }
          ref.read(partnerNotifierProvider.notifier).state = UserDomain(email: event.data()!['partnerEmail'], name: event.data()!['partnerName'], thumbnail: '');
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
        backgroundColor: PRIMARY_COLOR,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.ac_unit_outlined,
                size: MediaQuery.of(context).size.width / 2,
              ),
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
