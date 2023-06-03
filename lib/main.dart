import 'dart:async';

import 'package:dodo/common/const/colors.dart';
import 'package:dodo/common/splash.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '두두',
        theme: ThemeData(
          checkboxTheme: CheckboxThemeData(
              fillColor: MaterialStatePropertyAll(PRIMARY_COLOR)),
          fontFamily: 'Pretendard',
          primarySwatch: Colors.blue,
        ),
        home: const SplashView(),
      ),
    );
  }
}
