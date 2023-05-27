import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../common/component/common_text_form_field.dart';
import '../common/const/colors.dart';
import '../common/default_layout.dart';
import '../common/screen/root_tab.dart';
import 'model/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = '';
  String password = '';
  final dio = Dio();

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
        child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 32,
              ),
              Icon(
                Icons.ac_unit_outlined,
                size: MediaQuery.of(context).size.width / 3,
              ),
              Container(
                child: SizedBox(
                  height: 32,
                ),
              ),
              Text(
                '행복한 하루 되세요!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 32,
              ),
              SizedBox(
                height: 32,
              ),
              ElevatedButton(
                  onPressed: () async {
                    UserCredential userCredential = await signInWithGoogle();
                    if (userCredential.user?.email != null) {
                      UserDomain.myself.email = userCredential.user!.email!;
                    }
                    if (userCredential.user?.displayName != null) {
                      UserDomain.myself.name = userCredential.user!.displayName!;
                    }
                    if (userCredential.user?.photoURL != null) {
                      UserDomain.myself.thumbnail = userCredential.user!.photoURL!;
                    }
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => RootTab()),
                            (route) => false);
                  },
                  child: Text('login with google')),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: PRIMARY_COLOR,
                      padding: EdgeInsets.all(16)),
                  onPressed: () async {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => RootTab()),
                        (route) => false);
                  },
                  child: Text(
                    'sign in',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  )),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {
                        print('email: $email');
                      },
                      icon: Icon(Icons.adb)),
                  IconButton(
                      onPressed: () {}, icon: Icon(Icons.ac_unit_outlined)),
                  IconButton(onPressed: () {}, icon: Icon(Icons.adb))
                ],
              ),
              TextButton(
                  onPressed: () async {},
                  child: Text(
                    '회원가입',
                    style: TextStyle(color: Colors.black),
                  ))
            ],
          ),
        ),
      ),
    ));
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
