import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/component/text_input_dialog.dart';
import '../common/const/data.dart';
import 'model/nickname_provider.dart';

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
  ref.read(nicknameProvider.notifier).state = enteredText;
  firestore
      .collection('user')
      .doc(FirebaseAuth.instance.currentUser!.email!)
      .set({'nickname': enteredText});
}