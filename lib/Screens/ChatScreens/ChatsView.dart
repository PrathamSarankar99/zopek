import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:photo_view/photo_view.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:zopek/Screens/ChatScreens/PasswordView.dart';
import 'package:zopek/Screens/HomeScreens/Homepage.dart';
import 'package:zopek/Services/Constants.dart';
import 'package:zopek/Services/database.dart';
import 'dart:math' as math;
import 'package:zopek/Widgets/ChatScreenWidgets/ImageMessage.dart';
import 'package:zopek/Widgets/ChatScreenWidgets/TextMessage.dart';

class Chats extends StatefulWidget {
  final String chatRoomID;
  final String uid;
  final bool incognito;
  const Chats({Key key, this.chatRoomID, this.uid, @required this.incognito})
      : super(key: key);
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
  bool isInconito = false;
  @override
  void initState() {
    super.initState();
    isInconito = widget.incognito;
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
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Chat page is building");
    print("Are you incognito? $isInconito");
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
                  stream: isInconito == null
                      ? dbs.getChatRoomStreamOfMessagesExHidden(
                          widget.chatRoomID, Constants.uid)
                      : (isInconito
                          ? dbs.getChatRoomStreamOfMessages(
                              widget.chatRoomID, Constants.uid)
                          : dbs.getChatRoomStreamOfMessagesExHidden(
                              widget.chatRoomID, Constants.uid)),
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
                    stream: isInconito == null
                        ? dbs.getChatRoomStreamOfMessagesExHidden(
                            widget.chatRoomID, Constants.uid)
                        : (isInconito
                            ? dbs.getChatRoomStreamOfMessages(
                                widget.chatRoomID, Constants.uid)
                            : dbs.getChatRoomStreamOfMessagesExHidden(
                                widget.chatRoomID, Constants.uid)),
                    builder: (context, chatRoomSnapshot) {
                      if (!chatRoomSnapshot.hasData) {
                        return Container();
                      }

                      return ListView.separated(
                          shrinkWrap: true,
                          reverse: true,
                          controller: _autoScrollController,
                          physics: ClampingScrollPhysics(),
                          padding: EdgeInsets.only(top: 5, bottom: 0),
                          itemCount: chatRoomSnapshot.data.docs.length,
                          separatorBuilder: (context, index) {
                            return Container();
                          },
                          itemBuilder: (context, index) {
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
                            margin: EdgeInsets.only(left: 60),
                            width: MediaQuery.of(context).size.width * 0.68,
                            child: TextField(
                              onChanged: (str) {
                                Message.message = str;
                                _autoScrollController.jumpTo(
                                    _autoScrollController
                                        .position.minScrollExtent);
                              },
                              autocorrect: true,
                              focusNode: messageFocusNode,
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
                            right: -20,
                            bottom: 0,
                            child: FlatButton(
                                height: 50,
                                shape: CircleBorder(),
                                onPressed: () {
                                  if (messageController.text != "") {
                                    messageController.clear();
                                    sendMessage('');
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 8.0,
                                  ),
                                  child: Transform.rotate(
                                      angle: math.pi / 0.55,
                                      child: Icon(Icons.send,
                                          color: Colors.black.withBlue(60))),
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

  sendMessage(String filePath) {
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
              _queryDocumentSnapshot.get("ImageURL"),
            ];
      _queryDocumentSnapshot = null;
      FirebaseFirestore.instance
          .collection("ChatRooms")
          .doc(widget.chatRoomID)
          .get()
          .then((docSnapshot) async {
        visible = docSnapshot.get("Users");
        map = {
          "ImageURL": '',
          "FilePath1": filePath,
          "FilePath2": '',
          "Time": DateTime.now(),
          "Sender": Constants.userName,
          "Message": Message.message.trim(),
          "Visible": visible,
          "RepliedTo": repliedTo,
        };
        print('ChatRoomID is : ${widget.chatRoomID}');
        await dbs.sendMessage(widget.chatRoomID, map);
        Message.message = "";
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
    String filepath1 = chatRoomSnapshot.data.docs[index].get("FilePath1");
    String filepath2 = chatRoomSnapshot.data.docs[index].get("FilePath2");
    List repliedTo = chatRoomSnapshot.data.docs[index].get("RepliedTo");
    String repliedToSender = repliedTo.length == 3 ? repliedTo[0] : "";
    String repliedToMessage = repliedTo.length == 3 ? repliedTo[1] : "";
    String repliedToImageURL = repliedTo.length == 3 ? repliedTo[2] : "";
    bool hidden = !chatRoomSnapshot.data.docs[index]
        .get("Visible")
        .contains(Constants.uid);
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
                isSelected[isSelected.length - 1 - index] =
                    !isSelected[isSelected.length - 1 - index];
                print(isSelected);
                return;
              }
              Navigator.push(
                  context,
                  PageTransition(
                      child: Scaffold(
                        appBar: AppBar(
                          title: Text(username),
                          actions: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                              child: Icon(Icons.star_border),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                              child: Icon(Icons.forward),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                              child: Icon(Icons.more_vert),
                            ),
                          ],
                          brightness: Brightness.dark,
                          backgroundColor: Colors.black.withBlue(40),
                        ),
                        body: PhotoView(
                            backgroundDecoration: BoxDecoration(
                              color: Colors.black.withBlue(40),
                            ),
                            heroAttributes:
                                PhotoViewHeroAttributes(tag: imageURL),
                            imageProvider: byme
                                ? FileImage(File(filepath1))
                                : (filepath2 != ''
                                    ? FileImage(File(filepath2))
                                    : NetworkImage(imageURL))),
                      ),
                      type: PageTransitionType.fade));
            });
          },
          onLongPress: () {
            setState(() {
              if (isSelected.contains(false)) {
                isSelected[isSelected.length - 1 - index] =
                    !isSelected[isSelected.length - 1 - index];
                print(isSelected);
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
            child: message == ''
                ? ImageMessage(
                    snapshot: chatRoomSnapshot.data.docs[index],
                    chatRoomID: widget.chatRoomID,
                    isSelected: isSelected[isSelected.length - 1 - index],
                    ontap: () {
                      _scrollToIndex(repliedToMessage, repliedToImageURL);
                    },
                  )
                : TextMessage(
                    byme: byme,
                    hidden: hidden,
                    index: index,
                    isSelected: isSelected[isSelected.length - 1 - index],
                    message: message,
                    messagesLength: isSelected.length,
                    repliedToMessage: repliedToMessage,
                    repliedToSender: repliedToSender,
                    repliedToImageURL: repliedToImageURL,
                    timestamp: timestamp,
                    scrollToIndex: () {
                      _scrollToIndex(repliedToMessage, repliedToImageURL);
                    }),
          )),
    );
    //rgb(216,242,255)
  }

  Future sendImageMessage() async {
    ImagePicker imagePicker = new ImagePicker();
    PickedFile imageFile = await imagePicker.getImage(
      source: ImageSource.camera,
    );
    sendMessage(imageFile.path);

    // Reference reference = FirebaseStorage.instance.ref().child(
    //     "${widget.chatRoomID}/${Constants.userName}/images/${Path.basename(imageFile.path)}");
    // UploadTask uploadTask = reference.putFile(File(imageFile.path));
    // uploadTask.snapshotEvents.listen((event) {});
    // TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() async {
    //   String downloadURL = await reference.getDownloadURL();
    // });
  }

  Future _scrollToIndex(
      String repliedToMessage, String repliedToImageURL) async {
    print("Replied to message is $repliedToMessage");
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("ChatRooms")
        .doc(widget.chatRoomID)
        .collection("Messages")
        .orderBy("Time")
        .get();

    int index = repliedToImageURL != ''
        ? snapshot.docs.indexWhere(
            (element) => element.get("ImageURL") == repliedToImageURL)
        : snapshot.docs.indexWhere(
            (element) => element.get("Message") == repliedToMessage);

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
                                chatRoomSnapshot.data
                                    .docs[isSelected.length - 1 - i].reference
                                    .delete()
                                    .then((value) => print(
                                        "Message deletion successful at index ${isSelected.length - 1 - i}}"));
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
            if (code == 'unhide') {
              for (int i = 0; i < isSelected.length; i++) {
                if (isSelected[isSelected.length - i - 1]) {
                  List visible = chatRoomSnapshot
                      .data.docs[isSelected.length - i - 1]
                      .get("Visible");
                  if (!visible.contains(Constants.uid)) {
                    visible.add(Constants.uid);
                  }
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
            if (code == 'incognito') {
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => PasswordView(),
              //     ));
              dbs.getPassword(Constants.uid).then((password) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PasswordView(
                              password: password,
                            ))).then((value) {
                  setState(() {
                    print("The value is : $value");
                    isInconito = value;
                  });
                });
              });
            }
            if (code == 'hide') {
              for (int i = 0; i < isSelected.length; i++) {
                if (isSelected[isSelected.length - i - 1]) {
                  List visible = chatRoomSnapshot
                      .data.docs[isSelected.length - i - 1]
                      .get("Visible");
                  visible.removeWhere((element) => (element == Constants.uid));
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
          var menuitems = [
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
            PopupMenuItem(
                value: 'incognito',
                height: 35,
                child: Row(
                  children: [
                    SvgPicture.asset('assets/incognito.svg'),
                    SizedBox(
                      width: 5,
                    ),
                    Text('Incognito')
                  ],
                ))
          ];
          if (isInconito) {
            menuitems.insert(
              2,
              PopupMenuItem(
                  value: 'unhide',
                  textStyle: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                  enabled: !(getSelectedno() == 0),
                  height: 35,
                  child: Row(
                    children: [
                      Icon(Icons.remove_red_eye, color: Colors.blue),
                      SizedBox(
                        width: 5,
                      ),
                      Text("Unhide"),
                    ],
                  )),
            );
          }
          return menuitems;
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
}
