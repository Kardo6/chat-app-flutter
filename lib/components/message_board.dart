// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/components/message_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_windows/image_picker_windows.dart';
import 'package:provider/provider.dart';

import 'package:chat_app/main.dart';
import 'package:sorter/sorter.dart';

class MessageBoard extends StatefulWidget {
  String userEmail;
  MessageBoard({
    Key? key,
    required this.userEmail,
  }) : super(key: key);

  @override
  State<MessageBoard> createState() => _MessageBoardState();
}

class _MessageBoardState extends State<MessageBoard> {
  XFile? image;

  Future<XFile?> pickImage(ImageSource source) async {
    final imagePicker = ImagePickerWindows();
    final pickedFile = await imagePicker.getImageFromSource(source: source);

    return pickedFile;
  }

  TextEditingController message = TextEditingController();
  bool messageLoad = false;
  final Stream<QuerySnapshot> _messageStream =
      FirebaseFirestore.instance.collection('messages').snapshots();

  Future<void> readingAllMessages(allSortedMessages, appState) async {
    for (final message in allSortedMessages) {
      if (message['from'] == appState.currentMessagingUser['email']) {
        FirebaseFirestore.instance
            .collection('messages')
            .doc(message.id)
            .update({'read': true});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ChatAppState appState = context.watch<ChatAppState>();

    return Stack(
      clipBehavior: Clip.none,
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 75,
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 15.0,
                ),
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(200),
                        child: CachedNetworkImage(
                          imageUrl:
                              appState.currentMessagingUser['profile_picture'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      appState.currentMessagingUser['full_name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                  stream: _messageStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final fromMe = snapshot.data!.docs.where(
                      (message) =>
                          message['from'] == widget.userEmail &&
                          message['to'] ==
                              appState.currentMessagingUser['email'],
                    );
                    final fromRecipient = snapshot.data!.docs.where(
                      (message) => (message['from'] ==
                              appState.currentMessagingUser['email'] &&
                          message['to'] == widget.userEmail),
                    );

                    final allMessages = [...fromMe, ...fromRecipient];

                    final timestamps = allMessages.map((timestamp) {
                      return timestamp['timestamp'].seconds;
                    }).toList();

                    final sortedTimestamps = Sorter.bubbleSort(timestamps);
                    final allSortedMessages = [];

                    for (final timestamp in sortedTimestamps) {
                      final message = allMessages.firstWhere((message) =>
                          message['timestamp'].seconds == timestamp);
                      allSortedMessages.add(message);
                    }

                    readingAllMessages(allSortedMessages, appState);

                    return ListView(
                      reverse: true,
                      shrinkWrap: true,
                      children: allSortedMessages.reversed.map((message) {
                        if (message['from'] == widget.userEmail) {
                          return Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                MessageCard(
                                  message: message['message'],
                                  isFromUser: true,
                                  date: message['timestamp'],
                                  messageId: message.id,
                                  isMessageRead: message['read'],
                                  imageUrl: message['image'],
                                ),
                              ],
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            children: [
                              MessageCard(
                                message: message['message'],
                                isFromUser: false,
                                date: message['timestamp'],
                                messageId: message.id,
                                isMessageRead: message['read'],
                                imageUrl: message['image'],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }),
            ),
            Container(
              height: 50,
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 15.0,
                  right: 15.0,
                ),
                child: TextField(
                  onChanged: (text) {
                    setState(() {
                      message.text = text;
                    });
                  },
                  controller: message,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  expands: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(
                        right: 15.0,
                      ),
                      child: IconButton(
                        onPressed: () async {
                          var pickedImg = await pickImage(ImageSource.gallery);
                          setState(() {
                            image = pickedImg;
                          });
                          await showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                bool imageLoaded = false;
                                return StatefulBuilder(builder:
                                    (BuildContext context,
                                        StateSetter setState) {
                                  return Container(
                                    width: 700,
                                    height: 400,
                                    child: Column(
                                      children: [
                                        Container(
                                          child: Image.file(
                                            File(image!.path),
                                            height: 350,
                                            width: 700,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Expanded(child: Container()),
                                        Container(
                                          color: Colors.grey[200],
                                          height: 50,
                                          child: TextField(
                                            onChanged: (text) {
                                              setState(() {
                                                message.text = text;
                                              });
                                            },
                                            controller: message,
                                            maxLines: null,
                                            keyboardType:
                                                TextInputType.multiline,
                                            expands: true,
                                            decoration: InputDecoration(
                                              suffixIcon: Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 15.0,
                                                ),
                                                child: IconButton(
                                                  onPressed: () async {
                                                    setState(() {
                                                      messageLoad = true;
                                                      imageLoaded = true;
                                                    });

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
                                                          '${DateTime.now()}_message_${Random(10000)}',
                                                    );

                                                    String
                                                        currentMessagingUser =
                                                        appState.currentMessagingUser[
                                                            'email'];
                                                    String currentUser =
                                                        widget.userEmail;

                                                    CollectionReference
                                                        messages =
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'messages');

                                                    await messages.add({
                                                      'message':
                                                          message.text == ''
                                                              ? "Изображение"
                                                              : message.text,
                                                      'image':
                                                          response.secureUrl,
                                                      'from': currentUser,
                                                      'to':
                                                          currentMessagingUser,
                                                      'timestamp':
                                                          DateTime.now(),
                                                      'read': false,
                                                    });

                                                    setState(() {
                                                      messageLoad = false;
                                                      message.text = '';
                                                    });

                                                    Navigator.pop(context);
                                                  },
                                                  icon: imageLoaded == true
                                                      ? CircularProgressIndicator()
                                                      : Icon(
                                                          Icons.send_outlined,
                                                          color:
                                                              Colors.blue[600],
                                                        ),
                                                ),
                                              ),
                                              hintText: 'Введите сообщение',
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                              }).then((value) {
                            setState(() {
                              image = null;
                            });
                          });
                        },
                        icon: Icon(Icons.upload_outlined,
                            color: Colors.blue[600]),
                      ),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(
                        left: 15.0,
                      ),
                      child: IconButton(
                        onPressed: message.text == ''
                            ? null
                            : () async {
                                String currentMessagingUser =
                                    appState.currentMessagingUser['email'];
                                String currentUser = widget.userEmail;

                                CollectionReference messages = FirebaseFirestore
                                    .instance
                                    .collection('messages');

                                setState(() {
                                  messageLoad = true;
                                });

                                await messages.add({
                                  'message': message.text,
                                  'image': '',
                                  'from': currentUser,
                                  'to': currentMessagingUser,
                                  'timestamp': DateTime.now(),
                                  'read': false,
                                });

                                setState(() {
                                  messageLoad = false;
                                  message.text = '';
                                });
                              },
                        icon: messageLoad == true
                            ? CircularProgressIndicator()
                            : Icon(
                                Icons.send_outlined,
                                color: message.text == ''
                                    ? Colors.blue[200]
                                    : Colors.blue[600],
                              ),
                      ),
                    ),
                    hintText: 'Введите сообщение',
                    hintStyle: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
