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
      content: TextField(
        controller: _textEditingController,
        decoration: InputDecoration(
          hintText: widget.hint,
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            String enteredText = _textEditingController.text;
            Navigator.of(context).pop(enteredText);
          },
          child: Text('OK'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}