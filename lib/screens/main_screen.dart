import 'package:babygrowth_app/screens/baby_list_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'account_screen.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'dart:io';
import 'package:babygrowth_app/methods/child_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcome_screen.dart';

class MainScreen extends StatefulWidget {
  static const String id = 'main_screen';

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentTab = 0;
  List pages = [BabyListHome(), AccountScreen()];
  Widget currentPage;
  File savedImage;
  final _auth = FirebaseAuth.instance;
  User loggedInUser;

  @override
  void initState() {
    currentPage = pages[0];
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      loggedInUser = user;
    } else {
      Navigator.pushNamed(context, WelcomeScreen.id);
    }
  }

  void getBabyImage() async {
    final directory = await syspaths.getApplicationDocumentsDirectory();
    String directoryPath = directory.path;
    String filePath = '$directoryPath/${ChildButton().name}.jpg';
    savedImage = File(filePath);
    print(savedImage.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.grey[700],
        unselectedItemColor: Colors.grey[400],
        unselectedFontSize: 14,
        selectedFontSize: 18,
        currentIndex: currentTab,
        onTap: (int index) {
          setState(() {
            currentTab = index;
            currentPage = pages[index];
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(FontAwesome5Solid.baby), label: 'Baby List'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.settings), label: 'Settings')
        ],
      ),
      body: currentPage,
    );
  }
}
