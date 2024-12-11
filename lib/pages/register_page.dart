import 'dart:math';

import 'package:chat_app/pages/confirmation_page.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:chat_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool passwordIsHide = true;

  @override
  Widget build(BuildContext context) {
    ChatAppState appState = context.watch<ChatAppState>();
    const weakPassword = SnackBar(
      content: Text('The password provided is too weak.'),
    );

    const emailAlreadyInUse = SnackBar(
      content: Text('The account already exists for that email.'),
    );

    return Scaffold(
      body: appState.loading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
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
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[100],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    width: 500,
                    height: 500,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                
                                'Регистрация',
                                style: TextStyle(
                                  fontSize: 40,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: _email,
                                decoration: InputDecoration(
                                  hintText: 'email@example.com',
                                  label: Text('Введите вашу почту'),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                obscureText: passwordIsHide,
                                controller: _password,
                                decoration: InputDecoration(
                                  hintText: 'Пароль',
                                  label: Text('Придумайте себе пароль'),
                                  border: InputBorder.none,
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(
                                      right: 10.0,
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          passwordIsHide = !passwordIsHide;
                                        });
                                      },
                                      icon: Icon(Icons.remove_red_eye),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: 500,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[300],
                                shape: LinearBorder(),
                              ),
                              onPressed: () async {
                                try {
                                  String userName = 'kkardo881@gmail.com';
                                  String password = 'qlrh vbam zccy zwek';
                                  int min = 100000;
                                  int max = 1000000;
                                  String randomCode =
                                      '${Random().nextInt(max - min) + min}';

                                  final smtpServer = gmail(userName, password);

                                  final message = Message()
                                    ..from = Address(userName, 'Fellows App')
                                    ..recipients.add(_email.text)
                                    ..subject = 'Подтверждение регистрации'
                                    ..text =
                                        'Добрый день! Что бы завершить регистрацию вам необходимо ввести код подтверждения: ${randomCode}';
                                  appState.setLoading(true);
                                  final sendReport =
                                      await send(message, smtpServer);
                                  appState.setLoading(false);
                                  appState.setCode(randomCode);

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ConfirmationPage(
                                        email: _email.text,
                                        password: _password.text,
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  print(e);
                                }
                              },
                              child: Text(
                                'Регистрация',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'У вас уже есть аккаунт?',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/**
 * 
 */
