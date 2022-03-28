import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:password_generator_paper/screens/LoginPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.pink[900],
          appBarTheme: const AppBarTheme(
              backgroundColor: Colors.pink,
              iconTheme: IconThemeData(color: Colors.red),
              // This will be applied to the action icon buttons that locates on the right side
              actionsIconTheme: IconThemeData(color: Colors.amber),
              centerTitle: false,
              elevation: 15,
              titleTextStyle: TextStyle(color: Colors.lightBlueAccent))
      ),
      home: LoginPage(),
    );
  }
}


