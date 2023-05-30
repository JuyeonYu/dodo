import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dodo/user/model/partner_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';

import '../common/component/text_input_dialog.dart';
import '../common/const/colors.dart';
import '../common/const/data.dart';
import '../common/util/helper.dart';
import 'model/user.dart';
import 'package:flutter/foundation.dart';

class InviteButtons extends ConsumerStatefulWidget {
  const InviteButtons({Key? key}) : super(key: key);

  @override
  ConsumerState<InviteButtons> createState() => _InviteButtonsState();
}

class _InviteButtonsState extends ConsumerState<InviteButtons> {
  bool inInvitated = false;
  // AdManagerInterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    // loadAd();
  }

  void loadAd() {
    // AdManagerInterstitialAd.load(
    //     adUnitId: defaultTargetPlatform == TargetPlatform.android
    //         ? androidFullAdId
    //         : 'ca-app-pub-7604048409167711/7735304920',
    //     request: const AdManagerAdRequest(),
    //     adLoadCallback: AdManagerInterstitialAdLoadCallback(
    //       onAdLoaded: (ad) {
    //         debugPrint('$ad loaded.');
    //         _interstitialAd = ad;
    //       },
    //       onAdFailedToLoad: (LoadAdError error) {
    //         debugPrint('AdManagerInterstitialAd failed to load: $error');
    //       },
    //     ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_COLOR),
            onPressed: () {
              String shareCode = generateShortHashFromUUID();
              firestore
                  .collection('invitation')
                  .doc(FirebaseAuth.instance.currentUser?.email ?? '')
                  .set({
                'code': shareCode,
                'hostEmail': FirebaseAuth.instance.currentUser?.email ?? '',
                'hostName':
                    FirebaseAuth.instance.currentUser?.displayName ?? '',
                'timestamp': Timestamp.now()
              }, SetOptions(merge: true));
              showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    // _interstitialAd?.show();
                    return AlertDialog(
                        title: Text(shareCode),
                        content: const Text('위 코드를 상대방에게 공유하세요.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Share.share('두두 초대 코드: $shareCode');
                            },
                            child: const Text('공유'),
                            style: TextButton.styleFrom(foregroundColor: PRIMARY_COLOR),
                          ),
                        ]);
                  });
            },
            child: Text('초대하기')),
        ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_COLOR),
            onPressed: () async {
              // _interstitialAd?.show();
              String? enteredText = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return TextInputDialog(
                      title: '초대코드',
                      hint: '초대코드를 입력해주세요(숫자, 소문자)',
                    );
                  });

              if (enteredText == null || enteredText.isEmpty) {
                return;
              }
              var snapshots = firestore
                  .collection('invitation')
                  .where('code', isEqualTo: enteredText)
                  .snapshots();
              snapshots.listen((event) {
                if (event.docs.length == 1) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        Map<String, dynamic> json = event.docs.first.data();
                        String hostName = json['hostName'];
                        String hostEmail = json['hostEmail'];
                        Timestamp timestamp = json['timestamp'];
                        int diff = Timestamp.now().compareTo(timestamp);
                        print(diff);
                        return AlertDialog(
                            title: Text('알림'),
                            content: Text(
                                '초대한 사람의 정보가 맞습니까?\n이름: ${hostName}\nemail: ${hostEmail}'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                            title: Text('알림'),
                                            content: const Text(
                                                '해당 초대 코드에 문제가 있습니다. 코대 코드 생성을 다시 한번 부탁드립니다.'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('닫기'),
                                              ),
                                            ]);
                                      });
                                  Navigator.of(context).pop();
                                },
                                child: const Text('아니오'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  // setState(() {
                                  //   inInvitated = true;
                                  // });
                                  await firestore
                                      .collection('partnership')
                                      .doc(FirebaseAuth
                                              .instance.currentUser?.email ??
                                          '')
                                      .set({
                                    'partnerEmail': hostEmail,
                                    'partnerName': hostName,
                                  });
                                  await firestore
                                      .collection('partnership')
                                      .doc(hostEmail)
                                      .set({
                                    'partnerEmail': FirebaseAuth
                                            .instance.currentUser?.email ??
                                        '',
                                    'partnerName': FirebaseAuth.instance
                                            .currentUser?.displayName ??
                                        '',
                                  });
                                  ref.read(partnerNotifierProvider.notifier).setPartner(UserDomain(
                                      email: hostEmail,
                                      name: hostName,
                                      thumbnail: ''));
                                  // Navigator.pop(context);
                                  Navigator.of(context).pop();
                                },
                                child: const Text('네'),
                              ),
                            ]);
                      });
                } else if (event.docs.length > 1) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                            title: Text('알림'),
                            content: const Text(
                                '??해당 초대 코드에 문제가 있습니다. 코대 코드 생성을 다시 한번 부탁드립니다.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('닫기'),
                              ),
                            ]);
                      });
                } else {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                            title: Text('없는 초대코드입니다.'),
                            // content: const Text('초대한 사람 email: $'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('닫기'),
                              ),
                            ]);
                      });
                }
              });
            },
            child: inInvitated ? CircularProgressIndicator() : Text('초대받기')),
      ],
    );
  }
}
