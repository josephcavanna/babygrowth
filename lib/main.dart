import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

import '/widgets/unit_notifier.dart';
import '/screens/add_entry.dart';
import 'screens/baby_details_page.dart';
import 'screens/logs_list_screen.dart';
import '/screens/welcome_screen.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BabyGrowth());
}

class BabyGrowth extends StatelessWidget {
  const BabyGrowth({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UnitNotifier>(
      create: (context) => UnitNotifier(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(),
        initialRoute: WelcomeScreen.id,
        routes: {
          MainScreen.id: (context) => const MainScreen(),
          BabyDetailsPage.id: (context) => const BabyDetailsPage(),
          LoginScreen.id: (context) => const LoginScreen(),
          WelcomeScreen.id: (context) => const WelcomeScreen(),
          RegisterScreen.id: (context) => const RegisterScreen(),
          AddEntry.id: (context) => const AddEntry(),
          LogsListScreen.id: (context) => const LogsListScreen(),
        },
      ),
    );
  }
}
