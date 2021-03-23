import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:zopek/Screens/AuthScreens/Signin.dart';
import 'package:zopek/Screens/ChatScreens/PasswordView.dart';
import 'package:zopek/Screens/HomeScreens/Homepage.dart';

import 'package:zopek/Services/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
  //TODO : ImageLoading and sending progress.
  //TODO : Notifications.
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false, home: AuthenticityDecider());
  }
}

class AuthenticityDecider extends StatefulWidget {
  @override
  _AuthenticityDeciderState createState() => _AuthenticityDeciderState();
}

class _AuthenticityDeciderState extends State<AuthenticityDecider> {
  bool isUserLoggedIn = false;
  AuthServices authServices;
  @override
  void initState() {
    super.initState();
    authServices = new AuthServices();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
        stream: authServices.loggedInStream,
        builder: (context, user) {
          if (user.hasData) {
            return Homepage();
          }
          return SignIn();
        });
  }
}
