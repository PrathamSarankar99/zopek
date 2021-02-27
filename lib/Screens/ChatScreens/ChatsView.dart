import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:linkable/linkable.dart';
import 'package:page_transition/page_transition.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:photo_view/photo_view.dart';
import 'package:path/path.dart' as Path;
import 'package:swipe_to/swipe_to.dart';
import 'package:zopek/Screens/HomeScreens/Homepage.dart';
import 'package:zopek/Services/Constants.dart';
import 'package:zopek/Services/database.dart';
import 'dart:math' as math;
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:zopek/Widgets/ChatScreenWidgets/ImageMessage.dart';

class Chats extends StatefulWidget {
  final String chatRoomID;
  final String uid;

  const Chats({Key key, this.chatRoomID, this.uid}) : super(key: key);
  @override
  _ChatsState createState() => _ChatsState();
}

class Message {
  static String message = "";
}

class _ChatsState extends State<Chats> {
  PickedFile imagefile;
  TextEditingController messageController = new TextEditingController();
  FocusNode messageFocusNode;
  List<bool> isSelected = [];
  String photoURL = "";
  String username = "";
  String email = "";
  DataBaseServices dbs = new DataBaseServices();
  AutoScrollController _autoScrollController = new AutoScrollController();
  QueryDocumentSnapshot _queryDocumentSnapshot;
  @override
  void initState() {
    super.initState();
    populateSelection().then((value) {
      setState(() {
        //print("$value has been returned");
      });
    });
    messageFocusNode = FocusNode();
    getUserInfo();
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
    messageFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Chat page is building");

    return Scaffold(
      backgroundColor: Colors.black.withBlue(40),
      body: WillPopScope(
        onWillPop: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Homepage()));
          return;
        },
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.15,
              width: MediaQuery.of(context).size.width,
              color: Colors.black.withBlue(40),
              child: StreamBuilder<QuerySnapshot>(
                  stream: dbs.getChatRoomStreamOfMessagesExHidden(
                      widget.chatRoomID, Constants.userName),
                  builder: (context, chatRoomSnapshot) {
                    return SafeArea(
                        child: isSelected.contains(true)
                            ? toolingHeader(chatRoomSnapshot)
                            : profileHeader(chatRoomSnapshot));
                  }),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    )),
                width: MediaQuery.of(context).size.width,
                child: StreamBuilder<QuerySnapshot>(
                    stream: dbs.getChatRoomStreamOfMessagesExHidden(
                        widget.chatRoomID, Constants.userName),
                    builder: (context, chatRoomSnapshot) {
                      if (!chatRoomSnapshot.hasData) {
                        return Container();
                      }

                      return ListView.builder(
                          shrinkWrap: true,
                          reverse: true,
                          controller: _autoScrollController,
                          physics: ClampingScrollPhysics(),
                          padding: EdgeInsets.only(top: 5, bottom: 0),
                          itemCount: chatRoomSnapshot.data.docs.length,
                          itemBuilder: (context, index) {
                            if (isSelected.isEmpty ||
                                isSelected.length <= index) {}
                            print("Getting message $index");
                            return messageTile(index, chatRoomSnapshot);
                          });
                    }),
              ),
            ),
            Container(
              alignment: Alignment.bottomLeft,
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              child: Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(241, 245, 246, 1),
                  //rgb(241,245,246)
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                margin: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Visibility(
                      visible: _queryDocumentSnapshot != null,
                      child: _queryDocumentSnapshot == null
                          ? Container()
                          : Container(
                              height: 100,
                              width: MediaQuery.of(context).size.width - 16,
                              color: Colors.transparent,
                              child: Container(
                                padding: EdgeInsets.only(
                                  top: 10,
                                  left: 10,
                                ),
                                margin: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _queryDocumentSnapshot.get("Sender") ==
                                          Constants.userName
                                      ? Color.fromRGBO(23, 105, 164, 0.3)
                                      : Colors.amber.withOpacity(0.5),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _queryDocumentSnapshot
                                                      .get("Sender") ==
                                                  Constants.userName
                                              ? "You"
                                              : username,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 20,
                                              color: Colors.black
                                                  .withBlue(40)
                                                  .withOpacity(0.7)),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _queryDocumentSnapshot = null;
                                            });
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              right: 10,
                                            ),
                                            child: Icon(
                                              Icons.clear,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: 5,
                                        right: 10,
                                        left: 5,
                                      ),
                                      child: Divider(
                                        thickness: 1,
                                        height: 0.2,
                                      ),
                                    ),
                                    Container(
                                      height: 40,
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          left: 8,
                                          top: 5,
                                          right: 10,
                                        ),
                                        child: Container(
                                          child: _queryDocumentSnapshot
                                                      .get("Message") !=
                                                  ""
                                              ? Text(
                                                  _queryDocumentSnapshot
                                                      .get("Message"),
                                                  maxLines: 3,
                                                )
                                              : Row(
                                                  children: [
                                                    Icon(
                                                      Icons.photo,
                                                      color: Colors.black
                                                          .withBlue(40)
                                                          .withOpacity(0.7),
                                                    ),
                                                    Text(
                                                      "Photo",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w200,
                                                          fontSize: 17,
                                                          color: Colors.black
                                                              .withBlue(40)
                                                              .withOpacity(
                                                                  0.8)),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 16,
                      child: Stack(
                        children: [
                          Positioned(
                            left: -15,
                            bottom: 0,
                            child: FlatButton(
                                color: Colors.blue,
                                shape: CircleBorder(),
                                onPressed: () async {
                                  await sendImageMessage();
                                },
                                height: 45,
                                child: Icon(
                                  Icons.photo_camera,
                                  color: Colors.white,
                                )),
                          ),
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(bottom: 2),
                            margin: EdgeInsets.only(left: 55),
                            width: MediaQuery.of(context).size.width * 0.7 - 50,
                            child: TextField(
                              onChanged: (str) {
                                Message.message = str;
                                _autoScrollController.jumpTo(
                                    _autoScrollController
                                        .position.minScrollExtent);
                              },
                              autocorrect: true,
                              focusNode: messageFocusNode,
                              enableSuggestions: true,
                              minLines: 1,
                              maxLines: 5,
                              controller: messageController,
                              decoration: InputDecoration(
                                hintText: 'Type a message',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 30,
                            bottom: 0,
                            child: FlatButton(
                              shape: CircleBorder(),
                              onPressed: () {},
                              height: 50,
                              child: Transform.rotate(
                                angle: math.pi * 2 + 100,
                                child: Icon(Icons.attach_file),
                              ),
                            ),
                          ),
                          Positioned(
                            right: -15,
                            bottom: 0,
                            child: FlatButton(
                                height: 50,
                                shape: CircleBorder(),
                                onPressed: () {
                                  if (messageController.text != "") {
                                    messageController.clear();
                                    sendMessage(null);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Icons.send),
                                )),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  sendMessage(String imageURL) {
    setState(() {
      DataBaseServices dbs = new DataBaseServices();
      Map<String, dynamic> map;
      isSelected.add(false);
      List visible = [];
      List repliedTo = _queryDocumentSnapshot == null
          ? []
          : [
              _queryDocumentSnapshot.get("Sender"),
              _queryDocumentSnapshot.get("Message"),
            ];
      _queryDocumentSnapshot = null;
      FirebaseFirestore.instance
          .collection("ChatRooms")
          .doc(widget.chatRoomID)
          .get()
          .then((docSnapshot) async {
        visible = docSnapshot.get("Users");
        map = {
          "ImageURL": imageURL,
          "Time": DateTime.now(),
          "Sender": Constants.userName,
          "Message": Message.message.trim(),
          "Visible": visible,
          "RepliedTo": repliedTo,
        };
        await dbs.sendMessage(widget.chatRoomID, map);
        _autoScrollController.animateTo(
            _autoScrollController.position.minScrollExtent,
            duration: Duration(milliseconds: 150),
            curve: Curves.easeInOut);
        Message.message = "";
      });
    });
  }

  updatingMessageMap() async {
    QuerySnapshot chatRoomsnapshot =
        await FirebaseFirestore.instance.collection("ChatRooms").get();

    chatRoomsnapshot.docs.forEach((element) async {
      QuerySnapshot tmpSnapshot =
          await element.reference.collection("Messages").get();
      tmpSnapshot.docs.forEach((tmpelement) async {
        tmpelement.reference.update({
          "ImageURL": null,
        });
      });
    });
  }

  Future<int> populateSelection() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("ChatRooms")
        .doc(widget.chatRoomID)
        .collection("Messages")
        .where("Visible", arrayContains: Constants.userName)
        .get();
    int length = snapshot.docs.length;
    isSelected = List.generate(length, (index) => false, growable: true);
    return 0;
  }

  Future getUserInfo() async {
    Stream<DocumentSnapshot> snap = await dbs.getUserByID(widget.uid);
    await snap.first.then((value) {
      setState(() {
        photoURL = value.get("PhotoURL");
        username = value.get("UserName").toString().length > 15
            ? '${value.get("Name").toString().substring(0, 15)}...'
            : value.get("UserName").toString();

        email = value.get("Email");
      });
    });
  }

  Widget messageTile(int index, AsyncSnapshot<QuerySnapshot> chatRoomSnapshot) {
    if (!isSelected.contains(true)) {
      isSelected =
          List.generate(chatRoomSnapshot.data.docs.length, (index) => false);
    }
    String imageURL = chatRoomSnapshot.data.docs[index].get("ImageURL");
    bool byme =
        chatRoomSnapshot.data.docs[index].get("Sender") == Constants.userName;
    String message = chatRoomSnapshot.data.docs[index].get("Message");
    Timestamp timestamp = chatRoomSnapshot.data.docs[index].get("Time");
    List repliedTo = chatRoomSnapshot.data.docs[index].get("RepliedTo");
    String repliedToSender = repliedTo.length == 2 ? repliedTo[0] : "";
    String repliedToMessage = repliedTo.length == 2 ? repliedTo[1] : "";
    if (isSelected.isEmpty || isSelected.length <= index) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 200,
        color: Colors.pink,
      );
    }
    return AutoScrollTag(
      key: ValueKey(index),
      controller: _autoScrollController,
      index: index,
      child: GestureDetector(
        onDoubleTap: () {
          print("Double tapped on index $index");
        },
        onTap: () {
          setState(() {
            if (isSelected.contains(true)) {
              isSelected[index] = !isSelected[index];
              return;
            }
          });
        },
        onLongPress: () {
          setState(() {
            if (isSelected.contains(false)) {
              isSelected[index] = !isSelected[index];
            }
          });
        },
        child: SwipeTo(
          offsetDx: 0.2,
          onRightSwipe: () {
            setState(() {
              messageFocusNode.requestFocus();
              _queryDocumentSnapshot = chatRoomSnapshot.data.docs[index];
            });
          },
          child: imageURL != null
              ? ImageMessage(
                  byme: byme,
                  imageURL: imageURL,
                  isSelected: isSelected[index],
                  username: username,
                )
              : Container(
                  margin: EdgeInsets.only(bottom: 1),
                  decoration: BoxDecoration(
                    color: isSelected[index]
                        ? (!byme
                            ? Colors.amber.shade300.withOpacity(0.5)
                            : Color.fromRGBO(23, 105, 164, 0.5))
                        : Colors.transparent,
                    borderRadius: index == isSelected.length - 1
                        ? BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25),
                          )
                        : BorderRadius.zero,
                  ),
                  child: Container(
                      padding: EdgeInsets.only(top: 3, bottom: 3),
                      color: Colors.transparent,
                      margin: byme
                          ? EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.20,
                              right: 22,
                            )
                          : EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.20,
                              left: 22,
                            ),
                      alignment:
                          byme ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: byme
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Visibility(
                            visible: repliedToSender != "",
                            child: Container(
                              margin: EdgeInsets.only(top: 10),
                              color: Colors.transparent,
                              child: Text(repliedToSender == Constants.userName
                                  ? (byme
                                      ? "Replied to yourself"
                                      : "Replied to you")
                                  : (byme
                                      ? "You replied"
                                      : "Replied to themself")),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _scrollToIndex(repliedToMessage);
                            },
                            child: Visibility(
                              visible: repliedToMessage != "",
                              child: Container(
                                padding: byme
                                    ? EdgeInsets.only(right: 10)
                                    : EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                  border: byme
                                      ? Border(
                                          right: BorderSide(
                                          color: (repliedToSender !=
                                                  Constants.userName
                                              ? Colors.amber.shade300
                                                  .withOpacity(0.8)
                                              : Color.fromRGBO(
                                                  23, 105, 164, 0.8)),
                                          width: 2,
                                        ))
                                      : Border(
                                          left: BorderSide(
                                          color: (repliedToSender !=
                                                  Constants.userName
                                              ? Colors.amber.shade300
                                                  .withOpacity(0.8)
                                              : Color.fromRGBO(
                                                  23, 105, 164, 0.8)),
                                          width: 2,
                                        )),
                                  color: Colors.transparent,
                                ),
                                child: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: byme
                                          //rgb(255,72,56)
                                          ? (repliedToSender !=
                                                  Constants.userName
                                              ? Colors.amber.shade300
                                                  .withOpacity(0.8)
                                              : Color.fromRGBO(
                                                  23, 105, 164, 0.8))
                                          : (repliedToSender ==
                                                  Constants.userName
                                              ? Color.fromRGBO(
                                                  23, 105, 164, 0.8)
                                              : Colors.amber.shade300
                                                  .withOpacity(0.6)),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
                                    ),
                                    child: Text(
                                      repliedToMessage,
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.6),
                                      ),
                                    )),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: byme
                                    ? BorderRadius.only(
                                        topLeft: Radius.circular(25),
                                        topRight: Radius.circular(25),
                                        bottomLeft: Radius.circular(25),
                                      )
                                    : BorderRadius.only(
                                        topLeft: Radius.circular(25),
                                        topRight: Radius.circular(25),
                                        bottomRight: Radius.circular(25),
                                      ),
                                color: byme
                                    ? Color.fromRGBO(23, 105, 164, 1)
                                    : Colors.amber.shade300),

                            padding: EdgeInsets.only(
                                top: 15, left: 15, bottom: 5, right: 5),
                            //rgb(216,242,255)
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: byme
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: byme
                                      ? EdgeInsets.only(right: 10)
                                      : EdgeInsets.only(right: 10),
                                  child: Linkable(
                                    linkColor: Colors.white,
                                    textColor: Colors.black.withOpacity(0.8),
                                    text: message,
                                    style: TextStyle(
                                      fontSize: 18,
                                      decorationColor: Colors.blue,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  alignment: byme
                                      ? Alignment.bottomRight
                                      : Alignment.bottomLeft,
                                  height: 12,
                                  width: 40,
                                  color: Colors.transparent,
                                  child: Text(
                                    getTimeForMessageTile(timestamp),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      )),
                ),
        ),
      ),
    );
    //rgb(216,242,255)
  }

  Future sendImageMessage() async {
    ImagePicker imagePicker = new ImagePicker();
    PickedFile imageFile = await imagePicker.getImage(
      source: ImageSource.camera,
    );
    Reference reference = FirebaseStorage.instance.ref().child(
        "${widget.chatRoomID}/${Constants.userName}/images/${Path.basename(imageFile.path)}");
    UploadTask uploadTask = reference.putFile(File(imageFile.path));
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() async {
      String downloadURL = await reference.getDownloadURL();
      sendMessage(downloadURL);
    });

    //sendMessage(downloadURL);
  }

  Future _scrollToIndex(String repliedToMessage) async {
    print("Replied to message is $repliedToMessage");
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("ChatRooms")
        .doc(widget.chatRoomID)
        .collection("Messages")
        .orderBy("Time")
        .get();

    int index = snapshot.docs
        .indexWhere((element) => element.get("Message") == repliedToMessage);

    print("$index is the index of the message.");

    if (index != -1) {
      await _autoScrollController.scrollToIndex(isSelected.length - index - 1,
          preferPosition: AutoScrollPosition.begin);
    } else {
      final ScaffoldMessengerState scaffoldMessenger =
          ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(SnackBar(
          duration: Duration(seconds: 1),
          backgroundColor: Colors.grey,
          shape: StadiumBorder(),
          elevation: 5,
          margin: EdgeInsets.only(bottom: 12, left: 10, right: 10),
          behavior: SnackBarBehavior.floating,
          content: Text("This message has been deleted/hidden")));
    }
  }

  Widget toolingHeader(AsyncSnapshot<QuerySnapshot> chatRoomSnapshot) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_back),
          color: Color.fromRGBO(228, 227, 227, 1),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Homepage()));
          },
        ),
        Text(
          isSelected.where((element) => element).length.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        Spacer(),
        GestureDetector(
          onTap: () async {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Are you sure?"),
                    actions: [
                      FlatButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          print(isSelected.toString());
                          setState(() {
                            for (int i = 0; i < isSelected.length; i++) {
                              if (isSelected[i]) {
                                chatRoomSnapshot.data.docs[i].reference
                                    .delete()
                                    .then((value) => print(
                                        "Message deletion successful at index $i"));
                              }
                            }
                            isSelected.removeWhere((element) => element);
                          });

                          print(isSelected.toString());
                        },
                        child: Text("Delete"),
                      ),
                      FlatButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel"),
                      ),
                    ],
                  );
                });
          },
          child: Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              int length = isSelected.length;
              isSelected = List.generate(length, (index) => false);
            });
          },
          child: Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(
              Icons.clear,
              color: Colors.white,
            ),
          ),
        ),
        popupMenuButton(chatRoomSnapshot),
      ],
    );
  }

  PopupMenuButton popupMenuButton(
      AsyncSnapshot<QuerySnapshot> chatRoomSnapshot) {
    return PopupMenuButton(
        onSelected: (code) async {
          setState(() {
            if (code == 'hide') {
              for (int i = 0; i < isSelected.length; i++) {
                if (isSelected[i]) {
                  List visible = chatRoomSnapshot.data.docs[i].get("Visible");
                  visible.removeWhere(
                      (element) => (element == Constants.userName));
                  chatRoomSnapshot.data.docs[i].reference.update({
                    "Visible": visible,
                  }).then((value) {
                    print("A message at index $i is hidden successfully.");
                  });
                }
              }
              isSelected.removeWhere((element) => element);

              print(isSelected.toString());
            }
            if (code == 'select_all') {
              for (int i = 0; i < isSelected.length; i++) {
                isSelected[i] = true;
              }
            }
            if (code == "deselect_all") {
              for (int i = 0; i < isSelected.length; i++) {
                isSelected[i] = false;
              }
            }
          });
        },
        child: Padding(
          padding: EdgeInsets.only(right: 10),
          child: Icon(
            Icons.more_vert,
            color: Colors.white,
          ),
        ),
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              height: 35,
              textStyle: TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
              child: Row(
                children: [
                  Container(
                    height: 25,
                    width: 25,
                    child: getSelectedno() == isSelected.length
                        ? Image.asset("assets/deselect_all.png")
                        : Icon(
                            Icons.select_all,
                          ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(getSelectedno() == isSelected.length
                      ? "Deselect All"
                      : "Select All"),
                ],
              ),
              value: getSelectedno() == isSelected.length
                  ? "deselect_all"
                  : "select_all",
            ),
            PopupMenuItem(
                value: "hide",
                enabled: !(getSelectedno() == 0),
                height: 35,
                textStyle: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
                child: Row(
                  children: [
                    Opacity(
                      opacity: (getSelectedno() == 0) ? 0.3 : 1,
                      child: Container(
                          height: 25,
                          width: 25,
                          child: Image.asset("assets/hidden.png")),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text("Hide"),
                  ],
                )),
          ];
        });
  }

  int getSelectedno() {
    return isSelected.where((element) => element).length;
  }

  Widget profileHeader(AsyncSnapshot<QuerySnapshot> chatRoomSnapshot) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_back),
          color: Color.fromRGBO(228, 227, 227, 1),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Homepage()));
          },
        ),
        CircleAvatar(
          backgroundColor: Colors.grey,
          backgroundImage: photoURL.isNotEmpty ? NetworkImage(photoURL) : null,
        ),
        SizedBox(
          width: 10,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              children: [
                Text(
                  username,
                  style: TextStyle(
                    color: Color.fromRGBO(228, 227, 227, 1),
                    //rgb(228,227,227)
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            Text(
              email,
              style: TextStyle(
                color: Color.fromRGBO(228, 227, 227, 1),
                fontSize: 10,
              ),
            ),
          ],
        ),
        Spacer(),
        popupMenuButton(chatRoomSnapshot),
      ],
    );
  }

  String getTimeForMessageTile(Timestamp timeStamp) {
    DateTime time = timeStamp.toDate();
    String formatted =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    return formatted;
  }
}
