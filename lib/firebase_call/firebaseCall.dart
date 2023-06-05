import '../common/const/data.dart';

Future<void> insertUser() async {
  var response = (await firestore
      .collection('user')
      .doc(userId)
      .get()).data();
  if (response == null) {
    await firestore
        .collection('user')
        .doc(userId)
        .set({});
  }
}