import 'package:flutter/material.dart';

Color hexToColor(String hexCode) {
  String hex = hexCode.replaceAll('#', '');
  if (hex.length == 6) {
    hex = 'FF' + hex;
  }
  return Color(int.parse(hex, radix: 16));
}
