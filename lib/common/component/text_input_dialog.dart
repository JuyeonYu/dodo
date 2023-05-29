import 'package:dodo/common/component/common_text_form_field.dart';
import 'package:dodo/common/const/colors.dart';
import 'package:flutter/material.dart';

class TextInputDialog extends StatefulWidget {
  final String title;
  final String hint;

  const TextInputDialog({
    required this.title,
    required this.hint,
    Key? key,
  }) : super(key: key);

  @override
  _TextInputDialogState createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: CustomTextFormField(
        onChanged: (String value) {},
        hintText: '',
        borderColor: PRIMARY_COLOR,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () {
            String enteredText = _textEditingController.text;
            Navigator.of(context).pop(enteredText);
          },
          child: Text(
            '확인',
            style: TextStyle(color: PRIMARY_COLOR),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            '취소',
            style: TextStyle(color: BACKGROUND_COLOR),
          ),
        ),
      ],
    );
  }
}
