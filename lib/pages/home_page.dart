// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:chat_app/components/message_board.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sorter/sorter.dart';

import 'package:chat_app/components/chat_list.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/components/side_menu.dart';
import 'package:chat_app/pages/welcome_page.dart';

class HomePage extends StatefulWidget {
  String email;
  String fullName;
  String imageUrl;
  String userId;
  String dbId;

  HomePage({
    Key? key,
    required this.email,
    required this.fullName,
    required this.imageUrl,
    required this.userId,
    required this.dbId,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    ChatAppState appState = context.watch<ChatAppState>();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          children: [
            SafeArea(
              child: SideMenu(
                image: widget.imageUrl,
                userId: widget.userId,
                fullName: widget.fullName,
                dbId: widget.dbId,
              ),
            ),
            SafeArea(
              child: ChatList(
                email: widget.email,
              ),
            ),
            Expanded(
              child: appState.currentMessagingUser != null
                  ? MessageBoard(
                      userEmail: widget.email,
                    )
                  : WelcomePage(),
            ),
          ],
        );
      },
    );
  }
}
/**
 * Column(
                children: [
                  StreamBuilder(
                    stream: _messageStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final allMessages = snapshot.data!.docs.map((document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        return data;
                      }).toList();

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

                      return Expanded(
                        child: ListView(
                          shrinkWrap: true,
                          children: allSortedMessages.map((message) {
                            Map<String, dynamic> data =
                                message as Map<String, dynamic>;

                            final milliSeconds =
                                data['timestamp'].seconds * 1000;

                            return ListTile(
                              title: Row(
                                children: [
                                  Text(data['email']),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                      '(${DateFormat('d, MMMM, H:mm').format(DateTime.fromMillisecondsSinceEpoch(milliSeconds))})'),
                                ],
                              ),
                              subtitle: Text(data['message']),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 48,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              child: TextField(
                                maxLines: null,
                                controller: _messageController,
                                onSubmitted: (String text) async {
                                  await sendMessage(_messageController.text);
                                  _messageController.text = '';
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  hintText: 'Hi there!',
                                  label: Text('Message'),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 200,
                            height: 50,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                shape: LinearBorder(),
                                backgroundColor: Colors.amber[700],
                              ),
                              onPressed: () async {
                                await sendMessage(_messageController.text);
                                _messageController.text = '';
                              },
                              child: Text(
                                'Send',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
 */