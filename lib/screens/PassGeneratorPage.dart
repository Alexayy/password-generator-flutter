import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PassGeneratorPage extends StatelessWidget {
  final controller = TextEditingController();
  final appForPassword = TextEditingController();

  Widget _buildButton() {
    final backgroundColor = MaterialStateColor.resolveWith((states) => states.contains(MaterialState.pressed) ? Colors.pink : Colors.black);

    return ElevatedButton(
      style: ButtonStyle(backgroundColor: backgroundColor),
      onPressed: () {
        final password = _generatePassword();

        controller.text = password;
        _create();
      },
      child: Text("Generate Pass"),
    );
  }

  String _generatePassword({ bool hasLetters = true, bool hasNumbers = true, bool hasSpecial = true }) {
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
      await firestore.collection('userData').doc().set({
        'userId' : userUID,
        'appName' : appForPassword.text,
        'generatedPass' : _generatePassword(),
      });
    } catch (e) {
      print(e);
    }
  }

  void _read() async {
    try {

    } catch (e) {
      print(e);
    }
  }

  void _update() async {
    try {

    } catch (e) {
      print(e);
    }
  }

  void _delete() async {
    try {

    } catch (e) {
      print(e);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Random Pass Generator',
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
                        content: Text('Password Copied',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Colors.pink,
                      );

                      ScaffoldMessenger.of(context)..removeCurrentSnackBar()..showSnackBar(snackBar);
                    },
                  )
              ),
            ), // PASSWORD TEXT FIELD
            const SizedBox(height: 12),

            _buildButton(),
          ],
        ),
      ),
    );
  }
}