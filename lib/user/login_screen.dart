import 'package:dio/dio.dart';
import 'package:dodo/common/const/data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../common/const/colors.dart';
import '../common/default_layout.dart';
import '../common/screen/root_tab.dart';
import '../firebase_call/firebaseCall.dart';

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
            const SizedBox(
              height: 32,
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                height: MediaQuery.of(context).size.width / 3,
                child: Image.asset(
                  'assets/images/logo.png',
                )),
            const SizedBox(
              height: 32,
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '이 일은 내가 하고,',
                style: TextStyle(
                  // fontFamily: ,
                    fontSize: 15,
                    fontWeight: FontWeight.w100,
                    color: TEXT_COLOR),
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '저 일은 네가 하고',
                style: TextStyle(
                  // fontFamily: ,
                    fontSize: 15,
                    fontWeight: FontWeight.w100,
                    color: TEXT_COLOR),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '우리 둘이 두두!',
                style: TextStyle(
                    // fontFamily: ,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: TEXT_COLOR),
              ),
            ),
            const Spacer(),
            defaultTargetPlatform == TargetPlatform.android
                ? SizedBox(
                    height: 50,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black87,
                            backgroundColor: Colors.white),
                        onPressed: () async {
                              await signInWithGoogle();
                              await insertUser();
                              goRoot(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 18,
                                height: 18,
                                child: Image.asset(
                                    'assets/images/google_logo.png')),
                            const Text('     Sign in with Google', style: TextStyle(fontFamily: 'Robot'),)
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
                      await insertUser();
                      goRoot(context);
                    },
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: () async {
                  await FirebaseAuth.instance.signInAnonymously();
                  await insertUser();
                  goRoot(context);


                }, child: const Text('게스트로 들아가기')),
                IconButton(onPressed: (){}, icon: const Icon(Icons.info))
              ],
            ),
            const SizedBox(height: 50,)
          ],
        ),
      ),
    ));
  }

  void goRoot(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => RootTab()),
    (route) => false);
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
