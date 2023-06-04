import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/component/text_input_dialog.dart';
import '../common/const/data.dart';
import 'model/nickname_provider.dart';
import 'model/partner_provider.dart';
import 'model/user.dart';

Future<void> setNickname(BuildContext context, WidgetRef ref) async {
  String? enteredText = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return const TextInputDialog(
          title: '닉네임 설정',
          hint: '닉네임을 설정해주세요 (최대 8자)',
          maxLength: 8,
        );
      });
  if (enteredText == null || enteredText.isEmpty) {
    return;
  }
  ref.read(nicknameProvider.notifier).state = enteredText;
  firestore
      .collection('user')
      .doc(FirebaseAuth.instance.currentUser!.email!)
      .update({'nickname': enteredText});
}

Future<Map<String, dynamic>?> resetPartner(WidgetRef ref) async {
  Map<String, dynamic>? json = (await firestore
          .collection('user')
          .doc(FirebaseAuth.instance.currentUser?.email ?? '')
          .get())
      .data();
  if (json?['partnerEmail'] == null) {
    ref.read(partnerNotifierProvider.notifier).state = null;
  } else {
    String yourEmail = json!['partnerEmail'];
    Map<String, dynamic>? yourUserInfoJson = (await firestore
        .collection('user')
        .doc(yourEmail)
        .get())
        .data();
    ref.read(partnerNotifierProvider.notifier).state = UserDomain(
        email: yourEmail,
        name: yourUserInfoJson?['nickname'] ?? '',
        thumbnail: '');
  }
  return json;
}
