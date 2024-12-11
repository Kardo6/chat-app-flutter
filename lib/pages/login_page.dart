import 'package:chat_app/main.dart';
import 'package:chat_app/pages/register_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool passwordIsHide = true;
  @override
  Widget build(BuildContext context) {
    const userNotFound = SnackBar(
      content: Text('Не найдено пользователя с таким email адресом.'),
    );

    const wrongPassword = SnackBar(
      content: Text('Неверный пароль.'),
    );

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
                      children: [
                        Text(
                          'Авторизация',
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
                            label: Text('Введите свой пароль'),
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
                            final credential = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                              email: _email.text,
                              password: _password.text,
                            );

                            String fullName = '';
                            String imageUrl = '';
                            final instance = await FirebaseFirestore.instance
                                .collection('users')
                                .where('email', isEqualTo: _email.text)
                                .get()
                                .then(
                              (inst) {
                                for (final doc in inst.docs) {
                                  fullName = doc['full_name'];
                                  imageUrl = doc['profile_picture'];
                                }
                              },
                            );

                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'user-not-found') {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(userNotFound);
                            } else if (e.code == 'wrong-password') {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(wrongPassword);
                            }
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
                    SizedBox(
                      height: 20,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RegisterPage(),
                          ),
                        );
                      },
                      child: Text(
                        'У вас нет аккаунта?',
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