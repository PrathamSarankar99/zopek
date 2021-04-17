import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path/path.dart' as Path;
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:photo_view/photo_view.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:thumbnails/thumbnails.dart';
import 'package:video_compress/video_compress.dart';
import 'package:zopek/Modals/ImageSource.dart';
import 'package:zopek/Modals/revert.dart';
import 'package:zopek/Screens/ChatScreens/AboutView.dart';
import 'package:zopek/Screens/ChatScreens/Capture.dart';
import 'package:zopek/Screens/ChatScreens/PasswordView.dart';
import 'package:zopek/Screens/HomeScreens/Homepage.dart';
import 'package:zopek/Modals/Camera.dart';
import 'package:zopek/Modals/Constants.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zopek/Services/database.dart';
import 'package:zopek/Services/realtime_database.dart';
import 'dart:math' as math;
import 'package:zopek/Widgets/ChatScreenWidgets/ImageMessage.dart';
import 'package:zopek/Widgets/ChatScreenWidgets/TextMessage.dart';
import 'package:zopek/Widgets/ChatScreenWidgets/VideoMessage.dart';
import 'package:zopek/main.dart';

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
  Box chatRoomBox;
  TextEditingController messageController = new TextEditingController();
  FocusNode messageFocusNode;
  List<bool> isSelected = [];
  String photoURL = "";
  String username = "";
  String email = "";
  String uid = "";
  AutoScrollController _autoScrollController = new AutoScrollController();
  QueryDocumentSnapshot _queryDocumentSnapshot;
  String wallpaper = "";
  TextStyle popupMenuTextStyle;
  bool isInconito = false;
  double progress = 0;
  KeyboardVisibilityNotification keyboardVisibilityNotification;
  int subscribingid;

  @override
  void initState() {
    super.initState();

    keyboardVisibilityNotification = new KeyboardVisibilityNotification();
    subscribingid = keyboardVisibilityNotification.addNewListener(
      onChange: (bool visible) {
        print("Printing chatRoomIDs ${widget.chatRoomID}");
        DataBaseServices.setTypingStatus(
            widget.chatRoomID, widget.uid, visible);
      },
    );
    Hive.openBox(widget.chatRoomID).then((value) {
      setState(() {
        chatRoomBox = value;
      });
    });
    print("ChatState - Created");
    popupMenuTextStyle = new TextStyle(
      fontSize: 15,
    );
    isInconito = widget.incognito;
    populateSelection().then((value) {
      setState(() {
        print("The selected length is :${isSelected.length}");
      });
    });
    messageFocusNode = FocusNode();
    messageFocusNode.addListener(() {
      print("Has focus : ${messageFocusNode.hasFocus}");
    });
    getUserInfo();
    DataBaseServices.getWallpapers(widget.chatRoomID).then((value) {
      setState(() {
        List<String> users = [Constants.uid, widget.uid];
        users.sort();
        if (value.isNotEmpty && value != null) {
          wallpaper = value[users.indexOf(Constants.uid)];
        }
      });
    });
  }

  @override
  void dispose() {
    print("ChatState - Destroyed");
    super.dispose();
    keyboardVisibilityNotification.removeListener(subscribingid);
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => AuthenticityDecider()));
          return;
        },
        child: StreamBuilder<QuerySnapshot>(
            stream: isInconito == null
                ? DataBaseServices.getChatRoomStreamOfMessagesExHidden(
                    widget.chatRoomID, Constants.uid)
                : (isInconito
                    ? DataBaseServices.getChatRoomStreamOfMessages(
                        widget.chatRoomID, Constants.uid)
                    : DataBaseServices.getChatRoomStreamOfMessagesExHidden(
                        widget.chatRoomID, Constants.uid)),
            builder: (context, chatRoomSnapshot) {
              return Column(
                children: [
                  Container(
                      height: MediaQuery.of(context).size.height * 0.15,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.black.withBlue(40),
                      child: SafeArea(
                          child: isSelected.contains(true)
                              ? toolingHeader(chatRoomSnapshot)
                              : profileHeader(chatRoomSnapshot))),
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          color: Colors.black.withBlue(40),
                        ),
                        //Widget defining background of the chat.
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              image: wallpaper.isEmpty
                                  ? null
                                  : DecorationImage(
                                      image: NetworkImage(wallpaper),
                                      fit: BoxFit.cover),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              )),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              )),
                          width: MediaQuery.of(context).size.width,
                          child: !chatRoomSnapshot.hasData
                              ? Container()
                              : ListView.separated(
                                  shrinkWrap: true,
                                  reverse: true,
                                  controller: _autoScrollController,
                                  physics: ClampingScrollPhysics(),
                                  padding:
                                      const EdgeInsets.only(top: 5, bottom: 0),
                                  itemCount: chatRoomSnapshot.data.docs.length,
                                  separatorBuilder: (context, index) {
                                    return Container();
                                  },
                                  itemBuilder: (context, index) {
                                    print("Getting message $index");

                                    return messageTile(index, chatRoomSnapshot);
                                  }),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomLeft,
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(top: 3),
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(241, 245, 246, 1),
                        //rgb(241,245,246)
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      margin: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Visibility(
                            visible: _queryDocumentSnapshot != null,
                            child: _queryDocumentSnapshot == null
                                ? Container()
                                : Container(
                                    height: 100,
                                    width:
                                        MediaQuery.of(context).size.width - 16,
                                    color: Colors.transparent,
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                        top: 10,
                                        left: 10,
                                      ),
                                      margin: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _queryDocumentSnapshot
                                                    .get("Sender") ==
                                                Constants.userName
                                            ? Color.fromRGBO(23, 105, 164, 0.3)
                                            : Colors.amber.withOpacity(0.5),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                    _queryDocumentSnapshot =
                                                        null;
                                                  });
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
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
                                            padding: const EdgeInsets.only(
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
                                              padding: const EdgeInsets.only(
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
                                                                .withOpacity(
                                                                    0.7),
                                                          ),
                                                          Text(
                                                            "Photo",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w200,
                                                                fontSize: 17,
                                                                color: Colors
                                                                    .black
                                                                    .withBlue(
                                                                        40)
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
                                  left: 5,
                                  bottom: 2,
                                  child: TextButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.blue),
                                          shape: MaterialStateProperty.all(
                                              CircleBorder()),
                                          minimumSize:
                                              MaterialStateProperty.all(
                                                  Size(45, 45))),
                                      onPressed: () async {
                                        await sendMediaMessage();
                                      },
                                      child: Icon(
                                        Icons.photo_camera,
                                        color: Colors.white,
                                      )),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.only(bottom: 2),
                                  margin: const EdgeInsets.only(left: 60),
                                  width:
                                      MediaQuery.of(context).size.width * 0.68,
                                  child: TextField(
                                    autofocus: false,
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
                                  right: 0,
                                  bottom: 0,
                                  child: TextButton(
                                      style: ButtonStyle(
                                        minimumSize: MaterialStateProperty.all(
                                            Size(50, 50)),
                                        shape: MaterialStateProperty.all(
                                            CircleBorder()),
                                      ),
                                      onPressed: () {
                                        if (messageController.text != "") {
                                          messageController.clear();
                                          sendMessage();
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8.0,
                                          left: 5,
                                        ),
                                        child: Transform.rotate(
                                            angle: math.pi / 0.55,
                                            child: Icon(Icons.send,
                                                color:
                                                    Colors.black.withBlue(60))),
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
              );
            }),
      ),
    );
  }

  sendMessage(
      {String filePath, bool isImage: false, bool isVideo: false}) async {
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
        "isVideo": isVideo,
        "VideoURL": '',
        'isImage': isImage,
        "FilePath1": filePath,
        "FilePath2": '',
        "ThumbnailPath1": '',
        "ThumbnailPath2": '',
        "Time": DateTime.now(),
        "Sender": Constants.uid,
        "Reciever": widget.uid,
        "Message": Message.message.trim(),
        "Visible": visible,
        "RepliedTo": repliedTo,
      };
      print('ChatRoomID is : ${widget.chatRoomID}');
      await DataBaseServices.sendMessage(widget.chatRoomID, map)
          .then((value) async {
        Message.message = "";
        print("Message : A new message sent");
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection("ChatRooms")
            .doc(widget.chatRoomID)
            .collection("Messages")
            .where("FilePath1", isEqualTo: filePath)
            .limit(1)
            .get();
        String key1 = "${snapshot.docs[0].get("FilePath1")}_Thumbnail1";
        String key2 = "${snapshot.docs[0].get("FilePath1")}_Thumbnail2";
        if (!isImage && !isVideo) {
          print("Message : It retured");
          return;
        } else if (isVideo) {
          print("Thumbnail started");
          if (snapshot.docs[0].get("Sender") == Constants.uid) {
            String path = await Thumbnails.getThumbnail(
              videoFile: snapshot.docs[0].get("FilePath1"),
              imageType: ThumbFormat.PNG,
              quality: 100,
            );
            Hive.box(widget.chatRoomID).put(key1, path);
          } else {
            String path = await Thumbnails.getThumbnail(
              videoFile: snapshot.docs[0].get("VideoURL"),
              imageType: ThumbFormat.JPEG,
              quality: 100,
            );
            Hive.box(widget.chatRoomID).put(key2, path);
          }
        }
        String fileType = isImage ? "images" : "videos";
        Reference reference = FirebaseStorage.instance.ref().child(
            "${widget.chatRoomID}/${Constants.uid}/$fileType/${Path.basename(filePath)}");
        UploadTask uploadTask = reference.putFile(File(filePath));
        uploadTask.snapshotEvents.listen((event) {
          double progress =
              event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
          chatRoomBox.put(filePath, progress);
          print(chatRoomBox.get(filePath));
        }).onError((e) {
          print('There is an error : $e');
        });
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() async {
          String downloadURL = await reference.getDownloadURL();

          if (isImage) {
            snapshot.docs[0].reference.update({
              "ImageURL": downloadURL,
            });
          } else if (isVideo) {
            snapshot.docs[0].reference.update({
              "VideoURL": downloadURL,
            });
          }
        });
      });
    });
  }

  Future<int> populateSelection() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("ChatRooms")
        .doc(widget.chatRoomID)
        .collection("Messages")
        .where("Visible", arrayContains: Constants.uid)
        .get();
    int length = snapshot.docs.length;
    isSelected = List.generate(length, (index) => false, growable: true);
    return 0;
  }

  Future getUserInfo() async {
    Stream<DocumentSnapshot> snap = DataBaseServices.getUserByID(widget.uid);
    await snap.first.then((value) {
      setState(() {
        uid = value.id;
        photoURL = value.get("PhotoURL");
        username = value.get("UserName").toString().length > 15
            ? '${value.get("UserName").toString().substring(0, 15)}...'
            : value.get("UserName").toString();

        email = value.get("Email");
      });
    });
  }

  Widget messageTile(int index, AsyncSnapshot<QuerySnapshot> chatRoomSnapshot) {
    String imageURL = chatRoomSnapshot.data.docs[index].get("ImageURL");
    bool byme =
        chatRoomSnapshot.data.docs[index].get("Sender") == Constants.uid;

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
    bool isImage = chatRoomSnapshot.data.docs[index].get("isImage");
    bool isVideo = chatRoomSnapshot.data.docs[index].get("isVideo");
    if (isSelected.isEmpty || isSelected.length <= index) {
      return Container(
        margin: EdgeInsets.only(bottom: 5, top: 5),
        width: MediaQuery.of(context).size.width,
        height: 200,
        color: Colors.transparent,
      );
    }
    return AutoScrollTag(
      key: ValueKey(index),
      controller: _autoScrollController,
      index: index,
      child: GestureDetector(
          onTapDown: (details) {
            print(details.localPosition);
          },
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
              if (imageURL == '') {
                return;
              }
              Navigator.push(
                  context,
                  PageTransition(
                      child: Scaffold(
                        appBar: AppBar(
                          title: Text(username),
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
            child: isImage == true
                ? ImageMessage(
                    key: ObjectKey(timestamp),
                    snapshot: chatRoomSnapshot.data.docs[index],
                    chatRoomID: widget.chatRoomID,
                    isSelected: isSelected[isSelected.length - 1 - index],
                    ontap: () {
                      _scrollToIndex(repliedToMessage, repliedToImageURL);
                    },
                  )
                : (isVideo
                    ? VideoMessage(
                        key: ObjectKey(timestamp),
                        snapshot: chatRoomSnapshot.data.docs[index],
                        chatRoomID: widget.chatRoomID,
                        isSelected: isSelected[isSelected.length - 1 - index],
                        ontap: () {
                          _scrollToIndex(repliedToMessage, repliedToImageURL);
                        },
                      )
                    : TextMessage(
                        key: ObjectKey(timestamp),
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
                        })),
          )),
    );
    //rgb(216,242,255)
  }

  Future sendMediaMessage() async {
    Revert revert = await Navigator.push(
        context,
        PageTransition(
            child: Capture(
              cameraDescriptions: CameraConfigurations.cameraDescriptionList,
            ),
            type: PageTransitionType.fade));
    if (revert != null) {
      switch (revert.media) {
        case Media.image:
          sendMessage(filePath: revert.path, isImage: true);

          break;
        case Media.video:
          VideoCompress.compressVideo(
            revert.path,
            deleteOrigin: true,
            includeAudio: true,
            quality: VideoQuality.DefaultQuality,
          ).then((value) {
            sendMessage(filePath: value.path, isVideo: true);
          });
          break;
      }
    }
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
                      TextButton(
                        onPressed: () async {
                          messageFocusNode.nextFocus();
                          Navigator.pop(context);
                          print(isSelected.toString());
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

                          print(isSelected.toString());
                        },
                        child: Text("Delete"),
                      ),
                      TextButton(
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
        popupMenuButton(chatRoomSnapshot, context),
      ],
    );
  }

  PopupMenuButton popupMenuButton(
      AsyncSnapshot<QuerySnapshot> chatRoomSnapshot, BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return PopupMenuButton(
        onSelected: (code) async {
          messageFocusNode.nextFocus();
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
            if (code == 'wallpaper') {
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
                              width: width / 3,
                              child: new Material(
                                child: new InkWell(
                                  onTap: () {
                                    updateWallpaper('camera');
                                  },
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: height * 0.015,
                                      ),
                                      Container(
                                          height: height * 0.08,
                                          width: width * 0.25,
                                          child:
                                              Image.asset('assets/camera.png')),
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
                              width: width / 3,
                              child: new Material(
                                child: new InkWell(
                                  onTap: () {
                                    updateWallpaper('gallery');
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
                            Container(
                              height: height * 0.15,
                              width: width / 3,
                              child: new Material(
                                child: new InkWell(
                                  onTap: () {
                                    updateWallpaper("remove");
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
                                              'assets/delete_photo.png')),
                                      Text('Remove',
                                          style: TextStyle(
                                            color: Colors.blue,
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
            }
            if (code == 'incognito') {
              DataBaseServices.getPassword(Constants.uid).then((password) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PasswordView(
                              password: password == null ? false : password,
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
            if (code == 'about') {
              Navigator.push(
                context,
                PageTransition(
                    duration: Duration(seconds: 1),
                    curve: Curves.decelerate,
                    alignment: Alignment.topRight,
                    child: About(
                      uid: widget.uid,
                    ),
                    type: PageTransitionType.scale),
              );
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
              height: 45,
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
                  Text(
                      getSelectedno() == isSelected.length
                          ? "Deselect All"
                          : "Select All",
                      style: popupMenuTextStyle),
                ],
              ),
              value: getSelectedno() == isSelected.length
                  ? "deselect_all"
                  : "select_all",
            ),
            PopupMenuItem(
                value: "hide",
                enabled: !(getSelectedno() == 0),
                height: 45,
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
                    Text("Hide", style: popupMenuTextStyle),
                  ],
                )),
            PopupMenuItem(
                value: 'incognito',
                height: 45,
                child: Row(
                  children: [
                    SvgPicture.asset('assets/incognito.svg'),
                    SizedBox(
                      width: 5,
                    ),
                    Text('Incognito', style: popupMenuTextStyle)
                  ],
                )),
            PopupMenuItem(
                value: "wallpaper",
                height: 45,
                textStyle: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
                child: Row(
                  children: [
                    Container(
                        height: 25,
                        width: 25,
                        child: Image.asset("assets/wallpaper.png")),
                    SizedBox(
                      width: 5,
                    ),
                    Text("Wallpaper", style: popupMenuTextStyle),
                  ],
                )),
            PopupMenuItem(
                value: 'about',
                height: 45,
                child: Row(
                  children: [
                    Transform.rotate(
                        angle: math.pi, child: Icon(Icons.error_outline)),
                    SizedBox(
                      width: 5,
                    ),
                    Text('About', style: popupMenuTextStyle)
                  ],
                )),
          ];
          if (isInconito != null && isInconito) {
            menuitems.insert(
              2,
              PopupMenuItem(
                  value: 'unhide',
                  textStyle: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                  enabled: !(getSelectedno() == 0),
                  height: 45,
                  child: Row(
                    children: [
                      Icon(Icons.remove_red_eye, color: Colors.blue),
                      SizedBox(
                        width: 5,
                      ),
                      Text("Unhide", style: popupMenuTextStyle),
                    ],
                  )),
            );
          }
          return menuitems;
        });
  }

  updateWallpaper(String str) {
    List<String> users = [Constants.uid, widget.uid];
    users.sort();
    int index = users.indexOf(Constants.uid);
    switch (str) {
      case "remove":
        {
          Navigator.pop(context);
          setState(() {
            DataBaseServices.removeWallpaper(widget.chatRoomID, index);
            wallpaper = "";
          });
        }
        break;
      case "camera":
        {
          DataBaseServices.updateWallpaper(
                  widget.chatRoomID, index, ImageSource.camera, context)
              .then((value) {
            if (value.isNotEmpty) {
              Navigator.pop(context);
              setState(() {
                wallpaper = value;
              });
            }
          });
        }
        break;
      case "gallery":
        {
          DataBaseServices.updateWallpaper(
                  widget.chatRoomID, index, ImageSource.gallery, context)
              .then((value) {
            Navigator.pop(context);
            if (value.isNotEmpty) {
              setState(() {
                wallpaper = value;
              });
            }
          });
        }
        break;
    }
  }

  int getSelectedno() {
    return isSelected.where((element) => element).length;
  }

  String formatTime(Timestamp timeStamp) {
    String value = '';
    DateTime current = DateTime.now();
    DateTime comparer = timeStamp.toDate();

    if (((comparer.day == current.day) &&
        (comparer.month == current.month) &&
        (comparer.year == current.year))) {
      Duration duration = comparer.difference(current);
      value =
          "${comparer.hour.toString().padLeft(2, '0')}:${comparer.minute.toString().padLeft(2, '0')}";
    } else {
      value =
          "${comparer.day}/${comparer.month}/${comparer.year} - ${comparer.hour.toString().padLeft(2, '0')}:${comparer.minute.toString().padLeft(2, '0')}";
    }
    return value;
  }

  Widget profileHeader(AsyncSnapshot<QuerySnapshot> chatRoomSnapshot) {
    return StreamBuilder<DocumentSnapshot>(
        stream: DataBaseServices.typingStatusStream(widget.chatRoomID),
        builder: (context, typingsnapshot) {
          List users = [Constants.uid, widget.uid];
          users.sort();
          return StreamBuilder<Event>(
              stream: RealtimeDatabase.getStream(),
              builder: (context, snapshot) {
                String status = (typingsnapshot.hasData &&
                        typingsnapshot.data
                            .get("Typing")[users.indexOf(widget.uid)])
                    ? "typing..."
                    : (snapshot.hasData
                        ? snapshot.data.snapshot.value[widget.uid]["Status"]
                        : "");
                if (status == "Offline") {
                  status = formatTime(Timestamp.fromMicrosecondsSinceEpoch(
                      snapshot.data.snapshot.value[widget.uid]["LastSeen"]));
                }

                return GestureDetector(
                  onTap: () {
                    messageFocusNode.nextFocus();
                    Navigator.push(
                        context,
                        PageTransition(
                            alignment: Alignment.topCenter,
                            duration: Duration(
                              milliseconds: 300,
                            ),
                            child: About(
                              uid: widget.uid,
                            ),
                            type: PageTransitionType.fade));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        color: Color.fromRGBO(228, 227, 227, 1),
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Homepage()));
                        },
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            photoURL.isNotEmpty ? NetworkImage(photoURL) : null,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: TextStyle(
                              color: Color.fromRGBO(228, 227, 227, 1),
                              //rgb(228,227,227)
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 3),
                          Row(
                            children: [
                              Visibility(
                                visible: status == "Online" || status == "Away",
                                child: Container(
                                  margin: EdgeInsets.only(right: 5),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: status == "Online"
                                        ? Colors.green
                                        : Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Text(
                                status == "Offline" ? "" : status,
                                style: TextStyle(
                                  color: (status == "Online" ||
                                          status == "typing...")
                                      ? Colors.green
                                      : (status == "Away"
                                          ? Colors.orange
                                          : Color.fromRGBO(228, 227, 227, 1)),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Spacer(),
                      popupMenuButton(chatRoomSnapshot, context),
                    ],
                  ),
                );
              });
        });
  }
}
