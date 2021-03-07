import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zopek/Services/Helper.dart';

class Utils {
  Map<String, dynamic> mapForAuth(
      String username,
      String fullName,
      String email,
      String photoURL,
      String phoneNo,
      List<String> searchKeywords) {
    return {
      "UserName": username,
      "FullName": fullName,
      "Email": email,
      "PhotoURL": photoURL,
      "PhoneNo": phoneNo,
      "SearchKeywords": searchKeywords,
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

  Future<void> saveSharedPreferencesDetails(
      String uid, String username, String email) async {
    await Helper.saveUserID(uid);
    await Helper.saveUserNameSP(username)
        .then((value) => print("Your username saved successfully"));
    await Helper.saveUserEmailSP(email)
        .then((value) => print("Your email saved successfully"));
    await Helper.saveUserLoggedInSP(true)
        .then((value) => print("Your loggedIn status is true now."));
  }

  Future<void> saveSharedPreferencesLoggedStatus(bool isLoggedin) async {
    await Helper.saveUserLoggedInSP(isLoggedin)
        .then((value) => print("Your loggedIn status is true now."));
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
    };
  }
}
