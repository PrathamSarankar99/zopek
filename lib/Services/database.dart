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
  uploadUserInfo(Map<String, dynamic> map, String uid) {
    FirebaseFirestore.instance.collection("Users").doc(uid).set(map);
  }

  Future<List<dynamic>> getWallpapers(String chatRoomID) async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection("ChatRooms")
        .doc(chatRoomID)
        .get();
    return snap.get("Wallpapers");
  }

  removeWallpaper(String chatRoomID, int index) async {
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

  Future<String> updateWallpaper(String chatRoomID, int index,
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

  addMessagingTokens(String token, String uid) async {
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

  removeMessagingTokens(String token, String uid) async {
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

  Future getUserBySearchText(String searchText) async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .where("SearchKeywords", arrayContains: searchText)
        .get();
  }

  Future getUserNameByEmail(String email) async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .where("Email", isEqualTo: email)
        .get();
  }

  Stream<DocumentSnapshot> getUserByID(String uid) {
    return FirebaseFirestore.instance.collection("Users").doc(uid).snapshots();
  }

  createChatRoom(String chatRoomID, chatRoomMap) async {
    await FirebaseFirestore.instance
        .collection("ChatRooms")
        .doc(chatRoomID)
        .set(chatRoomMap);
  }

  updateUsername(String username) {
    List<String> searchKeywords = Utils().generateKeywordList(username);
    FirebaseFirestore.instance.collection('Users').doc(Constants.uid).update({
      'UserName': username,
      'SearchKeywords': searchKeywords,
    });
  }

  updateBio(String status) {
    FirebaseFirestore.instance.collection('Users').doc(Constants.uid).update({
      'Status': status,
    });
  }

  updateProfilePicture(String url) {
    FirebaseFirestore.instance.collection('Users').doc(Constants.uid).update({
      'PhotoURL': url,
    });
  }

  Future<bool> setPassword(String password, String uid) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    documentSnapshot.reference.update({"Password": password}).catchError((e) {
      return false;
    });
    return true;
  }

  Future<String> getPassword(String uid) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    return documentSnapshot.get("Password");
  }

  updateUserPhoneNo(String newPhoneNumber) async {
    User user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("Users")
        .doc(user.uid)
        .get();
    snapshot.reference.update({
      "PhoneNo": newPhoneNumber,
    });
  }

  Stream<QuerySnapshot> getChatRoomStreamOfMessagesExHidden(
      String chatRoomID, String username) {
    return FirebaseFirestore.instance
        .collection("ChatRooms")
        .doc(chatRoomID)
        .collection("Messages")
        .where("Visible", arrayContains: username)
        .orderBy("Time", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getChatRoomStreamOfMessages(
      String chatRoomID, String username) {
    return FirebaseFirestore.instance
        .collection("ChatRooms")
        .doc(chatRoomID)
        .collection("Messages")
        .orderBy("Time", descending: true)
        .snapshots();
  }

  Future<void> sendMessage(
      String chatRoomID, Map<String, dynamic> messageMap) async {
    return await FirebaseFirestore.instance
        .collection("ChatRooms")
        .doc(chatRoomID)
        .collection("Messages")
        .doc()
        .set(messageMap);
  }

  Stream<QuerySnapshot> getExistingChatRooms(String username) {
    return FirebaseFirestore.instance
        .collection("ChatRooms")
        .where("Users", arrayContains: username)
        .orderBy("LastMessageTime", descending: true)
        .snapshots();
  }
}
