import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final List<dynamic> appName = <String>[];
final List<dynamic> password = <String>[];

final List<dynamic> entries = <String>[];

final List<int> colorCodes = <int>[600, 500, 100];

class PasswordManager extends StatefulWidget {
  @override
  _PasswordManagerState createState() => _PasswordManagerState();
}

class _PasswordManagerState extends State<PasswordManager> {
  _PasswordManagerState();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // CollectionReference collectionReference =
  //     firestore.collection(user?.email);

  List<dynamic> smg = <dynamic>[];

  Future<void> _read() async {
    final User? user = auth.currentUser;

    CollectionReference collectionReference =
        firestore.collection("${user?.email}");

    QuerySnapshot querySnapshot = await collectionReference.get();

    querySnapshot.docs.map((e) => entries.add(e.data()));

    final allData = querySnapshot.docs.map((e) => e.data()).toList();

    smg = allData;

    print(allData.length);
    print(smg.length);

    // return allData;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final User? user = auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Passwords',
        ),
        titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: _read,
              child: Icon(
                Icons.access_alarm,
                size: 26.0,
              ),
            ),
          ),
        ],
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
                        onLongPress: () {
                          Clipboard.setData(
                              ClipboardData(text: doc['generatedPass']));
                          const snackBar = SnackBar(
                            content: Text(
                              'Password Copied',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: Colors.pink,
                          );

                          Scaffold.of(context).showSnackBar(snackBar);
                        }),
                  );
                }).toList(),
              );
            }
          }),
    );
  }
}
