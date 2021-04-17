import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:zopek/Services/auth.dart';

class RealtimeDatabase {
  static var dbRef = FirebaseDatabase.instance;
  static DatabaseReference reference = dbRef.reference().child("Online");
  static init() {
    AuthServices authServices = new AuthServices();
    authServices.loggedInStream.first.then((value) async {
      if (value != null) {
        await reference.child(value.uid).set({
          "Status": "Online",
          "LastSeen": Timestamp.now().microsecondsSinceEpoch,
        });
        await reference.child(value.uid).onDisconnect().update({
          "Status": "Offline",
          "LastSeen": Timestamp.now().microsecondsSinceEpoch,
        });
      }
    });
  }

  static void pause() {
    AuthServices authServices = new AuthServices();
    authServices.loggedInStream.first.then((value) async {
      if (value != null) {
        await reference.child(value.uid).update({
          "Status": "Away",
          "LastSeen": Timestamp.now().microsecondsSinceEpoch,
        });
      }
    });
  }

  static void resume() {
    AuthServices authServices = new AuthServices();
    authServices.loggedInStream.first.then((value) async {
      if (value != null) {
        await reference.child(value.uid).update({
          "Status": "Online",
          "LastSeen": Timestamp.now().microsecondsSinceEpoch,
        });
      }
    });
  }

  static Stream<Event> getStream() {
    return reference.onValue;
  }
}
