import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path/path.dart';
import 'package:zopek/Modals/Camera.dart';
import 'package:zopek/Modals/Constants.dart';
import 'package:zopek/Modals/ImageSource.dart';
import 'package:zopek/Screens/ChatScreens/Capture.dart';
import 'package:zopek/Services/auth.dart';
import 'package:zopek/Services/database.dart';
import 'package:zopek/Screens/AuthScreens/Signin.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  DataBaseServices dataBaseServices = new DataBaseServices();
  double progress = 0;
  @override
  Widget build(BuildContext context) {
    print('Constants : ${Constants.status}');
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          backgroundColor: Colors.black.withBlue(40),
          title: Text("Settings"),
          actions: [
            PopupMenuButton(
              onSelected: (value) async {
                if (value == 'logout') {
                  await AuthServices().signOut();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.of(context).pushReplacement(PageTransition(
                      child: SignIn(), type: PageTransitionType.fade));
                }
              },
              child: Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(Icons.more_vert),
              ),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    height: 20,
                    value: 'logout',
                    child: Text(
                      'Logout',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
        body: ListView(
          children: [
            Container(
                height: height * 0.13,
                width: width,
                color: Colors.black.withBlue(40),
                child: Row(
                  children: [
                    SizedBox(
                      width: width * 0.05,
                    ),
                    CircleAvatar(
                      radius: width * 0.09,
                      backgroundImage: NetworkImage(Constants.photoURL),
                      child: Container(
                        width: width * 0.18,
                        height: width * 0.18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: CircularProgressIndicator(
                          value: (progress > 0 && progress < 1) ? progress : 0,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            Constants.fullName,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            "Online",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.w300,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    )
                  ],
                )),
            TextButton(
                style: ButtonStyle(
                    minimumSize:
                        MaterialStateProperty.all(Size(width, height * 0.07))),
                onPressed: () async {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                            height: height * 0.15,
                            width: width,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: height * 0.15,
                                  width: width / 2,
                                  child: new Material(
                                    child: new InkWell(
                                      onTap: () {
                                        updateprofilepicture(
                                            ImageSource.camera, context);
                                      },
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: height * 0.015,
                                          ),
                                          Container(
                                              height: height * 0.08,
                                              width: width * 0.25,
                                              child: Image.asset(
                                                  'assets/camera.png')),
                                          Text('Camera',
                                              style: TextStyle(
                                                color: Colors.purple,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 20,
                                              )),
                                        ],
                                      ),
                                    ),
                                    color: Colors.transparent,
                                  ),
                                ),
                                Container(
                                  height: height * 0.15,
                                  width: width / 2,
                                  child: new Material(
                                    child: new InkWell(
                                      onTap: () {
                                        updateprofilepicture(
                                            ImageSource.gallery, context);
                                      },
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: height * 0.015,
                                          ),
                                          Container(
                                              height: height * 0.08,
                                              width: width * 0.25,
                                              child: Image.asset(
                                                  'assets/gallery.png')),
                                          Text('Gallery',
                                              style: TextStyle(
                                                color: Colors.orange,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 20,
                                              )),
                                        ],
                                      ),
                                    ),
                                    color: Colors.transparent,
                                  ),
                                ),
                              ],
                            ));
                      });
                },
                child: Row(
                  children: [
                    Icon(Icons.add_a_photo_outlined),
                    SizedBox(
                      width: width * 0.05,
                    ),
                    Text("Set Profile Picture"),
                  ],
                )),
            Divider(
              height: 2,
              thickness: 2,
              color: Colors.blue.withOpacity(0.5),
            ),
            ListTile(
              leading: Container(
                child: Icon(Icons.person),
              ),
              onTap: () {
                updateUsername(context);
              },
              title: Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  Constants.userName,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              subtitle: Text(
                "Username, tap to change",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: Colors.grey,
                ),
              ),
            ),
            ListTile(
              leading: Container(
                child: Icon(Icons.info_outline),
              ),
              onTap: () {
                updateBio(context);
              },
              title: Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Constants.status.length > 1
                    ? Text(Constants.status)
                    : Text(
                        Constants.status == '' ? "Status" : Constants.status,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
              ),
              subtitle: Text(
                Constants.status == ''
                    ? "Add a few words about yourself."
                    : "Tap to change",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ));
  }

  updateUsername(BuildContext context) {
    TextEditingController tdc = new TextEditingController()
      ..text = Constants.userName;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: TextField(
              controller: tdc,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            actions: [
              TextButton.icon(
                  onPressed: () async {
                    dataBaseServices.updateUsername(tdc.text.trim());
                    Navigator.pop(context);
                    setState(() {
                      Constants.userName = tdc.text.trim();
                    });
                  },
                  icon: Icon(Icons.check),
                  label: Text("Okay")),
              TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.cancel),
                  label: Text("Cancel"))
            ],
          );
        });
  }

  updateBio(BuildContext context) {
    TextEditingController tdc = new TextEditingController()
      ..text = Constants.status;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: TextField(
              maxLines: 5,
              minLines: 1,
              controller: tdc,
              decoration: InputDecoration(labelText: 'Add/Update your bio'),
            ),
            actions: [
              TextButton.icon(
                  onPressed: () async {
                    dataBaseServices.updateBio(tdc.text.trim());
                    Navigator.pop(context);
                    setState(() {
                      Constants.status = tdc.text.trim();
                    });
                  },
                  icon: Icon(Icons.check),
                  label: Text("Okay")),
              TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.cancel),
                  label: Text("Cancel"))
            ],
          );
        });
  }

  updateprofilepicture(ImageSource imageSource, BuildContext context) async {
    String path;
    if (imageSource == ImageSource.camera) {
      path = await Navigator.push(
          context,
          PageTransition(
              child: Capture(
                  cameraDescriptions:
                      CameraConfigurations.cameraDescriptionList),
              type: PageTransitionType.fade));
    } else {
      List<Asset> imageFile =
          await MultiImagePicker.pickImages(maxImages: 1, enableCamera: true);
      path = await FlutterAbsolutePath.getAbsolutePath(imageFile[0].identifier);
    }
    if (path == null) {
      print('No image selected');
      return;
    }
    Navigator.pop(context);
    Reference reference = FirebaseStorage.instance
        .ref()
        .child("${Constants.uid}/profilepicture/${basename(path)}");
    UploadTask uploadTask = reference.putFile(File(path));
    uploadTask.snapshotEvents.listen((event) {
      setState(() {
        progress = (event.bytesTransferred / event.totalBytes);
      });
    });
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() async {
      String downloadURL = await reference.getDownloadURL();
      dataBaseServices.updateProfilePicture(downloadURL);
      setState(() {
        Constants.photoURL = downloadURL;
      });
    });
  }
}
