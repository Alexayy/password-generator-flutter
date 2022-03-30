import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'EditPasswordPage.dart';

final List<dynamic> appName = <String>[];
final List<dynamic> password = <String>[];

final List<dynamic> entries = <String>[];

final List<int> colorCodes = <int>[600, 500, 100];

String appNamePassed = '';

class PasswordManager extends StatefulWidget {
  @override
  _PasswordManagerState createState() => _PasswordManagerState();

  String getAppName() {
    return appNamePassed;
  }
}

class _PasswordManagerState extends State<PasswordManager> {
  _PasswordManagerState();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  List<dynamic> smg = <dynamic>[];

  void _delete(String appName) async {
    final User? user = auth.currentUser;
    try {
      firestore.collection("${user?.email}").doc(appName).delete();
    } catch (e) {
      print(e);
    }
  }

  void _setAppName(String appName) {
    appNamePassed = appName;
  }

  String getAppName() {
    return appNamePassed;
  }

  @override
  Widget build(BuildContext context) {
    final User? user = auth.currentUser;
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/bg2.jpg"),
          fit: BoxFit.fitHeight,
          opacity: 0.5,
          colorFilter: ColorFilter.mode(Colors.white, BlendMode.modulate),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Manage Passwords',
          ),
          titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
          backgroundColor: Colors.transparent,
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: firestore.collection('${user?.email}').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    // snapshot.data.docs.map((doc) {
                    return Card(
                      child: ListTile(
                          title: Text(doc['appName'] ?? ''),
                          subtitle: Text(doc['generatedPass'] ?? ''),
                          leading: Icon(Icons.copy),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    const CircularProgressIndicator();
                                    _setAppName(doc['appName'] ?? '');
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditPasswordPage()));
                                  },
                                  icon: Icon(Icons.edit)),
                              IconButton(
                                  onPressed: () {
                                    _delete(doc['appName']);
                                  },
                                  icon: Icon(Icons.delete)),
                            ],
                          )),
                    );
                  }).toList(),
                );
              }
            }),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

// trailing: PopupMenuButton(
//   itemBuilder: (context) {
//     return [
//       PopupMenuItem(
//         child: Text('Delete Password'),
//         value: 'delete',
//         onTap: () {
//           _delete(doc['appName']);
//         },
//       ),
//       PopupMenuItem(
//         child: Text('Edit Password'),
//         enabled: true,
//         // value: 'update',
//         onTap: () {
//           const CircularProgressIndicator();
//           Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => EditPasswordPage()));
//         },
//       ),
//     ];
//   },
// ),
// onLongPress: () {
//   Clipboard.setData(
//       ClipboardData(text: doc['generatedPass']));
//   const snackBar = SnackBar(
//     content: Text(
//       'Password Copied',
//       style: TextStyle(fontWeight: FontWeight.bold),
//     ),
//     backgroundColor: Colors.pink,
//   );
//
//   Scaffold.of(context).showSnackBar(snackBar);
// }
