import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:zopek/Screens/AuthScreens/Signin.dart';
import 'package:zopek/Services/Constants.dart';
import 'package:zopek/Services/Helper.dart';
import 'package:zopek/Services/database.dart';

class PasswordView extends StatefulWidget {
  final String password;

  const PasswordView({Key key, this.password}) : super(key: key);
  @override
  _PasswordViewState createState() => _PasswordViewState();
}

class _PasswordViewState extends State<PasswordView> {
  var selectedindex = 0;
  String code = ' ';
  DataBaseServices dataBaseServices = new DataBaseServices();
  String alert = '';
  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.w500,
      color: Colors.black.withBlue(40),
    );
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    print("Code is $code");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (code == widget.password) {
        Navigator.pop(context, true);
      }
    });
    return Scaffold(
      backgroundColor: Colors.black.withBlue(40),
      body: Column(
        children: [
          Container(
            height: height * 0.15,
            width: width,
            color: Colors.black.withBlue(40),
            alignment: Alignment.center,
            child: SafeArea(
              child: Container(
                  height: height * 0.06,
                  width: height * 0.06,
                  child: SvgPicture.asset(
                    'assets/incognito.svg',
                  )),
            ),
          ),
          Container(
              height: height * 0.85,
              width: width,
              decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Text(
                              widget.password == ''
                                  ? "Incognito"
                                  : Constants.userName,
                              style: TextStyle(
                                fontSize: widget.password == '' ? 35 : 25,
                                color: Colors.black.withBlue(100),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              widget.password == ''
                                  ? "Set a pin"
                                  : Constants.email,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black.withBlue(40),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                DigitHolder(
                                  width: width,
                                  index: 0,
                                  selectedIndex: selectedindex,
                                  code: code,
                                ),
                                DigitHolder(
                                    width: width,
                                    index: 1,
                                    selectedIndex: selectedindex,
                                    code: code),
                                DigitHolder(
                                    width: width,
                                    index: 2,
                                    selectedIndex: selectedindex,
                                    code: code),
                                DigitHolder(
                                    width: width,
                                    index: 3,
                                    selectedIndex: selectedindex,
                                    code: code),
                              ],
                            ),
                            Visibility(
                              visible: (code.length == 4 &&
                                  alert != '' &&
                                  code != widget.password),
                              child: Text(alert,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 20,
                                    fontFamily: 'NotoSerif',
                                    fontWeight: FontWeight.w900,
                                  )),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 20),
                              width: MediaQuery.of(context).size.width,
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Alert'),
                                            content: Text(
                                                "Your pin will be reset and you will be logged out."),
                                            actions: [
                                              FlatButton.icon(
                                                  onPressed: () async {
                                                    setState(() {
                                                      dataBaseServices
                                                          .setPassword(
                                                              '', Constants.uid)
                                                          .then((value1) {
                                                        Helper.saveUserLoggedInSP(
                                                                false)
                                                            .then((value2) => {
                                                                  FirebaseAuth
                                                                      .instance
                                                                      .signOut(),
                                                                  Navigator.of(
                                                                          context)
                                                                      .pushReplacement(PageTransition(
                                                                          child:
                                                                              SignIn(),
                                                                          type:
                                                                              PageTransitionType.fade))
                                                                });
                                                      });
                                                    });
                                                  },
                                                  icon: Icon(Icons.check),
                                                  label: Text("Okay")),
                                              FlatButton.icon(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  icon: Icon(Icons.cancel),
                                                  label: Text("Cancel"))
                                            ],
                                          );
                                        });
                                  },
                                  child: Text('Forgot password?')),
                            )
                          ],
                        )),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Container(
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: FlatButton(
                                          height: double.maxFinite,
                                          onPressed: () {
                                            addDigit(1);
                                          },
                                          child: Text('1', style: textStyle)),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: FlatButton(
                                          height: double.maxFinite,
                                          onPressed: () {
                                            addDigit(2);
                                          },
                                          child: Text('2', style: textStyle)),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: FlatButton(
                                          height: double.maxFinite,
                                          onPressed: () {
                                            addDigit(3);
                                          },
                                          child: Text('3', style: textStyle)),
                                    ),
                                  ],
                                ),
                              )),
                          Expanded(
                              flex: 1,
                              child: Container(
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: FlatButton(
                                          height: double.maxFinite,
                                          onPressed: () {
                                            addDigit(4);
                                          },
                                          child: Text('4', style: textStyle)),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: FlatButton(
                                          height: double.maxFinite,
                                          onPressed: () {
                                            addDigit(5);
                                          },
                                          child: Text('5', style: textStyle)),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: FlatButton(
                                          height: double.maxFinite,
                                          onPressed: () {
                                            addDigit(6);
                                          },
                                          child: Text('6', style: textStyle)),
                                    ),
                                  ],
                                ),
                              )),
                          Expanded(
                              flex: 1,
                              child: Container(
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: FlatButton(
                                          height: double.maxFinite,
                                          onPressed: () {
                                            addDigit(7);
                                          },
                                          child: Text('7', style: textStyle)),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: FlatButton(
                                          height: double.maxFinite,
                                          onPressed: () {
                                            addDigit(8);
                                          },
                                          child: Text('8', style: textStyle)),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: FlatButton(
                                          height: double.maxFinite,
                                          onPressed: () {
                                            addDigit(9);
                                          },
                                          child: Text('9', style: textStyle)),
                                    ),
                                  ],
                                ),
                              )),
                          Expanded(
                              flex: 1,
                              child: Container(
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: FlatButton(
                                          height: double.maxFinite,
                                          onPressed: () {
                                            backspace();
                                          },
                                          child: Icon(Icons.backspace_outlined,
                                              color: Colors.black.withBlue(40),
                                              size: 30)),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: FlatButton(
                                          height: double.maxFinite,
                                          onPressed: () {
                                            addDigit(0);
                                          },
                                          child: Text('0', style: textStyle)),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: FlatButton(
                                          height: double.maxFinite,
                                          onPressed: () async {
                                            if (widget.password == '') {
                                              await dataBaseServices
                                                  .setPassword(
                                                      code, Constants.uid);
                                              Navigator.pop(context, false);
                                            } else {
                                              dataBaseServices
                                                  .getPassword(Constants.uid)
                                                  .then((password) {
                                                if (password == code) {
                                                  Navigator.pop(context, true);
                                                  return;
                                                }
                                                setState(() {
                                                  alert = 'Wrong Password!';
                                                });
                                              });
                                            }
                                          },
                                          child: Icon(Icons.check,
                                              color: Colors.black.withBlue(40),
                                              size: 30)),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  )
                ],
              ))
        ],
      ),
    );
  }

  addDigit(int digit) {
    if (code.trim().length > 3) {
      return;
    }
    setState(() {
      code = code.trim() + digit.toString();
      print('Code is $code');
      selectedindex = code.length;
    });
  }

  backspace() {
    if (code.trim().length == 0) {
      return;
    }
    setState(() {
      code = code.trim().substring(0, code.length - 1);
      selectedindex = code.length;
    });
  }
}

class DigitHolder extends StatelessWidget {
  final int selectedIndex;
  final int index;
  final String code;
  const DigitHolder({
    @required this.selectedIndex,
    Key key,
    @required this.width,
    this.index,
    this.code,
  }) : super(key: key);

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: width * 0.17,
      width: width * 0.17,
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: index == selectedIndex ? Colors.blue : Colors.transparent,
              offset: Offset(0, 0),
              spreadRadius: 1.5,
              blurRadius: 2,
            )
          ]),
      child: code.trim().length > index
          ? Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: Colors.black.withBlue(40),
                shape: BoxShape.circle,
              ),
            )
          : Container(),
    );
  }
}