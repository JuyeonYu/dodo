import 'package:dodo/common/component/common_text_form_field.dart';
import 'package:dodo/common/const/colors.dart';
import 'package:flutter/material.dart';

class TextInputDialog extends StatefulWidget {
  final String title;
  final String hint;
  final int maxLength;

  const TextInputDialog({
    required this.title,
    required this.hint,
    required this.maxLength,
    Key? key,
  }) : super(key: key);

  @override
  _TextInputDialogState createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  bool isEmpty = true;
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
        onChanged: (String value) {
          setState(() {
            _textEditingController.text = value;
            isEmpty = value.isEmpty;
          });
        },
        hintText: '',
        borderColor: PRIMARY_COLOR,
        autofocus: true,
        maxLength: widget.maxLength,
      ),
      actions: [
        TextButton(
          onPressed: () {
            String enteredText = _textEditingController.text;
            if (enteredText.isEmpty) {
              return;
            }
            Navigator.of(context).pop(enteredText);
          },
          child: Text(
            '확인',
            style: TextStyle(color: isEmpty ? BACKGROUND_COLOR : PRIMARY_COLOR),
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
