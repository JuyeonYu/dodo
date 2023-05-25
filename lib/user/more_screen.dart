import 'package:dodo/common/default_layout.dart';
import 'package:flutter/material.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
        child: Column(
      children: [
        ElevatedButton(onPressed: () {}, child: Image.asset('flower.jpg'))
      ],
    ));
  }
}
