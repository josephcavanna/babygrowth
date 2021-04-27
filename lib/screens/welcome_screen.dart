import 'package:babygrowth_app/screens/login_screen.dart';
import 'package:babygrowth_app/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:babygrowth_app/screens/main_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    getCurrentUser();
    print(_auth.currentUser);
    super.initState();
  }

  void getCurrentUser() async {
    final user = await _auth.currentUser;
    if (user != null) {
      Navigator.pushNamed(context, MainScreen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        stops: [0.3, 0.7],
        colors: [Colors.blue[200], Colors.pink[100]],
      )),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: EdgeInsets.only(bottom: 30, top: 200),
                child: Container(
                  child: Column(
                    children: [
                      Hero(
                        tag: 'logo',
                        child: Image.asset(
                          'assets/LogoGraphic.webp',
                          width: 200,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Image.asset(
                        'assets/LogoText.webp',
                        width: 250,
                      ),
                      SizedBox(
                        height: 85,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                              onPressed: () => Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      transitionDuration: Duration(seconds: 1),
                                      pageBuilder: (_, __, ___) =>
                                          RegisterScreen(),
                                    ),
                                  ),
                              child: Container(
                                child: Text(
                                  'Register ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              )),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: Duration(seconds: 1),
                                pageBuilder: (_, __, ___) => LoginScreen(),
                              ),
                            ),
                            child: Text(
                              'Log in ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
