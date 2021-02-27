import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:zopek/Screens/AuthScreens/Signin.dart';
import 'package:zopek/Screens/HomeScreens/Homepage.dart';
import 'package:zopek/Services/Helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthenticityDecider(),
    );
  }
}

class AuthenticityDecider extends StatefulWidget {
  @override
  _AuthenticityDeciderState createState() => _AuthenticityDeciderState();
}

class _AuthenticityDeciderState extends State<AuthenticityDecider> {
  bool isUserLoggedIn = false;
  @override
  void initState() {
    super.initState();
    getUserLoggedInStatus();
  }

  getUserLoggedInStatus() async {
    await Helper.getUserLoggedInSP().then((value) {
      if (value.runtimeType == bool) {
        setState(() {
          isUserLoggedIn = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isUserLoggedIn) {
      return Homepage();
    } else {
      return SignIn();
    }
  }
}
