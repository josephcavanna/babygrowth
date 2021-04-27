import 'package:babygrowth_app/methods/unit_notifier.dart';
import 'package:babygrowth_app/screens/add_entry.dart';
import 'package:babygrowth_app/screens/baby_page.dart';
import 'package:babygrowth_app/screens/logs_screen.dart';
import 'package:babygrowth_app/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(BabyGrowth());
}

class BabyGrowth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UnitNotifier>(
      create: (context) => UnitNotifier(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(),
        initialRoute: WelcomeScreen.id,
        routes: {
          MainScreen.id: (context) => MainScreen(),
          BabyPage.id: (context) => BabyPage(),
          LoginScreen.id: (context) => LoginScreen(),
          WelcomeScreen.id: (context) => WelcomeScreen(),
          RegisterScreen.id: (context) => RegisterScreen(),
          AddEntry.id: (context) => AddEntry(),
          LogsScreen.id: (context) => LogsScreen(),
        },
      ),
    );
  }
}
