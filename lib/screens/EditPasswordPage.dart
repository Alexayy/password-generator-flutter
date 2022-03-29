import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditPasswordPage extends StatelessWidget {
  final controller = TextEditingController();
  final appForPassword = TextEditingController();
  final newAppForPassword = TextEditingController();
  String newAppName = '';
  String password = '';

  Widget _buildButton(BuildContext context, String newAppName) {
    final backgroundColor = MaterialStateColor.resolveWith((states) =>
        states.contains(MaterialState.pressed) ? Colors.pink : Colors.black);

    return ElevatedButton(
      style: ButtonStyle(backgroundColor: backgroundColor),
      onPressed: () {
        newAppName = newAppForPassword.text;
        password = controller.text;
        showAlertDialog(context);
        _update(appForPassword.text, newAppForPassword.text);
      },
      child: Text("Change details"),
    );
  }

  bool g = true;
  Future<bool> _asyncConvert(String userEmail) async {
    if (appForPassword.text.isEmpty) {
      return false;
    } else {
      var ref = firestore.collection('${userEmail}').doc(appForPassword.text);
      var some = ref.snapshots().listen((event) {
        if (event.exists) {
          g = true;
        } else {
          g = false;
        }
      });
    }

    return g;
  }

  showAlertDialog(BuildContext context) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    final bool a = password.isEmpty;
    bool b = await _asyncConvert('${user?.email}');

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed:  () { Navigator.pop(context); },
    );
    Widget continueButton = TextButton(
      child: Text("OK"),
      onPressed:  () { Navigator.pop(context); },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(a || !b ? "Password or app name wrong!!!" : "Success"),
      content: Text(a || !b ? "Try again!!!" : "YAY"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  void _update(String appName, String newAppName) async {
    final User? user = auth.currentUser;
    try {
      firestore.collection("${user?.email}").doc(appName).update({
        'appName': newAppName,
        'generatedPass': password,
      });

      firestore.collection("${user?.email}").doc(appName).get().then((doc) {
        if (doc.exists) {
          var data = doc.data();
          firestore.collection("${user?.email}").doc(newAppForPassword.text).set(data!).then((a) {
            firestore.collection("${user?.email}").doc(appName).delete();
          });
        }
      });


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
          'Edit Password',
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
              'Change the password or app name here!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12,),

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

            TextFormField(
              cursorColor: Colors.red,
              // keyboardType: inputType,
              controller: newAppForPassword,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'New App name',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
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
            _buildButton(context, newAppName)
          ],
        ),
      ),
    );
  }
}
