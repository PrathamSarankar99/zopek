import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zopek/Services/database.dart';
import 'package:zopek/Services/Utils.dart';

class AuthServices {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  GoogleSignIn googleSignIn = new GoogleSignIn();
  Utils utils = new Utils();

  String photoURL =
      "https://firebasestorage.googleapis.com/v0/b/zopek-de839.appspot.com/o/default-user.png?alt=media&token=4deff2a2-3dd1-45f0-833d-b4c1ef3dfe22";

  Future signInWithEmailandPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      User user = userCredential.user;
      String username =
          utils.capitalizeFirstLetter(utils.extractFirstWord(user.displayName));
      List<String> searchKeywords = utils.generateKeywordList(username);
      photoURL = user.photoURL != null ? user.photoURL : photoURL;
      Map<String, dynamic> map = await utils.mapForAuth(
          username,
          user.displayName,
          user.email,
          photoURL,
          (user.phoneNumber == null ? "" : user.phoneNumber),
          searchKeywords);
      String token = await FirebaseMessaging.instance.getToken();
      DataBaseServices.addMessagingTokens(token, user.uid);
      if (userCredential.additionalUserInfo.isNewUser) {
        DataBaseServices.uploadUserInfo(map, user.uid);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "The user doesn't exist.";
      }
      if (e.code == 'wrong-password') {
        return "You have entered a wrong password.";
      } else {
        return e.code;
      }
    }
  }

  Stream<User> get loggedInStream => _firebaseAuth.authStateChanges();

  Future signUpWithEmailandPassword(
      String username, String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      User user = userCredential.user;

      List<String> searchKeywords = utils.generateKeywordList(username);
      Map<String, dynamic> map = await utils.mapForAuth(
          username, username, email, photoURL, "", searchKeywords);
      DataBaseServices.uploadUserInfo(map, user.uid);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return "The user doesn't exist.";
      } else {
        return e.code;
      }
    }
  }

  Future resetPassword(String email) async {
    return await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future signOut() async {
    String currentMessagingToken = await FirebaseMessaging.instance.getToken();
    User currentUser = _firebaseAuth.currentUser;
    DataBaseServices.removeMessagingTokens(
        currentMessagingToken, currentUser.uid);
    await googleSignIn.signOut();
    await _firebaseAuth.signOut();
    return;
  }

  Future<void> signInWithGoogle() async {
    print('Google signin starts');
    GoogleSignInAccount account = await googleSignIn.signIn();
    GoogleSignInAuthentication authentication = await account.authentication;
    OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: authentication.accessToken,
      idToken: authentication.idToken,
    );
    UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    User user = userCredential.user;
    String username =
        utils.capitalizeFirstLetter(utils.extractFirstWord(user.displayName));
    List<String> searchKeywords = utils.generateKeywordList(username);
    photoURL = user.photoURL != null ? user.photoURL : photoURL;
    Map<String, dynamic> map = await utils.mapForAuth(
        username,
        user.displayName,
        user.email,
        photoURL,
        (user.phoneNumber == null ? "" : user.phoneNumber),
        searchKeywords);
    String token = await FirebaseMessaging.instance.getToken();
    DataBaseServices.addMessagingTokens(token, user.uid);
    if (userCredential.additionalUserInfo.isNewUser) {
      DataBaseServices.uploadUserInfo(map, user.uid);
    }
  }
}
