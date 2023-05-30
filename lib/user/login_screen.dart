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
            Text(
              '우리 둘이 두두!',
              style: TextStyle(
                  // fontFamily: ,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: TEXT_COLOR),
            ),
            Spacer(),

            defaultTargetPlatform == TargetPlatform.android
                ? ElevatedButton(
                    onPressed: () async {
                      UserCredential userCredential = await signInWithGoogle();
                      if (userCredential.user?.email != null) {
                        UserDomain.myself.email = userCredential.user!.email!;
                      }
                      if (userCredential.user?.displayName != null) {
                        UserDomain.myself.name =
                            userCredential.user!.displayName!;
                      }
                      if (userCredential.user?.photoURL != null) {
                        UserDomain.myself.thumbnail =
                            userCredential.user!.photoURL!;
                      }
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => RootTab()),
                          (route) => false);
                    },
                    child: Image.asset('assets/images/google_login.png'))
                : SignInWithAppleButton(
                    onPressed: () async {
                      final appleCredential =
                          await SignInWithApple.getAppleIDCredential(
                        scopes: [
                          AppleIDAuthorizationScopes.email,
                          AppleIDAuthorizationScopes.fullName,
                        ],
                      );
                      final oauthCredential = OAuthProvider("apple.com").credential(
                        idToken: appleCredential.identityToken,
                        accessToken: appleCredential.authorizationCode,
                      );

                      await FirebaseAuth.instance.signInWithCredential(oauthCredential);

                      // updateAccount(); //실제 로그인/회원가입을 진행할 떄 필요한 코드를 작성하시면 됩니다.

                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => RootTab()),
                          (route) => false);
                      // print(credential);

                      // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
                      // after they have been validated with Apple (see `Integration` section for more information on how to do this)
                    },
                  )
// :FloatingActionButton.extended(onPressed: (){}, label: Row(children: [Image.asset('assets/images/apple_logo.svg'), Icon(Icons.apple), Text('Apple로 로그인하기')]), backgroundColor: Colors.black,)
//                 : ElevatedButton(
//                     onPressed: () async {
//                       UserCredential userCredential = await signInWithGoogle();
//                       if (userCredential.user?.email != null) {
//                         UserDomain.myself.email = userCredential.user!.email!;
//                       }
//                       if (userCredential.user?.displayName != null) {
//                         UserDomain.myself.name =
//                             userCredential.user!.displayName!;
//                       }
//                       if (userCredential.user?.photoURL != null) {
//                         UserDomain.myself.thumbnail =
//                             userCredential.user!.photoURL!;
//                       }
//                       Navigator.of(context).pushAndRemoveUntil(
//                           MaterialPageRoute(builder: (_) => RootTab()),
//                           (route) => false);
//                     },
//                     child: Text('login with apple')),
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
