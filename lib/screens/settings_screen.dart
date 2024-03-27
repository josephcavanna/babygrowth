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
    const radius = 15.0;
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
            const SizedBox(height: 20),
            const Text(
              'ACCOUNT',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius)),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  color: Colors.grey[300],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.email),
                            SizedBox(width: 10),
                            Text('Email: ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text(
                          loggedInUser.email!,
                          
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        MaterialButton(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(radius),
                            ),
                            color: buttonColor,
                            textColor: textButtonColor,
                            padding: const EdgeInsets.all(10),
                            child: const SizedBox(
                              width: 100,
                              child: Text(
                                'Log out',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            onPressed: () {
                              if (_auth.currentUser != null) {
                                _auth.signOut();
                                Navigator.pop(context);
                              } else {
                                Navigator.pop(context);
                              }
                            }),
                        Column(
                          children: [
                            _showButton > 0
                            ? MaterialButton(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(radius),
                                ),
                                color: Colors.red,
                                textColor: textButtonColor,
                                padding: const EdgeInsets.all(10),
                                child: const Text('Delete Account'),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text(
                                          'Confirm with your email and password'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            textAlign: TextAlign.center,
                                            onChanged: (newEmail) =>
                                                email = newEmail,
                                            decoration: const InputDecoration(
                                              hintText: 'Enter email',
                                              hintStyle:
                                                  TextStyle(color: Colors.grey),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 20.0),
                                            ),
                                          ),
                                          TextField(
                                            textAlign: TextAlign.center,
                                            onChanged: (newPassword) =>
                                                password = newPassword,
                                            obscureText: true,
                                            decoration: const InputDecoration(
                                              hintText: 'Enter password',
                                              hintStyle:
                                                  TextStyle(color: Colors.grey),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 20.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            AuthCredential credential =
                                                EmailAuthProvider.credential(
                                                    email: email,
                                                    password: password);
                                            loggedInUser
                                                .reauthenticateWithCredential(
                                                    credential);
                                            _auth.currentUser!.delete();
                                            Navigator.popUntil(
                                                context,
                                                ModalRoute.withName(
                                                    WelcomeScreen.id));
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
                            : MaterialButton(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(radius),
                                ),
                                color: buttonColor,
                                textColor: textButtonColor,
                                padding: const EdgeInsets.all(10),
                                child: const SizedBox(
                                  width: 100,
                                  child: Text(
                                    'Delete all data',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete all data?'),
                                      content: const Text(
                                          'This will delete all measurement data associated with this account.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            _firestore
                                                .collection(_auth.currentUser!.uid)
                                                .get()
                                                .then((snapshot) {
                                              for (DocumentSnapshot ds
                                                  in snapshot.docs) {
                                                ds.reference
                                                    .collection('entries')
                                                    .get()
                                                    .then((snapshot) {
                                                  for (DocumentSnapshot ds
                                                      in snapshot.docs) {
                                                    ds.reference.delete();
                                                  }
                                                });
                                              }
                                            });
                                            _firestore
                                                .collection(_auth.currentUser!.uid)
                                                .get()
                                                .then((snapshot) {
                                              for (DocumentSnapshot ds
                                                  in snapshot.docs) {
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
                                                Future.delayed(
                                                    const Duration(seconds: 1), () {
                                                  Navigator.of(context).pop(true);
                                                });
                                                return const AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(75.0),
                                                    ),
                                                  ),
                                                  backgroundColor: Colors.white70,
                                                  content: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                          'Data successfully deleted.',
                                                          textAlign:
                                                              TextAlign.center),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: const Text('Delete data'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                          ],
                        ),
                        
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const Text(
              'SETTINGS',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  color: Colors.grey[300],
                ),
                padding: const EdgeInsets.only(left: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.scale),
                        SizedBox(width: 10),
                        Text(
                      'Units:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                      ],
                    ),
                    
                    UnitNotifier(),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius)),
              child: const Padding(
                padding: EdgeInsets.all(30.0),
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
          ],
        ),
      ),
    );
  }
}
