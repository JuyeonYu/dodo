import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
        // backgroundColor: TEXT_COLOR,
        child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 32,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 32,
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                height: MediaQuery.of(context).size.width / 3,
                child: Image.asset(
                  'assets/images/logo.png',
                )),
            Container(
              child: SizedBox(
                height: 32,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '이 일은 내가 하고,',
                style: TextStyle(
                  // fontFamily: ,
                    fontSize: 15,
                    fontWeight: FontWeight.w100,
                    color: TEXT_COLOR),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '저 일은 네가 하고',
                style: TextStyle(
                  // fontFamily: ,
                    fontSize: 15,
                    fontWeight: FontWeight.w100,
                    color: TEXT_COLOR),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '우리 둘이 두두!',
                style: TextStyle(
                    // fontFamily: ,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: TEXT_COLOR),
              ),
            ),


            Spacer(),
            defaultTargetPlatform == TargetPlatform.android
                ? SizedBox(
                    height: 50,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black87,
                            backgroundColor: Colors.white),
                        onPressed: () async {
                              await signInWithGoogle();
                          // if (userCredential.user?.email != null) {
                          //   UserDomain.myself.email =
                          //       userCredential.user!.email!;
                          // }
                          // if (userCredential.user?.displayName != null) {
                          //   UserDomain.myself.name =
                          //       userCredential.user!.displayName!;
                          // }
                          // if (userCredential.user?.photoURL != null) {
                          //   UserDomain.myself.thumbnail =
                          //       userCredential.user!.photoURL!;
                          // }
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => RootTab()),
                              (route) => false);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 18,
                                height: 18,
                                child: Image.asset(
                                    'assets/images/google_logo.png')),
                            Text('     Sign in with Google', style: TextStyle(fontFamily: 'Robot'),)
                          ],
                        )),
                  )
                : SignInWithAppleButton(
                    onPressed: () async {
                      final appleCredential =
                          await SignInWithApple.getAppleIDCredential(
                        scopes: [
                          AppleIDAuthorizationScopes.email,
                          AppleIDAuthorizationScopes.fullName,
                        ],
                      );
                      final oauthCredential =
                          OAuthProvider("apple.com").credential(
                        idToken: appleCredential.identityToken,
                        accessToken: appleCredential.authorizationCode,
                      );

                      await FirebaseAuth.instance
                          .signInWithCredential(oauthCredential);
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => RootTab()),
                          (route) => false);
                    },
                  ),
            SizedBox(height: 50,)
          ],
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
