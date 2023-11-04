

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dodo/common/const/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

final storage = FlutterSecureStorage();
final firestore = FirebaseFirestore.instance;
String? getUserId() {
  User? user = FirebaseAuth.instance.currentUser;
  return (user?.email == '' || user?.email == null) ? user?.uid : user?.email;
}

const androidFullAdId = 'ca-app-pub-7604048409167711/2642760342';
const iOSFullAdId = 'ca-app-pub-7604048409167711/7735304920';
const androidBannerId = 'ca-app-pub-7604048409167711/8529511847';
const iOSBannerId = 'ca-app-pub-7604048409167711/5871558919';

List<Color> labelColors = [Colors.grey, PRIMARY_COLOR, Colors.redAccent];
DateFormat expirationDateFormat = DateFormat('yyyy. MM. dd');
