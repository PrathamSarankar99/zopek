import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:zopek/Modals/Camera.dart';
import 'package:zopek/Screens/AuthScreens/Signin.dart';
import 'package:zopek/Screens/HomeScreens/Homepage.dart';
import 'package:zopek/Services/auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling message');
  await Firebase.initializeApp();
  Map<String, dynamic> sender = message.data;
  print("Printing the sender $sender");
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
    alert: false,
    badge: false,
    sound: false,
  );

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
  AuthServices authServices;

  @override
  void initState() {
    super.initState();

    authServices = new AuthServices();
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
        //Navigator.push(context, PageTransition(child: SettingsPage(), type: PageTransitionType.fade ));
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message came');
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: 'launch_background',
              ),
            ));
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      Map<String, dynamic> data = message.data;
      String sender = data["sender_id"];
      String receiver = data["receiver_id"];
      print("Printing the sender $sender");
      print('Handling a background message ${message.messageId}');
    });
  }

  Future<void> onActionSelected(String value) async {
    switch (value) {
      case 'subscribe':
        {
          print(
              'FlutterFire Messaging Example: Subscribing to topic "fcm_test".');
          await FirebaseMessaging.instance.subscribeToTopic('fcm_test');
          print(
              'FlutterFire Messaging Example: Subscribing to topic "fcm_test" successful.');
        }
        break;
      case 'unsubscribe':
        {
          print(
              'FlutterFire Messaging Example: Unsubscribing from topic "fcm_test".');
          await FirebaseMessaging.instance.unsubscribeFromTopic('fcm_test');
          print(
              'FlutterFire Messaging Example: Unsubscribing from topic "fcm_test" successful.');
        }
        break;
      case 'get_apns_token':
        {
          print('FlutterFire Messaging Example: Getting APNs token...');
          String token = await FirebaseMessaging.instance.getAPNSToken();
          print('FlutterFire Messaging Example: Got APNs token: $token');
        }
        break;
      default:
        break;
    }
  }

  int _messageCount = 0;

  /// The API endpoint here accepts a raw FCM payload for demonstration purposes.
  String constructFCMPayload(String token) {
    _messageCount++;
    return jsonEncode({
      'token': token,
      'data': {
        'via': 'FlutterFire Cloud Messaging!!!',
        'count': _messageCount.toString(),
      },
      'notification': {
        'title': 'Hello FlutterFire!',
        'body': 'This notification (#$_messageCount) was created via FCM!',
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    // return Yokes();
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
