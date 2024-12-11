// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:chat_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_windows/image_picker_windows.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountSetup extends StatefulWidget {
  String email;
  AccountSetup({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<AccountSetup> createState() => _AccountSetupState();
}

class _AccountSetupState extends State<AccountSetup> {
  XFile? image;

  String? imageUrl;

  Future<XFile?> pickImage(ImageSource source) async {
    final imagePicker = ImagePickerWindows();
    final pickedFile = await imagePicker.getImageFromSource(source: source);

    return pickedFile;
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _name = TextEditingController();
    TextEditingController _surname = TextEditingController();
    TextEditingController _userId = TextEditingController();

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
              height: 600,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Настройка профиля',
                          style: TextStyle(
                            fontSize: 40,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100)),
                      width: 100,
                      child: InkWell(
                        onTap: () async {
                          var pickedImg = await pickImage(ImageSource.gallery);
                          setState(() {
                            image = pickedImg;
                          });
                        },
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundImage: (image != null)
                                  ? FileImage(File(image!.path))
                                  : AssetImage(
                                      'assets/tux.jpg',
                                    ),
                            ),
                            Positioned(
                              child: Container(
                                decoration: BoxDecoration(
                                    color:
                                        const Color.fromRGBO(224, 224, 224, .6),
                                    borderRadius: BorderRadius.circular(48)),
                                width: 100,
                                height: 100,
                                child: Center(
                                  child: Icon(Icons.add),
                                ),
                              ),
                            ),
                          ],
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
                          controller: _name,
                          decoration: InputDecoration(
                            hintText: 'Жалел',
                            label: Text('Введите ваше имя'),
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
                          controller: _surname,
                          decoration: InputDecoration(
                            hintText: 'Кабидоллаев',
                            label: Text('Введите свою фамилию'),
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
                          controller: _userId,
                          decoration: InputDecoration(
                            hintText: '@zhalelkabidollaev_',
                            label: Text('Придумайте себе id'),
                            border: InputBorder.none,
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
                          if (image != null) {
                            final cloudinary = Cloudinary.signedConfig(
                              apiKey: '711576926828756',
                              apiSecret: 'gUF8VZdnDmaHGRv3IT3ANGV8-QQ',
                              cloudName: 'dxfrm6efn',
                            );

                            final file = File(image!.path);
                            final response = await cloudinary.upload(
                              file: file.path,
                              fileBytes: file.readAsBytesSync(),
                              resourceType: CloudinaryResourceType.image,
                              fileName: '${DateTime.now()}_profile_picture',
                            );

                            setState(() {
                              imageUrl = response.secureUrl;
                            });
                          } else {
                            setState(() {
                              imageUrl =
                                  'https://res.cloudinary.com/dxfrm6efn/image/upload/v1731948041/profile_default.jpg';
                            });
                          }

                          CollectionReference users =
                              FirebaseFirestore.instance.collection('users');

                          await users.add({
                            'email': widget.email,
                            'full_name': '${_name.text} ${_surname.text}',
                            'user_id': '${_userId.text}',
                            'profile_picture': imageUrl,
                          });

                          SharedPreferences instance =
                              await SharedPreferences.getInstance();

                          await instance.setStringList('user', [
                            '${_name.text} ${_surname.text}',
                            imageUrl ?? '',
                            widget.email
                          ]);

                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
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
