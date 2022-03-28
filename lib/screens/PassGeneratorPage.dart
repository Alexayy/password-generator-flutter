import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'PasswordManager.dart';

class PassGeneratorPage extends StatelessWidget {
  final controller = TextEditingController();
  final appForPassword = TextEditingController();
  String password = '';

  Widget _buildButton() {
    final backgroundColor = MaterialStateColor.resolveWith((states) =>
        states.contains(MaterialState.pressed) ? Colors.pink : Colors.black);

    return ElevatedButton(
      style: ButtonStyle(backgroundColor: backgroundColor),
      onPressed: () {
        password = _generatePassword();

        controller.text = password;
        _create();
      },
      child: Text("Generate Pass"),
    );
  }

  String _generatePassword(
      {bool hasLetters = true,
      bool hasNumbers = true,
      bool hasSpecial = true}) {
    final length = 25;
    final letterLowerCase = 'qwertyuioplkjhgfdsazxcvbnm';
    final letterUppercase = 'QWERTYUIOPLKJHGFDSAZXCVBNM';
    final numbers = '1234567890';
    final specialChars = '`~!@#%^&*()-+=_\${}[];:|".,';

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
      await firestore.collection("${user?.email}").doc(appForPassword.text).set({
        'userId': userUID,
        'appName': appForPassword.text,
        'generatedPass': password,
      });
    } catch (e) {
      print(e);
    }
  }

  void _read() async {
    DocumentSnapshot documentSnapshot;
    final User? user = auth.currentUser;
    try {
      documentSnapshot =
          await firestore.collection("userData").doc(user?.email).get();
    } catch (e) {
      print(e);
    }
  }

  // void _update() async {
  //   final User? user = auth.currentUser;
  //   final userUID = user?.uid;
  //   try {
  //     firestore.collection("userData").doc(user?.email).update({
  //       'userId': userUID,
  //       'appName': appForPassword.text,
  //       'generatedPass': password,
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  void _delete() async {
    final User? user = auth.currentUser;
    try {
      firestore.collection("userData").doc(user?.email).delete();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = MaterialStateColor.resolveWith((states) =>
        states.contains(MaterialState.pressed) ? Colors.pink : Colors.black);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Generate Password',
        ),
        titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
      ),
      body: Container(
        padding: EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Random Pass Generator',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              cursorColor: Colors.red,
              // keyboardType: inputType,
              controller: appForPassword,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'App name',
              ),
            ), // APP TEXT FIELD

            const SizedBox(height: 12),
            TextField(
              controller: controller,
              readOnly: true,
              enableInteractiveSelection: false,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: () {
                      final data = ClipboardData(text: controller.text);
                      Clipboard.setData(data);

                      final snackBar = SnackBar(
                        content: Text(
                          'Password Copied',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.pink,
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
              child: Text('Save Pass'),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Text('App Menu and Navigation'),
            ),
            ListTile(
              title: const Text('Password Manager'),
              onTap: () {
                CircularProgressIndicator();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PasswordManager(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
    );
  }
}
