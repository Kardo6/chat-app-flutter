// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/pages/confirmation_page.dart';
import 'package:chat_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sorter/sorter.dart';

class ChatCard extends StatefulWidget {
  final user;
  String currentUser;
  bool isSearch;

  ChatCard({
    Key? key,
    required this.user,
    required this.currentUser,
    required this.isSearch,
  }) : super(key: key);

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  final Stream<QuerySnapshot> _messagesStream =
      FirebaseFirestore.instance.collection('messages').snapshots();

  bool hovered = false;

  String lastMessageText = '';
  String lastMessagedUser = '';
  Timestamp date = Timestamp(0, 0);
  DateTime messageDate = DateTime(2024);
  String hour = '';
  String minute = '';
  String time = '';
  int unreadMessages = 0;

  @override
  Widget build(BuildContext context) {
    ChatAppState appState = context.watch<ChatAppState>();

    _messagesStream.listen((messages) {
      List allMessages = [];

      for (final message in messages.docs) {
        allMessages.add(message);
      }

      appState.setLastMessages(allMessages);

      List allMessagesBetween = allMessages
          .where(
            (message) =>
                (message['from'] == widget.currentUser &&
                    message['to'] == widget.user['email']) ||
                (message['to'] == widget.currentUser &&
                    message['from'] == widget.user['email']),
          )
          .toList();

      final timestamps = allMessagesBetween.map((timestamp) {
        return timestamp['timestamp'].seconds;
      }).toList();

      final sortedTimestamps = Sorter.bubbleSort(timestamps);
      final allSortedMessages = [];

      for (final timestamp in sortedTimestamps) {
        final message = allMessagesBetween
            .firstWhere((message) => message['timestamp'].seconds == timestamp);
        allSortedMessages.add(message);
      }

      final lastUnreadMessages = allMessages
          .where(
            (message) =>
                (message['to'] == widget.currentUser &&
                    message['from'] == widget.user['email']) &&
                message['read'] == false,
          )
          .toList();

      if (allSortedMessages.isNotEmpty) {
        final lastMessage = allSortedMessages.last;
        setState(() {
          lastMessageText = lastMessage['message'];
          lastMessagedUser = lastMessage['from'] == widget.currentUser
              ? 'Вы'
              : widget.user['full_name'].split(' ')[0];
          date = lastMessage['timestamp'];
          messageDate = DateTime.fromMillisecondsSinceEpoch(date.seconds * 1000);
          hour =
              '${messageDate.hour < 10 ? '0${messageDate.hour}' : '${messageDate.hour}'}';
          minute =
              '${messageDate.minute < 10 ? '0${messageDate.minute}' : '${messageDate.minute}'}';
          time = '$hour:$minute';
          unreadMessages = lastUnreadMessages.length;
        });
      }
    });

    return InkWell(
      onHover: (val) {
        setState(() {
          hovered = val;
        });
      },
      onTap: () {
        appState.setCurrentMessaginUser(widget.user);
      },
      child: lastMessageText == '' && !widget.isSearch
          ? Container()
          : Container(
              color: hovered == true ||
                      (appState.currentMessagingUser != null &&
                          appState.currentMessagingUser['email'] ==
                              widget.user['email'])
                  ? Colors.grey[200]
                  : Colors.grey[100],
              width: 400,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 15.0,
                      right: 15.0,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100.0),
                                child: CachedNetworkImage(
                                  imageUrl: widget.user['profile_picture'],
                                  width: 75,
                                  height: 75,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 260,
                                    child: Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              widget.user['full_name'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(time),
                                          ],
                                        )),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    width: 260,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 200,
                                          child: Padding(
                                            padding: const EdgeInsets.all(0.0),
                                            child: Text(
                                              lastMessageText == ''
                                                  ? ''
                                                  : '${lastMessagedUser}: ${lastMessageText}',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        (unreadMessages == 0)
                                            ? Container()
                                            : Container(
                                                width: 25,
                                                height: 25,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.blue),
                                                child: Center(
                                                  child: Text(
                                                    '${unreadMessages}',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
