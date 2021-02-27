import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zopek/Services/Constants.dart';
import 'package:zopek/Services/Helper.dart';

class DataBaseServices {
  uploadUserInfo(Map<String, dynamic> map, String uid) {
    FirebaseFirestore.instance.collection("Users").doc(uid).set(map);
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

  Stream<QuerySnapshot> getUserDetailsByUsername(String username) {
    return FirebaseFirestore.instance
        .collection("Users")
        .where("UserName", isEqualTo: username)
        .snapshots();
  }

  Future<Stream<DocumentSnapshot>> getUserByID(String uid) async {
    return FirebaseFirestore.instance.collection("Users").doc(uid).snapshots();
  }

  createChatRoom(String chatRoomID, chatRoomMap) async {
    await FirebaseFirestore.instance
        .collection("ChatRooms")
        .doc(chatRoomID)
        .set(chatRoomMap);
  }

  updateUserPhoneNo(String newPhoneNumber) async {
    String uid = await Helper.getUserID();
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection("Users").doc(uid).get();
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

  Future<void> sendImageMessage(
      String chatRoomID, Map<String, dynamic> messageMap) async {
    return await FirebaseFirestore.instance
        .collection("ChatRooms")
        .doc(chatRoomID)
        .collection("Messages")
        .doc()
        .set(messageMap);
  }

  Future<void> sendTextMessage(
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
