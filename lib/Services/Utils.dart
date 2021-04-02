import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Utils {
  Future<Map<String, dynamic>> mapForAuth(
      String username,
      String fullName,
      String email,
      String photoURL,
      String phoneNo,
      List<String> searchKeywords) async{
    List<String> token = [await FirebaseMessaging.instance.getToken()];         
    return {
      "UserName": username,
      "FullName": fullName,
      "Email": email,
      "PhotoURL": photoURL,
      "PhoneNo": phoneNo,
      "SearchKeywords": searchKeywords,
      "Password": '',
      "Bio": '',
      "MessagingTokens":token,
    };
  }

  String capitalizeFirstLetter(String word) {
    return word.replaceFirst(
        word.substring(0, 1), word.substring(0, 1).toUpperCase());
  }

  String extractFirstWord(String string) {
    return string.toLowerCase().trim().substring(0, string.indexOf(" "));
  }

  List<String> generateKeywordList(String string) {
    List<String> keywordsList = [];
    for (int i = 0; i < string.length; i++) {
      keywordsList.add(string.substring(0, i + 1));
      keywordsList.add(string.toLowerCase().substring(0, i + 1));
      keywordsList.add(string.toUpperCase().substring(0, i + 1));
    }
    return keywordsList;
  }

  String getChatRoomID(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b&$a";
    } else {
      return "$a&$b";
    }
  }

  Map<String, dynamic> mapForChatRoom(List<String> users, Timestamp timestamp) {
    return {
      "Users": users,
      "LastMessageTime": timestamp,
      "Password": '',
    };
  }
}
