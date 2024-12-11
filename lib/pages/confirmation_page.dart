// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:chat_app/pages/account_setup.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:chat_app/main.dart';

class ConfirmationPage extends StatefulWidget {
  String email;
  String password;

  ConfirmationPage({
    Key? key,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  final FocusNode _focusNode = FocusNode();

  final code = TextEditingController();
  int count = 0;

  @override
  Widget build(BuildContext context) {
    ChatAppState appState = context.watch<ChatAppState>();

    final snackbar = SnackBar(content: Text('Неверно введен код'));

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              'assets/background.webp',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: const Color.fromRGBO(224, 224, 224, 0.90),
            ),
          ),
          Container(
            child: Center(
              child: Container(
                height: 320,
                width: 550,
                child: Card(
                  color: Colors.grey[200],
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 25,
                      right: 25,
                      top: 20,
                    ),
                    child: Column(
                      children: [
                        Text(
                          textAlign: TextAlign.center,
                          'Введите 6-значный код, отправленный Вам на почту ${widget.email}.',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: 500,
                          child: TextField(
                            controller: code,
                            decoration: InputDecoration(
                                hintText: 'Введите свой код',
                                label: Text('Код подтверждения'),
                                border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: 500,
                          child: Text(
                            textAlign: TextAlign.center,
                            'В целях безопасности, не делитесь ни с кем этим кодом.',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: 500,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[300],
                              shape: LinearBorder(),
                            ),
                            onPressed: () async {
                              if (code.text.length == 6 &&
                                  code.text == appState.confirmationCode) {
                                try {
                                  final credential = await FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                    email: widget.email,
                                    password: widget.password,
                                  );

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => AccountSetup(
                                        email: widget.email,
                                      ),
                                    ),
                                  );
                                } on FirebaseAuthException catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.code),
                                      backgroundColor: Colors.red,
                                    ),
                                  );

                                  Navigator.of(context).pop();
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(snackbar);
                              }
                            },
                            child: Text(
                              'Вход',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Вернуться на страницу регистрации'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
