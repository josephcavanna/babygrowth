import 'package:babygrowth_app/methods/unit_notifier.dart';
import 'package:babygrowth_app/screens/welcome_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  User loggedInUser;
  String password;
  String email;
  String resetEmail;
  int _showButton = 0;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      loggedInUser = user;
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = Colors.green[300];
    final textColor = Colors.white;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 100.0, horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Image.asset(
                  'assets/LogoGraphic.webp',
                  width: 100,
                ),
                Image.asset(
                  'assets/LogoText.webp',
                  width: 175,
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    Text(
                      'Disclaimer',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    Text(
                      'This app is intended for educational purposes only. Always seek the advice of your doctor or pediatrician.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(30.0),
              child: Column(
                children: [
                  Text(
                    'Measurement Units',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: buttonColor),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  UnitNotifier()
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            MaterialButton(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                color: buttonColor,
                textColor: textColor,
                padding: EdgeInsets.all(20),
                child: Text(
                  'Log out',
                ),
                onPressed: () {
                  if (_auth.currentUser != null) {
                    _auth.signOut();
                    Navigator.pop(context);
                  } else {
                    Navigator.pop(context);
                  }
                }),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: MaterialButton(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  color: buttonColor,
                  textColor: textColor,
                  padding: EdgeInsets.all(20),
                  child: Text('Delete all data'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete all data?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              _firestore
                                  .collection(_auth.currentUser.uid)
                                  .get()
                                  .then((snapshot) {
                                for (DocumentSnapshot ds in snapshot.docs) {
                                  ds.reference
                                      .collection('entries')
                                      .get()
                                      .then((snapshot) {
                                    for (DocumentSnapshot ds in snapshot.docs) {
                                      ds.reference.delete();
                                    }
                                  });
                                }
                              });
                              _firestore
                                  .collection(_auth.currentUser.uid)
                                  .get()
                                  .then((snapshot) {
                                for (DocumentSnapshot ds in snapshot.docs) {
                                  ds.reference.delete();
                                }
                              });
                              Navigator.pop(context);
                              setState(() {
                                _showButton++;
                              });
                              showDialog(
                                context: context,
                                builder: (context) {
                                  Future.delayed(Duration(seconds: 1), () {
                                    Navigator.of(context).pop(true);
                                  });
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(75.0),
                                      ),
                                    ),
                                    backgroundColor: Colors.white70,
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Data successfully deleted.',
                                            textAlign: TextAlign.center),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Text('Delete all data'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
            _showButton > 0
                ? MaterialButton(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    color: buttonColor,
                    textColor: textColor,
                    padding: EdgeInsets.all(20),
                    child: Text('Delete Account'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Confirm with your email and password'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                keyboardType: TextInputType.emailAddress,
                                textAlign: TextAlign.center,
                                onChanged: (newEmail) => email = newEmail,
                                decoration: InputDecoration(
                                  hintText: 'Enter email',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                ),
                              ),
                              TextField(
                                textAlign: TextAlign.center,
                                onChanged: (newPassword) =>
                                    password = newPassword,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Enter password',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                AuthCredential credential =
                                    EmailAuthProvider.credential(
                                        email: email, password: password);
                                loggedInUser
                                    .reauthenticateWithCredential(credential);
                                _auth.currentUser.delete();
                                Navigator.popUntil(context,
                                    ModalRoute.withName(WelcomeScreen.id));
                              },
                              child: Text('Delete account'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : Text(''),
          ],
        ),
      ),
    );
  }
}
