import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:international_phone_field/international_phone_field.dart';
import 'package:zopek/Services/database.dart';

class ChangePhoneNo extends StatefulWidget {
  @override
  _ChangePhoneNoState createState() => _ChangePhoneNoState();
}

class _ChangePhoneNoState extends State<ChangePhoneNo> {
  String phoneNumber;
  String phoneIsoCode;
  String selectedCountryCapital;
  String selectedCountryContinent;
  String selectedCountryCurrency;
  String selectedCountryName;
  String confirmedNumber;
  bool visible = false;
  bool isSMSsent = false;
  String _smsVerificationCode;
  AuthCredential credential;
  TextEditingController controller = new TextEditingController();
  DataBaseServices dataBaseServices = new DataBaseServices();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection("Users");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Phone Number"),
        brightness: Brightness.dark,
        backgroundColor: Colors.black.withBlue(40),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 5),
            child: IconButton(
              icon: Icon(Icons.check),
              onPressed: () async {
                String currentUserEmail = firebaseAuth.currentUser.email;
                if (confirmedNumber != null || confirmedNumber == '') {
                  print('We have a confirmed phone number : $confirmedNumber');
                  QuerySnapshot querySnapshot = await collectionReference
                      .where('Email', isEqualTo: currentUserEmail)
                      .limit(1)
                      .get();
                  print(querySnapshot.docs[0].id);
                  firebaseAuth.verifyPhoneNumber(
                      phoneNumber: confirmedNumber,
                      verificationCompleted: (authCredential) =>
                          _verificationComplete(authCredential, context),
                      verificationFailed: (authException) =>
                          _verificationFailed(authException, context),
                      codeSent: (verificationId, [code]) =>
                          _smsCodeSent(verificationId, [code]),
                      codeAutoRetrievalTimeout: (verificationId) =>
                          _codeAutoRetrievalTimeout(verificationId));
                  querySnapshot.docs[0].reference.update({});
                }
              },
            ),
          )
        ],
      ),
      //
      body: isSMSsent
          ? Padding(
              padding: EdgeInsets.only(top: 20.0, right: 5, left: 5),
              child: Column(
                children: [
                  Text(
                    'Code sent to - $confirmedNumber',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter the Code',
                      ),
                    ),
                  ),
                  FlatButton(
                    minWidth: 300,
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                    onPressed: () async {
                      final code = controller.text.trim();
                      try {
                        final AuthCredential credential =
                            PhoneAuthProvider.credential(
                          verificationId: _smsVerificationCode,
                          smsCode: code,
                        );
                      } catch (e) {
                        print("There was an errr - $e");
                      }
                    },
                    child: Text('Continue'),
                  )
                ],
              ))
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 15.0, right: 5, left: 5),
                  child: InterField(
                      onPhoneNumberChange: onPhoneNumberChange,
                      initialPhoneNumber: phoneNumber,
                      initialSelection: '+91',
                      labelText: "Enter your phone Number",
                      addCountryComponentInsideField: false,
                      border: UnderlineInputBorder()),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, right: 5, left: 5),
                  child: Text(
                    "Hereby, you agree to change your phone number in the database. If you do your chatRoom partners will see it and may use it to call you or further share it with anyone else.",
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.7), fontSize: 15),
                  ),
                ),
              ],
            ),
    );
  }

  _verificationComplete(AuthCredential authCredential, BuildContext context) {
    // Navigator.pop(context);
  }

  _smsCodeSent(String verificationId, List<int> code) {
    // set the verification code so that we can use it to log the user in
    print('The sms code $verificationId');
    setState(() {
      isSMSsent = true;
      _smsVerificationCode = verificationId;
    });
  }

  _verificationFailed(FirebaseException authException, BuildContext context) {
    print('Verfication failed.');
  }

  _codeAutoRetrievalTimeout(String verificationId) {
    // set the verification code so that we can use it to log the user in
    _smsVerificationCode = verificationId;
  }

  void onPhoneNumberChange(
      String number,
      String internationalizedPhoneNumber,
      String isoCode,
      String dialCode,
      String countryCapital,
      String countryContinent,
      String countryCurrency,
      String countryName) {
    print('It is no: $internationalizedPhoneNumber');
    setState(() {
      phoneNumber = number;
      phoneIsoCode = isoCode;
      selectedCountryCapital = countryCapital;
      selectedCountryContinent = countryContinent;
      selectedCountryCurrency = countryCurrency;
      selectedCountryName = countryName;
      visible = true;
      confirmedNumber = internationalizedPhoneNumber;
    });
  }
}
