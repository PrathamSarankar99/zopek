import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:zopek/Screens/HomeScreens/Homepage.dart';
import 'package:zopek/Services/auth.dart';
import 'package:zopek/Services/database.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  FocusNode usernameFN = FocusNode();
  FocusNode emailFN = FocusNode();
  FocusNode passwordFN = FocusNode();
  AuthServices authServices = new AuthServices();
  DataBaseServices dataBaseServices = new DataBaseServices();
  TextEditingController usernameTEC = TextEditingController();
  TextEditingController emailTEC = TextEditingController();
  TextEditingController passwordTEC = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: JumpingDotsProgressIndicator(
                fontSize: 70.0,
                color: Colors.black.withBlue(50),
                numberOfDots: 3,
              ),
            )
          : SingleChildScrollView(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.all(25),
                        alignment: Alignment.centerLeft,
                        height: 330,
                        decoration: BoxDecoration(),
                        child: Text(
                          "Let's get you started.",
                          style:
                              TextStyle(fontSize: 50, fontFamily: 'NotoSerif'),
                        )),
                    Container(
                      margin: EdgeInsets.only(right: 20, left: 20),
                      height: 50,
                      width: double.maxFinite,
                      child: Padding(
                        padding: EdgeInsets.only(right: 10, left: 10),
                        child: TextField(
                          focusNode: usernameFN,
                          controller: usernameTEC,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.cyan,
                            ),
                            hintText: "Username",
                            hintStyle: TextStyle(
                                fontSize: 20, fontFamily: 'NotoSerif'),
                          ),
                        ),
                      ),
                      decoration:
                          BoxDecoration(color: Colors.white, boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withOpacity(0.5),
                          offset: Offset(0, 0),
                          spreadRadius: 1,
                          blurRadius: 10,
                        ),
                      ]),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 20, left: 20),
                      height: 50,
                      width: double.maxFinite,
                      child: Padding(
                        padding: EdgeInsets.only(right: 10, left: 10),
                        child: TextField(
                          focusNode: emailFN,
                          controller: emailTEC,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.mail,
                              color: Colors.cyan,
                            ),
                            hintText: "Email",
                            hintStyle: TextStyle(
                                fontSize: 20, fontFamily: 'NotoSerif'),
                          ),
                        ),
                      ),
                      decoration:
                          BoxDecoration(color: Colors.white, boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withOpacity(0.5),
                          offset: Offset(0, 0),
                          spreadRadius: 1,
                          blurRadius: 10,
                        ),
                      ]),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 20, left: 20),
                      height: 50,
                      width: double.maxFinite,
                      child: Padding(
                        padding: EdgeInsets.only(right: 10, left: 10),
                        child: TextField(
                          focusNode: passwordFN,
                          controller: passwordTEC,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.lock_outline_rounded,
                              color: Colors.cyan,
                            ),
                            hintText: "Password",
                            hintStyle: TextStyle(
                                fontSize: 20, fontFamily: 'NotoSerif'),
                          ),
                        ),
                      ),
                      decoration:
                          BoxDecoration(color: Colors.white, boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withOpacity(0.5),
                          offset: Offset(0, 0),
                          spreadRadius: 1,
                          blurRadius: 10,
                        ),
                      ]),
                    ),
                    SizedBox(height: 70),
                    GestureDetector(
                      onTap: signUp,
                      child: Container(
                        alignment: Alignment.center,
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            gradient: LinearGradient(colors: [
                              Color.fromRGBO(163, 197, 242, 1),
                              Color.fromRGBO(41, 192, 179, 1),
                              Color.fromRGBO(18, 232, 109, 1),
                            ])),
                        margin: EdgeInsets.only(right: 20, left: 20),
                        child: Text(
                          "Sign up",
                          style: TextStyle(
                              color: Colors.white, fontFamily: "NotoSerif"),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                        });
                        authServices.signInWithGoogle().then((value) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Homepage()));
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(18, 232, 109, 1),
                              spreadRadius: 1,
                            )
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        width: double.maxFinite,
                        height: 48,
                        margin: EdgeInsets.only(right: 20, left: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Sign up with ",
                                style: TextStyle(fontFamily: 'NotoSerif')),
                            Text(
                              "G",
                              style: TextStyle(
                                  color: Colors.blue, fontFamily: "NotoSerif"),
                            ),
                            Text(
                              "o",
                              style: TextStyle(
                                  color: Colors.red, fontFamily: "NotoSerif"),
                            ),
                            Text(
                              "o",
                              style: TextStyle(
                                  color: Colors.yellow,
                                  fontFamily: "NotoSerif"),
                            ),
                            Text(
                              "g",
                              style: TextStyle(
                                  color: Colors.blue, fontFamily: "NotoSerif"),
                            ),
                            Text(
                              "l",
                              style: TextStyle(
                                  color: Colors.green, fontFamily: "NotoSerif"),
                            ),
                            Text(
                              "e",
                              style: TextStyle(
                                  color: Colors.red, fontFamily: "NotoSerif"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  bool isValidPassword(String value) {
    if (value.length > 6) {
      return true;
    }
    return false;
  }

  bool isValidEmail(String value) {
    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  bool isValidUsername(String value) {
    if (value.length > 30) {
      return false;
    }
    return true;
  }

  void signUp() async {
    setState(() {
      isLoading = true;
    });
    final ScaffoldMessengerState scaffoldMessenger =
        ScaffoldMessenger.of(context);

    if (!isValidUsername(usernameTEC.text.trim())) {
      setState(() {
        isLoading = false;
      });
      scaffoldMessenger.showSnackBar(SnackBar(
          duration: Duration(seconds: 5),
          content: Text("Username length should not exceed 30 letters.")));
      usernameFN.requestFocus();
    } else if (!isValidEmail(emailTEC.text.trim())) {
      setState(() {
        isLoading = false;
      });
      scaffoldMessenger.showSnackBar(SnackBar(
          duration: Duration(seconds: 2), content: Text("Invalid Email")));
      emailFN.requestFocus();
    } else if (!isValidPassword(passwordTEC.text.trim())) {
      setState(() {
        isLoading = false;
      });
      scaffoldMessenger.showSnackBar(SnackBar(
          duration: Duration(seconds: 2), content: Text("Invalid Password")));
      passwordFN.requestFocus();
    } else {
      try {
        setState(() {
          isLoading = true;
        });
        var user = await authServices.signUpWithEmailandPassword(
            usernameTEC.text.trim(), emailTEC.text, passwordTEC.text);
        if (user.runtimeType == String) {
          setState(() {
            isLoading = false;
          });
          scaffoldMessenger.showSnackBar(
              SnackBar(duration: Duration(seconds: 2), content: Text(user)));
          return null;
        }

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Homepage()));
      } catch (e) {
        print(e.toString());
      }
    }
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0, 350);
    path.quadraticBezierTo(30, 250, size.width / 2, 270);
    path.quadraticBezierTo(size.width, 315, size.width, 200);
    path.lineTo(size.width, 0);
    //path.lineTo(size.width, 175);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
