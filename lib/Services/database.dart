import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path/path.dart';
import 'package:zopek/Modals/Camera.dart';
import 'package:zopek/Modals/Constants.dart';
import 'package:zopek/Modals/ImageSource.dart';
import 'package:zopek/Screens/ChatScreens/Capture.dart';
import 'package:zopek/Services/Utils.dart';

class DataBaseServices {
  static uploadUserInfo(Map<String, dynamic> map, String uid) {
    FirebaseFirestore.instance.collection("Users").doc(uid).set(map);
  }

  static setTypingStatus(String chatRoomID, String uid, bool typingbool) async {
    List users = [Constants.uid, uid];
    users.sort();
    DocumentSnapshot document = await FirebaseFirestore.instance
        .collection("ChatRooms")
        .doc(chatRoomID)
        .get();
    List<bool> typing = List<bool>.from(document.get("Typing"));
    typing[users.indexOf(Constants.uid)] = typingbool;
    document.reference.update({
      "Typing": typing,
    });
  }

  static Future<List<dynamic>> getWallpapers(String chatRoomID) async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection("ChatRooms")
        .doc(chatRoomID)
        .get();
    return snap.get("Wallpapers");
  }

  static removeWallpaper(String chatRoomID, int index) async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection("ChatRooms")
        .doc(chatRoomID)
        .get();
    List<dynamic> list = snap.get("Wallpapers");
    if (list.isEmpty) {
      return;
    }
    list[index] = "";
    snap.reference.update({
      "Wallpapers": list,
    });
  }

  static Stream<DocumentSnapshot> typingStatusStream(String chatRoomID) {
    return FirebaseFirestore.instance
        .collection("ChatRooms")
        .doc(chatRoomID)
        .snapshots();
  }

  static Future<String> updateWallpaper(String chatRoomID, int index,
      ImageSource source, BuildContext context) async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection("ChatRooms")
        .doc(chatRoomID)
        .get();
    List<dynamic> list = snap.get("Wallpapers");
    String downloadURL = "";
    switch (source) {
      case ImageSource.camera:
        {
          String path = await Navigator.push(
              context,
              PageTransition(
                  child: Capture(
                      cameraDescriptions:
                          CameraConfigurations.cameraDescriptionList),
                  type: PageTransitionType.fade));
          Reference reference = FirebaseStorage.instance.ref().child(
              "$chatRoomID/${Constants.uid}/wallpaper/${basename(path)}");
          UploadTask uploadTask = reference.putFile(File(path));
          TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() async {
            downloadURL = await reference.getDownloadURL();
            list[index] = downloadURL;
            snap.reference.update({
              "Wallpapers": list,
            });
          });
        }
        break;
      case ImageSource.gallery:
        {
          List<Asset> imageFile = await MultiImagePicker.pickImages(
              maxImages: 1, enableCamera: true);
          String path = await FlutterAbsolutePath.getAbsolutePath(
              imageFile[0].identifier);
          Reference reference = FirebaseStorage.instance.ref().child(
              "$chatRoomID/${Constants.uid}/wallpaper/${basename(path)}");
          UploadTask uploadTask = reference.putFile(File(path));
          TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() async {
            downloadURL = await reference.getDownloadURL();
            if (list.isEmpty) {
              list = List.generate(2, (index) => "");
            }
            list[index] = downloadURL;
            snap.reference.update({
              "Wallpapers": list,
            });
          });
        }
        break;
    }
    return downloadURL;
  }

  static addMessagingTokens(String token, String uid) async {
    List<dynamic> existingTokens = [];
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(uid)
        .get()
        .then((value) async {
      existingTokens = value.get("MessagingTokens");
    });
    if (existingTokens.contains(token)) {
      return;
    }
    existingTokens.add(token);
    FirebaseFirestore.instance.collection("Users").doc(uid).update({
      "MessagingTokens": existingTokens,
    });
  }

  static removeMessagingTokens(String token, String uid) async {
    List<dynamic> existingTokens = [];
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(uid)
        .get()
        .then((value) async {
      existingTokens = value.get("MessagingTokens");
    });
    existingTokens.removeWhere((element) => element == token);
    FirebaseFirestore.instance.collection("Users").doc(uid).update({
      "MessagingTokens": existingTokens,
    });
  }

  static Future getUserBySearchText(String searchText) async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .where("SearchKeywords", arrayContains: searchText)
        .get();
  }

  static Future getUserNameByEmail(String email) async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .where("Email", isEqualTo: email)
        .get();
  }

  static Stream<DocumentSnapshot> getUserByID(String uid) {
    return FirebaseFirestore.instance.collection("Users").doc(uid).snapshots();
  }

  static createChatRoom(String chatRoomID, chatRoomMap) async {
    await FirebaseFirestore.instance
        .collection("ChatRooms")
        .doc(chatRoomID)
        .set(chatRoomMap);
  }

  static updateUsername(String username) {
    List<String> searchKeywords = Utils().generateKeywordList(username);
    FirebaseFirestore.instance.collection('Users').doc(Constants.uid).update({
      'UserName': username,
      'SearchKeywords': searchKeywords,
    });
  }

  static updateBio(String status) {
    FirebaseFirestore.instance.collection('Users').doc(Constants.uid).update({
      'Status': status,
    });
  }

  static updateProfilePicture(String url) {
    FirebaseFirestore.instance.collection('Users').doc(Constants.uid).update({
      'PhotoURL': url,
    });
  }

  static Future<bool> setPassword(String password, String uid) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    documentSnapshot.reference.update({"Password": password}).catchError((e) {
      return false;
    });
    return true;
  }

  static Future<String> getPassword(String uid) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    return documentSnapshot.get("Password");
  }

  static updateUserPhoneNo(String newPhoneNumber) async {
    User user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("Users")
        .doc(user.uid)
        .get();
    snapshot.reference.update({
      "PhoneNo": newPhoneNumber,
    });
  }

  static Stream<QuerySnapshot> getChatRoomStreamOfMessagesExHidden(
      String chatRoomID, String username) {
    return FirebaseFirestore.instance
        .collection("ChatRooms")
        .doc(chatRoomID)
        .collection("Messages")
        .where("Visible", arrayContains: username)
        .orderBy("Time", descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getChatRoomStreamOfMessages(
      String chatRoomID, String username) {
    return FirebaseFirestore.instance
        .collection("ChatRooms")
        .doc(chatRoomID)
        .collection("Messages")
        .orderBy("Time", descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
      String chatRoomID, Map<String, dynamic> messageMap) async {
    return await FirebaseFirestore.instance
        .collection("ChatRooms")
        .doc(chatRoomID)
        .collection("Messages")
        .doc()
        .set(messageMap);
  }

  // static getExistingStatus(){
  //   FirebaseFirestore.instance.collection("Users").
  // }

  static Stream<QuerySnapshot> getExistingChatRooms(String uid) {
    return FirebaseFirestore.instance
        .collection("ChatRooms")
        .orderBy("LastMessageTime", descending: true)
        .where("Users", arrayContains: uid)
        .snapshots();
  }
}
