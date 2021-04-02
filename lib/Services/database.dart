import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zopek/Modals/Constants.dart';
import 'package:zopek/Services/Utils.dart';

class DataBaseServices {
  uploadUserInfo(Map<String, dynamic> map, String uid) {
    FirebaseFirestore.instance.collection("Users").doc(uid).set(map);
  }

  addMessagingTokens(String token, String uid)async {
     List<dynamic> existingTokens =[];
     await FirebaseFirestore.instance.collection("Users").doc(uid).get().then((value) async{
        existingTokens= value.get("MessagingTokens");
     });
     if(existingTokens.contains(token)){
       return;
     }
     existingTokens.add(token);
     FirebaseFirestore.instance.collection("Users").doc(uid).update({
       "MessagingTokens":existingTokens,
     });
  }
  removeMessagingTokens(String token, String uid)async {
     List<dynamic> existingTokens =[];
     await FirebaseFirestore.instance.collection("Users").doc(uid).get().then((value) async{
        existingTokens= value.get("MessagingTokens");
     });
     existingTokens.removeWhere((element) => element==token);
     FirebaseFirestore.instance.collection("Users").doc(uid).update({
       "MessagingTokens":existingTokens,
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

  updateBio(String bio) {
    FirebaseFirestore.instance.collection('Users').doc(Constants.uid).update({
      'Bio': bio,
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
