import 'dart:convert';

import 'package:dodo/common/const/data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../main.dart';
import '../const/colors.dart';

Color hexToColor(String hexCode) {
  String hex = hexCode.replaceAll('#', '');
  if (hex.length == 6) {
    hex = 'FF$hex';
  }
  return Color(int.parse(hex, radix: 16));
}

String generateShortHashFromUUID() {
  const uuid = Uuid();
  final randomUUID = uuid.v4(); // 랜덤 UUID 생성

  final bytes = utf8.encode(randomUUID); // UTF-8로 인코딩된 UUID 바이트 배열
  final digest = sha1.convert(bytes); // SHA-1 해시 계산

  final hash = digest.toString(); // 해시를 문자열로 변환
  final shortHash = hash.substring(0, 6); // 첫 6글자 추출

  return shortHash;
}

Future<String?> getNickName() async {
  Map<String, dynamic>? data =
      (await firestore.collection('user').doc(userId).get()).data();
  String? nickname = data?['nickname'];
  return nickname;
}

void restartApp() {
  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  runApp(const MyApp());
}

void checkLogin(BuildContext context) {
  if (FirebaseAuth.instance.currentUser == null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('로그인이 필요합니다.'),
      action: SnackBarAction(
        textColor: PRIMARY_COLOR,
        label: '바로가기',
        onPressed: () {
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      ),
    ));
  }
}
