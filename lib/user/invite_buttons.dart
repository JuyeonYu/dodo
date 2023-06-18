import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dodo/user/help.dart';
import 'package:dodo/user/model/nickname_provider.dart';
import 'package:dodo/user/model/partner_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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

  AdManagerInterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    loadAd();
  }

  void loadAd() {
    AdManagerInterstitialAd.load(
        adUnitId: defaultTargetPlatform == TargetPlatform.android
            ? androidFullAdId
            : iOSFullAdId,
        request: const AdManagerAdRequest(),
        adLoadCallback: AdManagerInterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('$ad loaded.');
            _interstitialAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('AdManagerInterstitialAd failed to load: $error');
          },
        ));
  }

  void showAd() {
    _interstitialAd?.show();
    loadAd();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_COLOR),
            onPressed: () {
              if (FirebaseAuth.instance.currentUser?.email == null) {
                checkLogin(context);
              }
              if (ref.read(nicknameProvider) == null ||
                  ref.read(nicknameProvider)!.isEmpty) {
                showSetNicknameSnackBar(context);
                return;
              }
              showAd();
              String shareCode = generateShortHashFromUUID();
              firestore
                  .collection('invitation')
                  .doc(FirebaseAuth.instance.currentUser?.email ?? '')
                  .set({
                'code': shareCode,
                'email': FirebaseAuth.instance.currentUser?.email ?? '',
                'name': ref.read(nicknameProvider),
                'timestamp': Timestamp.now()
              }, SetOptions(merge: true));
              showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: Text(shareCode),
                        content: const Text('위 코드를 상대방에게 공유하세요.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Share.share('두두 초대 코드: $shareCode\n안드로이드 다운로드: https://play.google.com/store/apps/details?id=com.chaechae.dodo\n아이폰 다운로드: https://apps.apple.com/kr/app/두두/id6449709551');
                            },
                            style: TextButton.styleFrom(
                                foregroundColor: PRIMARY_COLOR),
                            child: const Text('공유'),
                          ),
                        ]);
                  });
            },
            child: const Text('초대하기')),
        ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_COLOR),
            onPressed: () async {
              showAd();
              if (FirebaseAuth.instance.currentUser?.email == null) {
                checkLogin(context);
                return;
              }
              if (ref.read(nicknameProvider) == null ||
                  ref.read(nicknameProvider)!.isEmpty) {
                showSetNicknameSnackBar(context);
                return;
              }
              String? enteredText = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return const TextInputDialog(
                      title: '초대코드(최대 6자)',
                      hint: '초대코드를 입력해주세요(숫자, 소문자)',
                      maxLength: 6,
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
                  Map<String, dynamic> json = event.docs.first.data();
                  String? partnerEmail  = json['partnerEmail'];
                  if (partnerEmail!.isEmpty || partnerEmail != FirebaseAuth.instance.currentUser?.email) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                              title: const Text('알림'),
                              content: const Text(
                                  '이미 초대 받은 사용자입니다.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('닫기'),
                                ),
                              ]);
                        });
                  } else if(partnerEmail == FirebaseAuth.instance.currentUser?.email) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                              title: const Text('알림'),
                              content: const Text(
                                  '내가 만든 초대코드입니다.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('닫기', style: TextStyle(color: BACKGROUND_COLOR),),
                                ),
                              ]);
                        });
                  } else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {

                          String hostName = json['name'];
                          String hostEmail = json['email'];
                          Timestamp timestamp = json['timestamp'];
                          int diff = Timestamp.now().compareTo(timestamp);
                          print(diff);
                          return AlertDialog(
                              title: const Text('알림'),
                              content: Text('초대한 사람의 정보가 맞습니까?\n닉네임: $hostName'),
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
                                                  child: const Text('닫기', style: TextStyle(color: BACKGROUND_COLOR),),
                                                ),
                                              ]);
                                        });
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    '아니오',
                                    style: TextStyle(color: BACKGROUND_COLOR),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await firestore
                                        .collection('user')
                                        .doc(getUserId())
                                        .update({
                                      'partnerEmail': hostEmail,
                                    });
                                    await firestore
                                        .collection('user')
                                        .doc(hostEmail)
                                        .update({
                                      'partnerEmail': FirebaseAuth
                                          .instance.currentUser?.email ??
                                          '',
                                    });
                                    ref
                                        .read(partnerNotifierProvider.notifier)
                                        .setPartner(UserDomain(
                                        email: hostEmail,
                                        name: hostName,
                                        thumbnail: ''));
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    '네',
                                    style: TextStyle(color: PRIMARY_COLOR),
                                  ),
                                ),
                              ]);
                        });
                  }

                } else if (event.docs.length > 1) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                            title: const Text('알림'),
                            content: const Text(
                                '해당 초대 코드에 문제가 있습니다. 코대 코드 생성을 다시 한번 부탁드립니다.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('닫기', style: TextStyle(color: BACKGROUND_COLOR),),
                              ),
                            ]);
                      });
                } else {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                            title: const Text('없는 초대코드입니다.'),
                            // content: const Text('초대한 사람 email: $'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('닫기', style: TextStyle(color: BACKGROUND_COLOR),),
                              ),
                            ]);
                      });
                }
              });
            },
            child: inInvitated
                ? const CircularProgressIndicator()
                : const Text('초대받기')),
      ],
    );
  }

  void showSetNicknameSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('닉네임 설정이 필요합니다.'),
      action: SnackBarAction(
        textColor: PRIMARY_COLOR,
        label: '닉네임 설정',
        onPressed: () {
          setNickname(context, ref);
        },
      ),
    ));
  }
}
