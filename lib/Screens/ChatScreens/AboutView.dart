import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zopek/Services/database.dart';

class About extends StatefulWidget {
  final String uid;

  const About({Key key, this.uid}) : super(key: key);
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  DataBaseServices dbs = new DataBaseServices();
  String photoURL;
  String username;
  String email;
   

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }
   
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.black.withBlue(40),
          title: Text(username),
        ),
      body: Container(),
    );
    
  }
 
  Future getUserInfo() async {
    Stream<DocumentSnapshot> snap = dbs.getUserByID(widget.uid);
    await snap.first.then((value) {
      setState(() {
        photoURL = value.get("PhotoURL");
        username = value.get("UserName").toString().length > 15
            ? '${value.get("UserName").toString().substring(0, 15)}...'
            : value.get("UserName").toString();

        email = value.get("Email");
      });
    });
  }
}