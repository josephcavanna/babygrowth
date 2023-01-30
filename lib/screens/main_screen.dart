import 'baby_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'settings_screen.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'dart:io';
import '/widgets/child_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcome_screen.dart';

class MainScreen extends StatefulWidget {
  static const String id = 'main_screen';

  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentTab = 0;
  List pages = [const BabyListScreen(), const AccountScreen()];
  late Widget currentPage;
  File? savedImage;
  final _auth = FirebaseAuth.instance;
  late User loggedInUser;

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
    String filePath = '$directoryPath/${const ChildButton().name}.jpg';
    savedImage = File(filePath);
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
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.child_care), label: 'Baby List'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.settings), label: 'Preferences')
        ],
      ),
      body: currentPage,
    );
  }
}
