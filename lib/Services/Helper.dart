import 'package:shared_preferences/shared_preferences.dart';

class Helper {
  static String userLoggedInKeySP = "ISLOGGEDIN";
  static String userNameKeySP = "USERNAMEKEY";
  static String userEmailKeySP = "USEREMAILKEY";
  static String userIDKeySP = "USERIDKEYSP";

  static Future<void> saveUserLoggedInSP(bool isUserLoggedIn) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setBool(userLoggedInKeySP, isUserLoggedIn);
  }

  static Future<void> saveUserID(String userID) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setString(userIDKeySP, userID);
  }

  static Future<void> saveUserNameSP(String userName) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setString(userNameKeySP, userName);
  }

  static Future<void> saveUserEmailSP(String userEmail) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setString(userEmailKeySP, userEmail);
  }

  //Getters

  static Future<bool> getUserLoggedInSP() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.getBool(userLoggedInKeySP);
  }

  static Future<String> getUserNameSP() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.getString(userNameKeySP);
  }

  static Future<String> getUserEmailSP() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.getString(userEmailKeySP);
  }

  static Future<String> getUserID() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.getString(userIDKeySP);
  }
}
