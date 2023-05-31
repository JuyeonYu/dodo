

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dodo/common/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();
final firestore = FirebaseFirestore.instance;

final androidFullAdId = 'ca-app-pub-3940256099942544/1033173712'; // ca-app-pub-7604048409167711/2642760342
final iOSFullAdId = 'ca-app-pub-3940256099942544/1033173712';
final androidBannerId = 'ca-app-pub-3940256099942544/1033173712';
final iOSBannerId = 'ca-app-pub-3940256099942544/1033173712';

List<Color> labelColors = [Colors.grey, PRIMARY_COLOR, Colors.redAccent];