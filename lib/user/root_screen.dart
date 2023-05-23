import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../common/component/common_text_form_field.dart';
import '../common/const/colors.dart';
import '../common/default_layout.dart';
import '../common/screen/root_tab.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = '';
  String password = '';
  final dio = Dio();

  @override
  Widget build(BuildContext context) {
    print('build');



    return DefaultLayout(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 32,
                  ),
                  Icon(
                    Icons.ac_unit_outlined,
                    size: MediaQuery.of(context).size.width / 3,
                  ),
                  Container(
                    child: SizedBox(
                      height: 32,
                    ),
                  ),
                  Text(
                    '행복한 하루 되세요!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  CustomTextFormField(
                      hintText: 'Email',
                      onChanged: (String value) {
                        print(value);
                        print(email);
                        email = value;
                      }),
                  SizedBox(
                    height: 16,
                  ),
                  CustomTextFormField(
                      obscureText: true,
                      hintText: 'Password',
                      onChanged: (String value) {
                        print(value);
                        password = value;
                      }),
                  SizedBox(
                    height: 32,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: PRIMARY_COLOR,
                          padding: EdgeInsets.all(16)),
                      onPressed: () async {
                        /*
                    local server test
                    final rawString = '$email:$password';
                    print('raw: $rawString');
                    Codec<String, String> stringToBase64 = utf8.fuse(base64);
                    String token = stringToBase64.encode(rawString);
                    final resp = await dio.post('http://$localIp/auth/login',
                        options: Options(headers: {
                          'authorization': 'Basic $token',
                        }));
                    print(resp.data);
                    storage.write(
                        key: ACCESS_TOKEN_KEY, value: resp.data['accessToken']);
                    storage.write(
                        key: REFRESH_TOKEN_KEY,
                        value: resp.data['refreshToken']);
                     */

                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => RootTab()),
                                (route) => false);

                      },
                      child: Text(
                        'sign in',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      )),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () {
                            print('email: $email');
                          },
                          icon: Icon(Icons.adb)),
                      IconButton(
                          onPressed: () {}, icon: Icon(Icons.ac_unit_outlined)),
                      IconButton(onPressed: () {}, icon: Icon(Icons.adb))
                    ],
                  ),
                  TextButton(
                      onPressed: () async {

                      },
                      child: Text(
                        '회원가입',
                        style: TextStyle(color: Colors.black),
                      ))
                ],
              ),
            ),
          ),
        ));
  }
}
