

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();
final firestore = FirebaseFirestore.instance;

List<Color> labelColors = [Colors.grey, Colors.amberAccent, Colors.green, Colors.blueAccent, Colors.purpleAccent];

enum Avatar {
  bird,
  cat,
  horse,
  lizard,
  meerkat,
  owl,
  squirrel,
}

extension AvatarExtension on Avatar {
  String get rawValue {
    switch (this) {
      case Avatar.bird:
        return 'bird';
      case Avatar.cat:
        return 'cat';
      case Avatar.horse:
        return 'horse';
      case Avatar.lizard:
        return 'lizard';
      case Avatar.meerkat:
        return 'meerkat';
      case Avatar.owl:
        return 'owl';
      case Avatar.squirrel:
        return 'squirrel';
      default:
        throw Exception('Unknown avatar');
    }
  }
}
