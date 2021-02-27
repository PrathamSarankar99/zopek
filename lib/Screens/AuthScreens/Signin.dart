import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:zopek/Screens/HomeScreens/Homepage.dart';
import 'package:zopek/Services/auth.dart';
import 'package:zopek/Services/database.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  FocusNode emailFN = FocusNode();
  FocusNode passwordFN = FocusNode();
  bool isLoading = false;
  AuthServices authServices = new AuthServices();
  TextEditingController emailTEC = TextEditingController();
  TextEditingController passwordTEC = TextEditingController();
  DataBaseServices dataBaseServices = new DataBaseServices();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final TapGestureRecognizer signupTGR = TapGestureRecognizer()
      ..onTap = () {
        Navigator.push(
            context,
            PageTransition(
                child: SignIn(),
                type: PageTransitionType.rightToLeft,
                duration: Duration(milliseconds: 300)));
      };
    DataBaseServices dataBaseServices = new DataBaseServices();
    return Scaffold(
      key: scaffoldKey,
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
                    GestureDetector(
                      child: Container(
                        margin: EdgeInsets.only(right: 20, left: 20, top: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              "Forgot Password?",
                              style: TextStyle(
                                fontFamily: 'NotoSerif',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    GestureDetector(
                      onTap: signIn,
                      child: Container(
                        alignment: Alignment.center,
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(right: 20, left: 20),
                        child: Text(
                          "Sign in",
                          style: TextStyle(
                              color: Colors.white, fontFamily: "NotoSerif"),
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            gradient: LinearGradient(colors: [
                              Color.fromRGBO(163, 197, 242, 1),
                              Color.fromRGBO(41, 192, 179, 1),
                              Color.fromRGBO(18, 232, 109, 1),
                            ])),
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
                            Text("Sign in with ",
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
                    SizedBox(
                      height: 40,
                    ),
                    RichText(
                      text: TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'NotoSerif',
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign up',
                              style: TextStyle(
                                color: Colors.black.withRed(150),
                              ),
                              recognizer: signupTGR,
                            ),
                          ]),
                    ),
                    SizedBox(height: 10),
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

  void signIn() async {
    setState(() {
      isLoading = true;
    });
    final ScaffoldMessengerState scaffoldMessenger =
        ScaffoldMessenger.of(context);
    if (!isValidEmail(emailTEC.text.trim())) {
      setState(() {
        isLoading = false;
      });
      scaffoldMessenger.showSnackBar(
        const SnackBar(
            duration: Duration(seconds: 2), content: Text('Invalid Email')),
      );
      emailFN.requestFocus();
    } else if (!isValidPassword(passwordTEC.text.trim())) {
      setState(() {
        isLoading = false;
      });
      scaffoldMessenger.showSnackBar(
        const SnackBar(
            duration: Duration(seconds: 2), content: Text('Invalid Password')),
      );
      passwordFN.requestFocus();
    } else {
      try {
        var user = await authServices.signInWithEmailandPassword(
            emailTEC.text, passwordTEC.text);
        if (user.runtimeType == String) {
          setState(() {
            isLoading = false;
          });
          scaffoldMessenger.showSnackBar(
            SnackBar(duration: Duration(seconds: 2), content: Text(user)),
          );
          return null;
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Homepage()));
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print(e.toString());
        scaffoldMessenger.showSnackBar(
            SnackBar(duration: Duration(seconds: 2), content: Text(e)));
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
