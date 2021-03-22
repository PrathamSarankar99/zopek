import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';
import 'package:zopek/Screens/HomeScreens/SearchScreen.dart';
import 'package:zopek/Services/Constants.dart';
import 'package:zopek/Services/Helper.dart';
import 'package:zopek/Services/Utils.dart';
import 'package:zopek/Services/database.dart';
import 'package:zopek/Screens/SettingScreens/Settings.dart' as settings;
import 'package:zopek/Widgets/StatusWidget.dart';
import 'package:zopek/Screens/ChatScreens/ChatsView.dart';
import 'package:zopek/Widgets/YourStory.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  DataBaseServices dataBaseServices = new DataBaseServices();
  Stream<QuerySnapshot> querySnapshotStream;
  Utils utils = new Utils();
  List<bool> isSelected = [];
  final double maxHeight = 0.82;
  final double minHeight = 0.63;

  @override
  void setState(fn) {
    // TODO: implement setState
    if (this.mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    populateSelection();
    deleteEmptyChatRooms();
    //If you don't wanna delete empty chat rooms delete this method, everthing is set for it.
    updateLastMessageTime();
    getUserDetails();
  }

  double _containerheight = 200;
  @override
  Widget build(BuildContext context) {
    print("Uid is : ${Constants.uid}");
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double opacity = 1 -
        (_containerheight - (height * minHeight)) /
            ((height * maxHeight) - (height * minHeight));
    return Scaffold(
      backgroundColor: Colors.black.withBlue(40),
      body: StreamBuilder<QuerySnapshot>(
          stream: dataBaseServices.getExistingChatRooms(Constants.uid),
          builder: (context, roomSnapshot) {
            return Stack(
              children: [
                Positioned(
                  top: 0,
                  child: Container(
                    height: height * 0.40,
                    width: width,
                    color: Colors.black.withBlue(40),
                    child: Column(
                      children: [
                        SafeArea(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 50, 0, 0),
                                child: Text(
                                  "Messages",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Spacer(),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 40, 20, 0),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SearchScreen()));
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Color(0xff444446),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.search,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    GestureDetector(
                                      onTap: () async {},
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Color(0xff444446),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: GestureDetector(
                                          onTap: () async {
                                            // QuerySnapshot snapshot =
                                            //     await FirebaseFirestore.instance
                                            //         .collection("Users")
                                            //         .get();
                                            // snapshot.docs
                                            //     .forEach((element) async {
                                            //   element.reference
                                            //       .update({"PhoneNo": ""});
                                            // });
                                            await GoogleSignIn().signOut();
                                            Navigator.push(
                                                context,
                                                PageTransition(
                                                    duration: Duration(
                                                        milliseconds: 100),
                                                    alignment:
                                                        Alignment.topRight,
                                                    child:
                                                        settings.SettingsPage(),
                                                    type: PageTransitionType
                                                        .fade));
                                          },
                                          child: Icon(
                                            Icons.settings,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedOpacity(
                          opacity:
                              (opacity == null || opacity > 1 || opacity < 0)
                                  ? 1
                                  : opacity,
                          duration: Duration(microseconds: 0),
                          child: Row(
                            children: [
                              Expanded(child: Container(child: YourStory())),
                              Container(
                                height: height * (maxHeight - minHeight),
                                width: MediaQuery.of(context).size.width - 100,
                                child: roomSnapshot.hasData
                                    ? ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            roomSnapshot.data.docs.length,
                                        itemBuilder: (context, index) {
                                          String uid = roomSnapshot
                                                      .data.docs[index]
                                                      .get("Users")[0] ==
                                                  Constants.uid
                                              ? roomSnapshot.data.docs[index]
                                                  .get("Users")[1]
                                              : roomSnapshot.data.docs[index]
                                                  .get("Users")[0];

                                          return StreamBuilder(
                                              stream: dataBaseServices
                                                  .getUserByID(uid),
                                              builder: (context, userSnapshot) {
                                                if (!roomSnapshot.hasData ||
                                                    !userSnapshot.hasData) {
                                                  return Container();
                                                }
                                                String username = userSnapshot
                                                            .data
                                                            .get("UserName")
                                                            .toString()
                                                            .length >
                                                        15
                                                    ? '${userSnapshot.data.get("UserName").toString().substring(0, 15)}...'
                                                    : userSnapshot.data
                                                        .get("UserName")
                                                        .toString();
                                                return StatusWidget(
                                                    username: username,
                                                    photoURL: userSnapshot.data
                                                        .get("PhotoURL"),
                                                    color: Colors.blue);
                                              });
                                        })
                                    : Container(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: GestureDetector(
                    onVerticalDragEnd: (details) {
                      setState(() {
                        print(details.primaryVelocity);
                        if (details.primaryVelocity < -1000) {
                          _containerheight = height * maxHeight;
                        } else if (details.primaryVelocity > 1000) {
                          _containerheight = height * minHeight;
                        }
                        if ((_containerheight / height) >
                            ((minHeight + maxHeight) / 2)) {
                          _containerheight = height * maxHeight;
                        }
                        if ((_containerheight / height) <
                            ((minHeight + maxHeight) / 2)) {
                          _containerheight = height * minHeight;
                        }
                      });
                    },
                    onVerticalDragUpdate: (dragUpdateDetails) {
                      setState(() {
                        _containerheight -= dragUpdateDetails.delta.dy * 1;
                        if (_containerheight > height * maxHeight) {
                          _containerheight = height * maxHeight;
                        } else if (_containerheight < height * minHeight) {
                          _containerheight = height * minHeight;
                        }
                      });
                    },
                    child: AnimatedContainer(
                      constraints: BoxConstraints(
                        minHeight: height * minHeight,
                        maxHeight: height * maxHeight,
                      ),
                      duration: Duration(microseconds: 100),
                      height: _containerheight,
                      width: width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 70,
                            child: Stack(
                              children: [
                                Container(
                                  height: 70,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.transparent,
                                ),
                                Container(
                                  height: 70,
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        topRight: Radius.circular(30)),
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Recent',
                                          style: TextStyle(
                                            fontSize: 20,
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            fontWeight: FontWeight.w500,
                                            //rgb(203,201,201)
                                          ),
                                        ),
                                        Spacer(),
                                        Visibility(
                                          visible: getSelectedno() > 0 &&
                                              roomSnapshot.data.docs.isNotEmpty,
                                          child: Row(
                                            children: [
                                              Text(
                                                getSelectedno().toString(),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontFamily: "NotoSerif",
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      bool isChecked = false;
                                                      return StatefulBuilder(
                                                        builder: (context,
                                                            setState) {
                                                          return AlertDialog(
                                                            title: Text("Delete" +
                                                                (getSelectedno() ==
                                                                        1
                                                                    ? " the"
                                                                    : " ${getSelectedno()}") +
                                                                " selected" +
                                                                (getSelectedno() ==
                                                                        1
                                                                    ? " chat?"
                                                                    : " chats?")),
                                                            content: Row(
                                                              children: [
                                                                Checkbox(
                                                                    value:
                                                                        isChecked,
                                                                    onChanged:
                                                                        (bool
                                                                            val) {
                                                                      setState(
                                                                          () {
                                                                        isChecked =
                                                                            val;
                                                                      });
                                                                    }),
                                                                Container(
                                                                  child: Text(
                                                                    "Delete media in " +
                                                                        (getSelectedno() ==
                                                                                1
                                                                            ? "this"
                                                                            : "these") +
                                                                        (getSelectedno() ==
                                                                                1
                                                                            ? " chat"
                                                                            : " chats"),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14.0),
                                                                    maxLines: 3,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            actions: <Widget>[
                                                              FlatButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        context),
                                                                child: Text(
                                                                  "Cancel",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .cyan,
                                                                  ),
                                                                ),
                                                              ),
                                                              FlatButton(
                                                                onPressed:
                                                                    () async {
                                                                  Navigator.pop(
                                                                      context);
                                                                  print(isSelected
                                                                      .toString());
                                                                  setState(() {
                                                                    for (int i =
                                                                            0;
                                                                        i < isSelected.length;
                                                                        i++) {
                                                                      if (isSelected[
                                                                          i]) {
                                                                        roomSnapshot
                                                                            .data
                                                                            .docs[i]
                                                                            .reference
                                                                            .delete();
                                                                        if (isChecked) {
                                                                          roomSnapshot
                                                                              .data
                                                                              .docs[i]
                                                                              .reference
                                                                              .collection("Messages")
                                                                              .get()
                                                                              .then((tmpquerysnapshot) {
                                                                            tmpquerysnapshot.docs.forEach((tmpdocumentsnapshot) {
                                                                              tmpdocumentsnapshot.reference.delete();
                                                                            });
                                                                          });
                                                                        }
                                                                      }
                                                                    }
                                                                    isSelected.removeWhere(
                                                                        (element) =>
                                                                            element);
                                                                  });
                                                                  print(isSelected
                                                                      .toString());
                                                                },
                                                                child: Text(
                                                                  "Delete",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .red
                                                                        .shade800,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.red.shade900,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    for (int i = 0;
                                                        i < isSelected.length;
                                                        i++) {
                                                      isSelected[i] = false;
                                                    }
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.cancel_sharp,
                                                  color: Colors.green.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Visibility(
                                          visible: roomSnapshot.hasData
                                              ? roomSnapshot
                                                  .data.docs.isNotEmpty
                                              : true,
                                          child: PopupMenuButton(
                                            onSelected: (code) {
                                              setState(() {
                                                if (code == 'select_all') {
                                                  for (int i = 0;
                                                      i < isSelected.length;
                                                      i++) {
                                                    isSelected[i] = true;
                                                  }
                                                }
                                                if (code == "deselect_all") {
                                                  for (int i = 0;
                                                      i < isSelected.length;
                                                      i++) {
                                                    isSelected[i] = false;
                                                  }
                                                }
                                              });
                                            },
                                            child: Icon(
                                              Icons.more_vert,
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                            ),
                                            itemBuilder: (context) {
                                              if (getSelectedno() == 0) {
                                                return [
                                                  PopupMenuItem(
                                                    height: 30,
                                                    textStyle: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                    ),
                                                    child: getSelectedno() ==
                                                            isSelected.length
                                                        ? Text("Deselect All")
                                                        : Text("Select All"),
                                                    value: getSelectedno() ==
                                                            isSelected.length
                                                        ? "deselect_all"
                                                        : "select_all",
                                                  )
                                                ];
                                              }
                                              return [
                                                PopupMenuItem(
                                                  height: 30,
                                                  textStyle: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                  ),
                                                  child: getSelectedno() ==
                                                          isSelected.length
                                                      ? Text("Deselect All")
                                                      : Text("Select All"),
                                                  value: getSelectedno() ==
                                                          isSelected.length
                                                      ? "deselect_all"
                                                      : "select_all",
                                                )
                                              ];
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: roomSnapshot.hasData
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    physics: ScrollPhysics(),
                                    padding: EdgeInsets.only(bottom: 10),
                                    itemCount: roomSnapshot.data.docs.length,
                                    itemBuilder: (context, index) {
                                      String uid = roomSnapshot.data.docs[index]
                                                  .get("Users")[0] ==
                                              Constants.uid
                                          ? roomSnapshot.data.docs[index]
                                              .get("Users")[1]
                                          : roomSnapshot.data.docs[index]
                                              .get("Users")[0];
                                      return StreamBuilder<DocumentSnapshot>(
                                          stream:
                                              dataBaseServices.getUserByID(uid),
                                          builder: (context, userSnapshot) {
                                            if (!userSnapshot.hasData) {
                                              return Container(
                                                height: 80,
                                                alignment: Alignment.center,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  30),
                                                          topRight:
                                                              Radius.circular(
                                                                  30)),
                                                ),
                                              );
                                            }

                                            return StreamBuilder<QuerySnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection("ChatRooms")
                                                  .doc(utils.getChatRoomID(
                                                      Constants.uid, uid))
                                                  .collection("Messages")
                                                  .orderBy("Time",
                                                      descending: true)
                                                  .limit(1)
                                                  .snapshots(),
                                              builder: (context,
                                                  lastMessageSnapshot) {
                                                return userMessageListTile(
                                                    false,
                                                    context,
                                                    userSnapshot,
                                                    index,
                                                    lastMessageSnapshot);
                                              },
                                            );
                                          });
                                    })
                                : Container(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }

  deleteEmptyChatRooms() async {
    String uid = await Helper.getUserID();
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("ChatRooms")
        .where("Users", arrayContains: uid)
        .get();
    snapshot.docs.forEach((element) async {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("ChatRooms")
          .doc(element.id)
          .collection("Messages")
          .get();
      if (snapshot.docs.isEmpty) {
        FirebaseFirestore.instance
            .collection("ChatRooms")
            .doc(element.id)
            .delete()
            .then((value) {});
      }
    });
  }

  void updateLastMessageTime() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("ChatRooms").get();
    snapshot.docs.forEach((element) async {
      QuerySnapshot lastmessagesnapshot = await FirebaseFirestore.instance
          .collection("ChatRooms")
          .doc(element.id)
          .collection("Messages")
          .orderBy("Time", descending: true)
          .limit(1)
          .get();
      if (lastmessagesnapshot.docs.isNotEmpty) {
        element.reference.update({
          "LastMessageTime": lastmessagesnapshot.docs[0].get("Time"),
        });
      }
    });
  }

  void populateSelection() async {
    String uid = await Helper.getUserID();
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("ChatRooms")
        .where("Users", arrayContains: uid)
        .get();
    int length = snapshot.docs.length;
    setState(() {
      isSelected = List.generate(length, (index) => false, growable: true);
    });
    print(isSelected.toString());
  }

  Widget userMessageListTile(
      bool isSelected,
      BuildContext context,
      AsyncSnapshot userSnapshot,
      int index,
      AsyncSnapshot lastMessageSnapshot) {
    if (this.isSelected.isEmpty || this.isSelected.length <= index) {
      return Container();
    }
    return Column(
      children: [
        ListTile(
            selectedTileColor: Colors.cyan.withOpacity(0.2),
            selected: this.isSelected.isEmpty || this.isSelected.length <= index
                ? false
                : this.isSelected[index],
            onLongPress: () {
              setState(() {
                if (this.isSelected.contains(false)) {
                  this.isSelected[index] = !this.isSelected[index];
                }
              });
            },
            onTap: () {
              setState(() {
                if (this.isSelected.contains(true)) {
                  this.isSelected[index] = !this.isSelected[index];
                  return;
                }
                Navigator.pushReplacement(
                    context,
                    PageTransition(
                        child: Chats(
                          incognito: false,
                          chatRoomID: utils.getChatRoomID(
                              Constants.uid, userSnapshot.data.id),
                          uid: userSnapshot.data.id,
                        ),
                        type: PageTransitionType.fade,
                        duration: Duration(milliseconds: 300)));
              });
            },
            title: Row(
              children: [
                Text(
                  userSnapshot.data.get('UserName'),
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            leading: this.isSelected[index]
                ? Stack(
                    alignment: Alignment.bottomRight,
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        child: CircleAvatar(
                          backgroundImage:
                              NetworkImage(userSnapshot.data.get("PhotoURL")),
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        child: Image.asset("assets/tick.png"),
                      ),
                    ],
                  )
                : Container(
                    width: 50,
                    height: 50,
                    child: CircleAvatar(
                      backgroundImage:
                          NetworkImage(userSnapshot.data.get("PhotoURL")),
                    ),
                  ),
            subtitle: (!lastMessageSnapshot.hasData ||
                    lastMessageSnapshot.data.docs.isEmpty)
                ? Container()
                : Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: lastMessageSnapshot.data.docs[0].get("Message") == ""
                        ? (lastMessageSnapshot.data.docs[0].get("ImageURL") ==
                                null
                            ? Row()
                            : Row(
                                children: [
                                  Icon(
                                    Icons.photo,
                                    size: 15,
                                    color: Colors.black.withBlue(40),
                                  ),
                                  Text("Photo"),
                                ],
                              ))
                        : Text(
                            lastMessageSnapshot.data.docs[0].get("Message"),
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                  )),
        SizedBox(
          height: 0.5,
        ),
      ],
    );
  }

  int getSelectedno() {
    return isSelected.where((element) => element).length;
  }

  getUserDetails() async {
    Stream<DocumentSnapshot> snap;
    String uid = await Helper.getUserID();
    snap = dataBaseServices.getUserByID(uid);
    snap.forEach((element) async {
      Constants.userName = element.get("UserName");
      Constants.fullName = element.get("FullName");
      Constants.email = element.get("Email");
      Constants.photoURL = element.get("PhotoURL");
      Constants.phoneNo = element.get("PhoneNo");
      Constants.uid = element.id;
      Constants.bio = element.get('Bio');
    });
  }
}
