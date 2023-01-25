import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_screen.dart';
import 'package:flutter/cupertino.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  String? email;
  String? password;
  String? resetEmail;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  void getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      Navigator.pushNamed(context, MainScreen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color color = Colors.black;
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        stops: const [0.3, 0.7],
        colors: [Colors.blue[200]!, Colors.pink[100]!],
      )),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: MediaQuery.of(context).orientation == Orientation.portrait
              ? const EdgeInsets.symmetric(horizontal: 32.0, vertical: 75)
              : const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                    icon: const Icon(CupertinoIcons.back),
                    color: color,
                    onPressed: () => Navigator.pop(context)),
                SizedBox(
                    height: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? 50
                        : 0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'logo',
                      child: Image.asset('assets/LogoGraphic.webp', width: 250),
                    ),
                    const SizedBox(
                      height: 100.0,
                    ),
                    TextField(
                      cursorColor: Colors.black54,
                      style: const TextStyle(color: color),
                      onChanged: (typedEmail) => email = typedEmail,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: color, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: color, width: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    TextField(
                      cursorColor: Colors.black54,
                      style: const TextStyle(color: color),
                      onChanged: (userPassword) => password = userPassword,
                      obscureText: true,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w300,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: color, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: color, width: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 24.0,
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          final loginUser =
                              await _auth.signInWithEmailAndPassword(
                                  email: email!, password: password!);
                          if (loginUser != null) {
                            Navigator.pushNamed(context, MainScreen.id);
                          }
                        } catch (e) {
                          print(e);
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Incorrect email or password.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Try Again'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          color: color,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    TextButton(
                      child: const Text(
                        'Reset Password',
                        style: TextStyle(
                          color: color,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: const Text('Reset password'),
                                  content: TextField(
                                    cursorColor: Colors.black54,
                                    style: const TextStyle(color: Colors.grey),
                                    onChanged: (typedEmail) =>
                                        resetEmail = typedEmail,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter email',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 20.0),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text('Reset'),
                                      onPressed: () {
                                        _auth.sendPasswordResetEmail(
                                            email: resetEmail!);
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
