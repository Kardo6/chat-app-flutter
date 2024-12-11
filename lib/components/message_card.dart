// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';

class MessageCard extends StatelessWidget {
  String message;
  String messageId;
  Timestamp date;
  bool isFromUser;
  bool isMessageRead;
  String imageUrl;
  MessageCard({
    Key? key,
    required this.message,
    required this.date,
    required this.isFromUser,
    required this.messageId,
    required this.isMessageRead,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime messageDate =
        new DateTime.fromMillisecondsSinceEpoch(date.seconds * 1000);
    int hour = messageDate.hour;
    int minute = messageDate.minute;
    int year = messageDate.year;
    int month = messageDate.month;
    int day = messageDate.day;

    return ContextMenuRegion(
      contextMenu: ContextMenu(
        entries: [
          (isFromUser)
              ? MenuItem(
                  icon: Icons.delete,
                  label: 'Delete',
                  value: 'Delete',
                  onSelected: () async {
                    await FirebaseFirestore.instance
                        .collection('messages')
                        .doc(messageId)
                        .delete();
                  })
              : MenuItem(
                  label: '',
                  constraints: BoxConstraints(
                    maxWidth: 0,
                  ),
                ),
        ],
        padding: EdgeInsets.all(0),
      ),
      child: Container(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(
          minWidth: 100,
          maxWidth: 400,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isFromUser ? Colors.blue[200] : Colors.grey[200],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (imageUrl != '')
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              SizedBox(
                height: 10,
              ),
              Text(
                textAlign: TextAlign.justify,
                message,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                constraints: BoxConstraints(
                  minWidth: 100,
                  maxWidth: 100,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    (isFromUser == true)
                        ? Icon(
                            Icons.check_circle,
                            color: isMessageRead == true
                                ? Colors.blue[600]
                                : Colors.grey[600],
                            size: 20,
                          )
                        : Container(),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      '${hour}:${minute < 10 ? '0${minute}' : minute}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      '(${day}.${month})',
                      style: TextStyle(
                        fontSize: 8,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
