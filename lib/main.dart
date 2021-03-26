import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:zopek/Screens/AuthScreens/Signin.dart';
import 'package:zopek/Screens/HomeScreens/Homepage.dart';
import 'package:zopek/Modals/Camera.dart';
import 'package:zopek/Services/auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  CameraConfigurations.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(App());
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
