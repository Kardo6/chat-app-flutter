// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/pages/confirmation_page.dart';
import 'package:chat_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sorter/sorter.dart';

class NewChatCard extends StatefulWidget {
  final user;
  String currentUser;

  NewChatCard({
    Key? key,
    required this.user,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<NewChatCard> createState() => _NewChatCardState();
}

class _NewChatCardState extends State<NewChatCard> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    ChatAppState appState = context.watch<ChatAppState>();

    return InkWell(
      onHover: (val) {
        setState(() {
          hovered = val;
        });
      },
      onTap: () {
        appState.setCurrentMessaginUser(widget.user);
        appState.setSearchText('');
      },
      child: Container(
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
                                    ],
                                  )),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              width: 260,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 200,
                                    child: Padding(
                                      padding: const EdgeInsets.all(0.0),
                                      child: Text(
                                        'Начните новую беседу',
                                        overflow: TextOverflow.ellipsis,
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
