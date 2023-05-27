import 'package:dodo/common/default_layout.dart';
import 'package:flutter/material.dart';

import '../common/const/data.dart';


class ConfigScreen extends StatefulWidget {
  const ConfigScreen({Key? key}) : super(key: key);

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

      ],
    ));
  }
}
