// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chat_app/components/new_chat_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:chat_app/components/chat_card.dart';
import 'package:chat_app/main.dart';
import 'package:sorter/sorter.dart';

class ChatList extends StatefulWidget {
  String email;
  ChatList({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('users').snapshots();
  final Stream<QuerySnapshot> _messagesStream =
      FirebaseFirestore.instance.collection('messages').snapshots();

  TextEditingController searchChatText = TextEditingController();

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getAllChats(
      String searchMessageText) async {
    final users = await FirebaseFirestore.instance.collection('users').get();

    return users.docs;
  }

  Widget showSearchChatCards(String searchMessageText) {
    return FutureBuilder(
      future: getAllChats(searchMessageText),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final data = snapshot.data;
          final allSearchedUsers = data!
              .where((user) =>
                  user['user_id'].toString().startsWith(searchMessageText))
              .toList();

          return ListView.builder(
            itemCount: allSearchedUsers.length,
            itemBuilder: (context, index) {
              if (widget.email != allSearchedUsers[index]['email']) {
                return NewChatCard(
                  user: allSearchedUsers[index],
                  currentUser: widget.email,
                );
              }
              return Container();
            },
          );
        }

        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ChatAppState appState = context.watch<ChatAppState>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          right: BorderSide(
            width: 0.3,
            color: Colors.grey,
          ),
        ),
      ),
      width: 400,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 15.0,
              top: 15.0,
              right: 15.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Чаты',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 15.0,
              right: 15.0,
            ),
            child: Container(
              color: Colors.grey[100],
              width: 400,
              height: 50,
              child: TextField(
                onChanged: (text) {
                  appState.setSearchText(text);
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintStyle: TextStyle(
                    fontSize: 16,
                  ),
                  hintText: '@уникальный_id_пользователя',
                  label: Text('Поиск пользователя'),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Expanded(
            child: appState.searchText != ''
                ? showSearchChatCards(appState.searchText)
                : StreamBuilder(
                    stream: _usersStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          widget.email == '') {
                        return Center(child: CircularProgressIndicator());
                      }

                      return ListView(
                        shrinkWrap: true,
                        children: (snapshot.data != null)
                            ? snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                                if (widget.email != document['email']) {
                                  return ChatCard(
                                    isSearch: false,
                                    user: document,
                                    currentUser: widget.email,
                                  );
                                }
                                return Container();
                              }).toList()
                            : [],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
