import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../common/const/data.dart';

Future<void> insertUser() async {
  var response =
      (await firestore.collection('user').doc(getUserId()).get()).data();
  var token = await FirebaseMessaging.instance.getToken();
  if (response == null && FirebaseAuth.instance.currentUser?.email != null) {
    await firestore
        .collection('user')
        .doc(getUserId())
        .set({'pushToken': token});
  }
}
