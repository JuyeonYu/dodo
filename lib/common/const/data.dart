

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();
final firestore = FirebaseFirestore.instance;

List<Color> labelColors = [Colors.grey, Colors.amberAccent, Colors.green, Colors.blueAccent, Colors.purpleAccent];