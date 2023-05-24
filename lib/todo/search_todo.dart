import 'dart:async';

import 'package:dodo/common/component/common_text_form_field.dart';
import 'package:dodo/common/const/data.dart';
import 'package:dodo/common/default_layout.dart';
import 'package:flutter/material.dart';

class Searchtodo extends StatefulWidget {
  const Searchtodo({Key? key}) : super(key: key);

  @override
  State<Searchtodo> createState() => _SearchtodoState();
}

class _SearchtodoState extends State<Searchtodo> {
  Timer? _debounceTimer;


  void _handleSearch(String searchTerm) {
    _debounceTimer?.cancel();

    // Debounce search by delaying the search action for 500 milliseconds
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      // var test = firestore.collection('todo').where('title', isGreaterThanOrEqualTo: searchTerm ).snapshots();


      print('Search term: $searchTerm');
    });
  }


  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(onPressed: (){
                Navigator.pop(context);
              }, icon: Icon(Icons.arrow_back_ios)),
              Expanded(child: CustomTextFormField(showCursorColor: false, borderColor: Colors.transparent, onChanged: (String value) {
                _handleSearch(value);
              }, autofocus: true, hintText: '검색어를 입력해주세요',contentPadding: EdgeInsets.fromLTRB(8, 0, 8, 0),))
            ],
          ),
        )
      ]),
    );
  }
}
