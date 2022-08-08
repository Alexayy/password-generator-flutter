import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:password_generator_paper/screens/EditPasswordPage.dart';

import 'PasswordManager.dart';

class PassGeneratorPage extends StatelessWidget {
  final controller = TextEditingController();
  final appForPassword = TextEditingController();
  String password = '';

  Widget _buildButton() {
    final backgroundColor = MaterialStateColor.resolveWith((states) =>
        states.contains(MaterialState.pressed) ? Colors.black : Colors.pink);

    return ElevatedButton(
      style: ButtonStyle(backgroundColor: backgroundColor),
      onPressed: () {
        password = generatePassword();

        controller.text = password;
        // _create();
      },
      child: const Text("Generate Pass"),
    );
  }

  String generatePassword(
      {bool hasLetters = true,
      bool hasNumbers = true,
      bool hasSpecial = true}) {
    const length = 25;
    const letterLowerCase = 'qwertyuioplkjhgfdsazxcvbnm';
    const letterUppercase = 'QWERTYUIOPLKJHGFDSAZXCVBNM';
    const numbers = '1234567890';
    const specialChars = '`~!@#%^&*()-+=_\${}[];:|".,';

    String chars = '';
    if (hasLetters) chars += '$letterUppercase$letterLowerCase';
    if (hasNumbers) chars += '$numbers';
    if (hasSpecial) chars += '$specialChars';

    return List.generate(length, (index) {
      final indexRandom = Random().nextInt(chars.length);

      return chars[indexRandom];
    }).join('');
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  void _create() async {
    try {
      final User? user = auth.currentUser;
      final userUID = user?.uid;
      await firestore
          .collection("${user?.email}")
          .doc(appForPassword.text)
          .set({
        'userId': userUID,
        'appName': appForPassword.text,
        'generatedPass': password,
      });

      print("Successful login? " +
          "Username: " +
          userUID.toString() +
          ", appName: " +
          appForPassword.text +
          ", generatedPass: " +
          password);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = MaterialStateColor.resolveWith((states) =>
        states.contains(MaterialState.pressed) ? Colors.black : Colors.pink);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Generate Password',
          style: TextStyle(color: Colors.white),
        ),
        titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("assets/images/bg2.jpg"),
            fit: BoxFit.fitHeight,
          ),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const AnimatedOpacity(
                opacity: 0.5, duration: Duration(milliseconds: 1000)),
            BackdropFilter(
              filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                decoration:
                    new BoxDecoration(color: Colors.white.withOpacity(0.0)),
              ),
            ),
            const Text(
              'Insert the name of the app and press "Generate Pass"!!!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextFormField(
              cursorColor: Colors.red,

              // keyboardType: inputType,
              controller: appForPassword,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white70,
                hintText: 'App name',
              ),
            ), // APP TEXT FIELD
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              readOnly: true,
              enableInteractiveSelection: false,
              decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white54,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      final data = ClipboardData(text: controller.text);
                      Clipboard.setData(data);

                      const snackBar = SnackBar(
                        content: Text(
                          'Password Copied',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.orangeAccent,
                      );

                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(snackBar);
                    },
                  )),
            ), // PASSWORD TEXT FIELD
            const SizedBox(height: 12),

            _buildButton(),
            ElevatedButton(
              style: ButtonStyle(backgroundColor: backgroundColor),
              onPressed: _create,
              child: const Text('Save Pass'),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: Color(0xFFF8BBD0),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bg3.jpg"),
                  fit: BoxFit.fitWidth,
                ),
                color: Color(0xFFFCE4EC),
              ),
              child: Text('App Menu and Navigation',
                  style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              title: const Text('Password Manager'),
              tileColor: Color(0xFFF8BBD0),
              onTap: () {
                const CircularProgressIndicator();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PasswordManager(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Edit'),
              tileColor: Color(0xFFF8BBD0),
              onTap: () {
                const CircularProgressIndicator();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditPasswordPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
