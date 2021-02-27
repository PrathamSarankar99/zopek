import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';
import 'package:zopek/Screens/SettingScreens/ChangePhoneNo.dart';
import 'package:zopek/Services/Constants.dart';
import 'package:zopek/Services/Helper.dart';
import 'package:zopek/Services/database.dart';
import 'package:zopek/Screens/AuthScreens/Signin.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  DataBaseServices dataBaseServices = new DataBaseServices();
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.black.withBlue(40),
          title: Text("Settings"),
          actions: [
            PopupMenuButton(
              onSelected: (value) async {
                if (value == 'logout') {
                  await FirebaseAuth.instance.signOut();
                  await GoogleSignIn().signOut();
                  Helper.saveUserLoggedInSP(false);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => SignIn()));
                }
              },
              child: Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(Icons.more_vert),
              ),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    height: 20,
                    value: 'logout',
                    child: Text(
                      'Logout',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
                height: height * 0.13,
                width: width,
                color: Colors.black.withBlue(40),
                child: Row(
                  children: [
                    SizedBox(
                      width: width * 0.05,
                    ),
                    CircleAvatar(
                      radius: width * 0.09,
                      backgroundImage: NetworkImage(Constants.photoURL),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            Constants.fullName,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            "Online",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w300,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    )
                  ],
                )),
            FlatButton(
                height: height * 0.07,
                onPressed: () async {},
                child: Row(
                  children: [
                    Icon(Icons.add_a_photo_outlined),
                    SizedBox(
                      width: width * 0.05,
                    ),
                    Text("Set Profile Picture"),
                  ],
                )),
            Divider(
              height: 2,
              thickness: 2,
              color: Colors.blue.withOpacity(0.5),
            ),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(top: 15),
                    width: width,
                    height: 256,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: width * 0.045),
                          child: Text(
                            "Account",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        ListTile(
                          onTap: () {},
                          title: Padding(
                            padding: EdgeInsets.only(bottom: 5),
                            child: Text(
                              Constants.userName,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          subtitle: Text(
                            "Username, tap to change",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width * 0.04),
                          child: Divider(
                            height: 0.5,
                            thickness: 0.5,
                          ),
                        ),
                        ListTile(
                          onTap: () {},
                          title: Padding(
                            padding: EdgeInsets.only(bottom: 5),
                            child: Text(
                              "Bio",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          subtitle: Text(
                            "Add a few words about yourself.",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width * 0.04),
                          child: Divider(
                            height: 0.5,
                            thickness: 0.5,
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    duration: Duration(milliseconds: 300),
                                    child: ChangePhoneNo(),
                                    type: PageTransitionType.fade));
                          },
                          title: Padding(
                            padding: EdgeInsets.only(bottom: 5),
                            child: Text(
                              (Constants.phoneNo == ""
                                  ? "Phone no."
                                  : Constants.phoneNo),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          subtitle: Text(
                            (Constants.phoneNo == ""
                                ? "Add your phone no."
                                : "Phone no. tap to change"),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width * 0.04),
                          child: Divider(
                            height: 0.5,
                            thickness: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(top: 15),
                    width: width,
                    height: 155,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: width * 0.045),
                          child: Text(
                            "Settings",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        ListTile(
                          onTap: () {},
                          title: Row(
                            textBaseline: TextBaseline.ideographic,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  width: 50,
                                  height: 50,
                                  child: Icon(
                                    Icons.notifications_none,
                                    size: 25,
                                    color: Colors.black.withOpacity(0.5),
                                  )),
                              Text(
                                "Notifications and Sound",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width * 0.04),
                          child: Divider(
                            height: 0.5,
                            thickness: 0.5,
                          ),
                        ),
                        ListTile(
                          onTap: () {},
                          title: Row(
                            textBaseline: TextBaseline.ideographic,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  width: 50,
                                  height: 50,
                                  child: Icon(
                                    Icons.lock_outline_rounded,
                                    size: 25,
                                    color: Colors.black.withOpacity(0.5),
                                  )),
                              Text(
                                "Privacy and Security",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width * 0.04),
                          child: Divider(
                            height: 0.5,
                            thickness: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(top: 15),
                    width: width,
                    height: 155,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: width * 0.045),
                          child: Text(
                            "Help",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        ListTile(
                          onTap: () {},
                          title: Row(
                            textBaseline: TextBaseline.ideographic,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  width: 50,
                                  height: 50,
                                  child: Icon(
                                    Icons.chat,
                                    size: 25,
                                    color: Colors.black.withOpacity(0.5),
                                  )),
                              Text(
                                "Ask a Question",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width * 0.04),
                          child: Divider(
                            height: 0.5,
                            thickness: 0.5,
                          ),
                        ),
                        ListTile(
                          onTap: () {},
                          title: Row(
                            textBaseline: TextBaseline.ideographic,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  width: 50,
                                  height: 50,
                                  child: Icon(
                                    Icons.support_agent,
                                    size: 25,
                                    color: Colors.black.withOpacity(0.5),
                                  )),
                              Text(
                                "Suggest us",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width * 0.04),
                          child: Divider(
                            height: 0.5,
                            thickness: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
