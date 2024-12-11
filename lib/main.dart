import 'package:chat_app/pages/account_setup.dart';
import 'package:chat_app/pages/confirmation_page.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart'
    show FirebaseAuthPlatform;
import 'package:go_router/go_router.dart';

late final FirebaseApp app;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class ChatAppState extends ChangeNotifier {
  String confirmationCode = '';
  var currentMessagingUser = null;
  List lastUnreadMessages = [];
  bool loading = false;
  String searchText = '';

  void setCode(String code) {
    confirmationCode = code;
    notifyListeners();
  }

  void setCurrentMessaginUser(currentUser) {
    currentMessagingUser = currentUser;
    notifyListeners();
  }

  void setLastMessages(List usersLastMessages) {
    lastUnreadMessages = usersLastMessages;
    notifyListeners();
  }

  void setLoading(bool isLoading) {
    loading = isLoading;
    notifyListeners();
  }

  void setSearchText(String text) {
    searchText = text;
    notifyListeners();
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String email = '';
  String userName = '';
  String imageUrl = '';
  String userId = '';
  String dbId = '';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatAppState(),
      child: MaterialApp(
        theme: ThemeData(
          fontFamily: 'ChatFont',
        ),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else {
                if (snapshot.hasData) {
                  FirebaseFirestore.instance
                      .collection('users')
                      .where('email', isEqualTo: snapshot.data!.email)
                      .get()
                      .then((document) {
                    for (final doc in document.docs) {
                      if (email == '') {
                        setState(() {
                          email = doc['email'];
                          imageUrl = doc['profile_picture'];
                          userName = doc['full_name'];
                          userId = doc['user_id'];
                          dbId = doc.id;
                        });
                      }
                    }
                  });

                  return HomePage(
                    email: snapshot.data!.email ?? '',
                    fullName: userName,
                    imageUrl: imageUrl,
                    userId: userId,
                    dbId: dbId,
                  );
                } else {
                  return const LoginPage();
                }
              }
            },
          ),
        ),
      ),
    );
  }
}

/**
 * 
 */