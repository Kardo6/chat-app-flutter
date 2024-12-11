// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_windows/image_picker_windows.dart';
import 'package:provider/provider.dart';

import 'package:chat_app/main.dart';

class SideMenu extends StatefulWidget {
  String image;
  String userId;
  String fullName;
  String dbId;

  SideMenu({
    Key? key,
    required this.image,
    required this.userId,
    required this.fullName,
    required this.dbId,
  }) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  Future<XFile?> pickImage(ImageSource source) async {
    final imagePicker = ImagePickerWindows();
    final pickedFile = await imagePicker.getImageFromSource(source: source);

    return pickedFile;
  }

  @override
  Widget build(BuildContext context) {
    ChatAppState appState = context.watch<ChatAppState>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(
          right: BorderSide(
            width: 0.3,
            color: Colors.grey,
          ),
        ),
      ),
      width: 50,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 15.0,
          bottom: 15.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Tooltip(
              message: 'Чаты',
              child: IconButton(
                style: IconButton.styleFrom(
                    shape: LinearBorder(
                        side: BorderSide(
                      color: Color.fromARGB(14, 252, 150, 150),
                    )),
                    backgroundColor: Colors.grey[300]),
                onPressed: () async {},
                icon: Icon(Icons.chat),
              ),
            ),
            Column(
              children: [
                Tooltip(
                  message: 'Выйти',
                  child: IconButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      appState.setCurrentMessaginUser(null);
                      appState.setLastMessages([]);
                    },
                    icon: Icon(Icons.logout),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Tooltip(
                  message: 'Настройки аккаунта',
                  child: IconButton(
                    onPressed: () async {
                      await showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            XFile? image;

                            String? imageUrl;
                            return StatefulBuilder(builder:
                                (BuildContext context, StateSetter setState) {
                              return Container(
                                height: 300,
                                width: 500,
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(100)),
                                            width: 100,
                                            child: InkWell(
                                              onTap: () async {
                                                var pickedImg = await pickImage(
                                                    ImageSource.gallery);
                                                setState(() {
                                                  image = pickedImg;
                                                });
                                              },
                                              child: Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            1000),
                                                    child: (image != null)
                                                        ? Image.file(
                                                            File(image!.path),
                                                            width: 100,
                                                            height: 100,
                                                            fit: BoxFit.cover,
                                                          )
                                                        : CachedNetworkImage(
                                                            imageUrl:
                                                                widget.image,
                                                            width: 100,
                                                            height: 100,
                                                            fit: BoxFit.cover,
                                                          ),
                                                  ),
                                                  Positioned(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: const Color
                                                              .fromRGBO(224,
                                                              224, 224, .6),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      48)),
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
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue[300],
                                              shape: LinearBorder(),
                                            ),
                                            onPressed: (image != null)
                                                ? () async {
                                                    final cloudinary =
                                                        Cloudinary.signedConfig(
                                                      apiKey: '711576926828756',
                                                      apiSecret:
                                                          'gUF8VZdnDmaHGRv3IT3ANGV8-QQ',
                                                      cloudName: 'dxfrm6efn',
                                                    );

                                                    final file =
                                                        File(image!.path);
                                                    final response =
                                                        await cloudinary.upload(
                                                      file: file.path,
                                                      fileBytes: file
                                                          .readAsBytesSync(),
                                                      resourceType:
                                                          CloudinaryResourceType
                                                              .image,
                                                      fileName:
                                                          '${DateTime.now()}_profile_picture_${Random(1121425)}',
                                                    );

                                                    setState(() {
                                                      imageUrl =
                                                          response.secureUrl;
                                                    });

                                                    FirebaseFirestore.instance
                                                        .collection('users')
                                                        .doc(widget.dbId)
                                                        .update({
                                                      'profile_picture':
                                                          imageUrl
                                                    });

                                                    Navigator.of(context).pop();
                                                  }
                                                : null,
                                            child: Text(
                                              "Обновить изображение",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Полное имя: ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            widget.fullName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            "Уникальный Id: ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                          Text(
                                            widget.userId,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Expanded(child: Container()),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red[300],
                                            shape: LinearBorder(),
                                          ),
                                          onPressed: () {
                                            FirebaseAuth.instance.signOut();
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            "Выйти из аккаунта",
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
                              );
                            });
                          });
                    },
                    icon: Icon(Icons.settings),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
