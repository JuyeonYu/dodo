import 'package:flutter/material.dart';

import '../const/colors.dart';

class CustomTextFormField extends StatelessWidget {
  final String? hintText;
  final String? errorText;
  final String? initialValue;
  final bool obscureText;
  final bool autofocus;
  final bool showCursorColor;
  final ValueChanged<String>? onChanged;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsets? contentPadding;

  const CustomTextFormField({
    required this.onChanged,
    this.obscureText = false,
    this.autofocus = false,
    this.showCursorColor = true,
    this.hintText,
    this.errorText,
    this.initialValue,
    this.backgroundColor,
    this.borderColor,
    this.contentPadding,

    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseBorder = OutlineInputBorder(
        borderSide: BorderSide(color: borderColor ?? INPUT_BORDER_COLOR, width: 1.0));
    return TextFormField(
      initialValue: initialValue,
      cursorColor: showCursorColor ? PRIMARY_COLOR : Colors.transparent,
      obscureText: obscureText,
      autofocus: autofocus,
      onChanged: onChanged,
      decoration: InputDecoration(
          contentPadding: contentPadding ?? EdgeInsets.all(20),
          hintText: hintText,
          errorText: errorText,
          hintStyle: TextStyle(color: BODY_TEXT_COLOR, fontSize: 14.0),
          fillColor: backgroundColor ?? INPUT_BG_COLOR,
          filled: true,
          border: baseBorder,
          enabledBorder: baseBorder,
          focusedBorder: baseBorder.copyWith(
              borderSide:
              baseBorder.borderSide.copyWith(color: showCursorColor ? PRIMARY_COLOR : Colors.transparent))),
    );
  }
}
