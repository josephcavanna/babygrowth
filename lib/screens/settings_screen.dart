import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/widgets/unit_notifier.dart';
import '/screens/welcome_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late User loggedInUser;
  late String password;
  late String email;
  late String resetEmail;
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
    const buttonColor = Colors.black;
    const textButtonColor = Colors.white;
    const radius = 5.0;
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
            const SizedBox(
              height: 15,
            ),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius)),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: const [
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
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  const Text(
                    'Measurement Units',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  UnitNotifier()
                  
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            MaterialButton(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                ),
                color: buttonColor,
                textColor: textButtonColor,
                padding: const EdgeInsets.all(20),
                child: const Text(
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
                    borderRadius: BorderRadius.circular(radius),
                  ),
                  color: buttonColor,
                  textColor: textButtonColor,
                  padding: const EdgeInsets.all(20),
                  child: const Text('Delete all data'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete all data?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              _firestore
                                  .collection(_auth.currentUser!.uid)
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
                                  .collection(_auth.currentUser!.uid)
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
                                  Future.delayed(const Duration(seconds: 1),
                                      () {
                                    Navigator.of(context).pop(true);
                                  });
                                  return AlertDialog(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(75.0),
                                      ),
                                    ),
                                    backgroundColor: Colors.white70,
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Text('Data successfully deleted.',
                                            textAlign: TextAlign.center),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: const Text('Delete all data'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
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
                      borderRadius: BorderRadius.circular(radius),
                    ),
                    color: Colors.red,
                    textColor: textButtonColor,
                    padding: const EdgeInsets.all(20),
                    child: const Text('Delete Account'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm with your email and password'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                keyboardType: TextInputType.emailAddress,
                                textAlign: TextAlign.center,
                                onChanged: (newEmail) => email = newEmail,
                                decoration: const InputDecoration(
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
                                decoration: const InputDecoration(
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
                                _auth.currentUser!.delete();
                                Navigator.popUntil(context,
                                    ModalRoute.withName(WelcomeScreen.id));
                              },
                              child: const Text('Delete account'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : const Text(''),
          ],
        ),
      ),
    );
  }
}
