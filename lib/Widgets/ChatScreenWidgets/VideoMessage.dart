import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path/path.dart';
import 'package:zopek/Screens/ChatScreens/SingleVideoPlayer.dart';
import 'package:zopek/Modals/Constants.dart';

class VideoMessage extends StatefulWidget {
  final QueryDocumentSnapshot snapshot;
  final bool isSelected;
  final String chatRoomID;
  final VoidCallback ontap;

  const VideoMessage(
      {Key key, this.snapshot, this.isSelected, this.chatRoomID, this.ontap})
      : super(key: key);
  @override
  _VideoMessageState createState() => _VideoMessageState();
}

class _VideoMessageState extends State<VideoMessage> {
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    String replyText = replySpecifier(widget.snapshot.get('RepliedTo'));

    Widget repliedAddOn(String text) {
      if (widget.snapshot.get("RepliedTo").isEmpty) {
        return Container();
      }
      Alignment alignment = (widget.snapshot.get("Sender") == Constants.uid)
          ? Alignment.centerRight
          : Alignment.centerLeft;
      Color color = (widget.snapshot.get('RepliedTo')[0] == Constants.uid
          ? Color.fromRGBO(23, 105, 164, 0.8)
          : Colors.amber.shade300.withOpacity(0.8));
      return GestureDetector(
        onTap: widget.ontap,
        child: Column(
          children: [
            Container(
                alignment: alignment,
                margin: (widget.snapshot.get("Sender") == Constants.uid)
                    ? EdgeInsets.only(right: 20, top: 20)
                    : EdgeInsets.only(left: 20, top: 20),
                child: Text(text)),
            Container(
              margin: (widget.snapshot.get("Sender") == Constants.uid)
                  ? EdgeInsets.only(
                      right: 20,
                      left: MediaQuery.of(context).size.width * 0.20,
                    )
                  : EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.20,
                      left: 20,
                    ),
              alignment: alignment,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: (widget.snapshot.get("Sender") == Constants.uid)
                      ? Border(
                          right: BorderSide(
                              color: color, width: 2, style: BorderStyle.solid))
                      : Border(
                          left: BorderSide(
                              color: color,
                              width: 2,
                              style: BorderStyle.solid))),
              child: Container(
                padding: widget.snapshot.get('RepliedTo')[1] != ''
                    ? EdgeInsets.only(top: 10, bottom: 10)
                    : EdgeInsets.zero,
                margin: (widget.snapshot.get("Sender") == Constants.uid)
                    ? EdgeInsets.only(right: 10)
                    : EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: color,
                ),
                child: Padding(
                  padding: widget.snapshot.get('RepliedTo')[1] != ''
                      ? const EdgeInsets.only(right: 8.0, left: 8.0)
                      : EdgeInsets.zero,
                  child: widget.snapshot.get('RepliedTo')[1] != ''
                      ? Text(widget.snapshot.get('RepliedTo')[1])
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 1.5,
                              ),
                            ),
                            Container(
                                width: 70,
                                height: 60,
                                child: (widget.snapshot.get("RepliedTo")[0] ==
                                        Constants.uid)
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                        child: Image.network(
                                            (widget.snapshot
                                                .get('RepliedTo')[2]),
                                            fit: BoxFit.cover),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                        child: Image.network(
                                            (widget.snapshot
                                                .get('RepliedTo')[2]),
                                            fit: BoxFit.cover),
                                      )),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Color selectedColor = widget.isSelected
        ? (!(widget.snapshot.get("Sender") == Constants.uid)
            ? Colors.amber.shade300.withOpacity(0.5)
            : Color.fromRGBO(23, 105, 164, 0.5))
        : Colors.transparent;
    return (widget.snapshot.get("VideoURL") == '' &&
            !(widget.snapshot.get("Sender") == Constants.uid))
        ? Container()
        : Container(
            color: selectedColor,
            child: Hero(
              tag: basename(widget.snapshot.get('FilePath1')),
              child: Column(
                children: [
                  repliedAddOn(replyText),
                  Container(
                    alignment: (widget.snapshot.get("Sender") == Constants.uid)
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    height: 180,
                    color: Colors.transparent,
                    child: Container(
                      margin: (widget.snapshot.get("Sender") == Constants.uid)
                          ? EdgeInsets.only(right: 22)
                          : EdgeInsets.only(left: 22),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      width: 200,
                      height: 170,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        child: (widget.snapshot.get("Sender") == Constants.uid)
                            ? (widget.snapshot.get("VideoURL") != ''
                                ? postUpload(context) //change it to postUpload
                                : preUpload())
                            : networkVideo(true),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  String replySpecifier(List repliedTo) {
    if (repliedTo.isEmpty) {
      return '';
    }
    if (Constants.uid == widget.snapshot.get('Sender')) {
      if (widget.snapshot.get('RepliedTo')[0] == Constants.uid) {
        return 'Replied to yourself';
      }
      return 'Replied to them';
    }
    if (widget.snapshot.get('RepliedTo')[0] == Constants.uid) {
      return 'Replied to you';
    }
    return 'Replied to themselves';
  }

  postUpload(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.blue,
          image: DecorationImage(
              fit: BoxFit.cover,
              image: FileImage(
                File(Hive.box(widget.chatRoomID)
                    .get("${widget.snapshot.get("FilePath1")}_Thumbnail1")),
              ))),
      child: Stack(
        alignment: Alignment.center,
        children: [
          TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(CircleBorder()),
              minimumSize: MaterialStateProperty.all(Size(70, 70)),
              overlayColor: MaterialStateProperty.all(
                  Colors.blue.shade400.withOpacity(0.5)),
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  PageTransition(
                      child: SingleVideoPlayer(
                        source: VideoSource(
                          path: widget.snapshot.get("VideoURL"),
                          sourceType: SourceType.online,
                        ),
                      ),
                      type: PageTransitionType.fade));
            },
            child: Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 35,
            ),
          ),
        ],
      ),
    );
  }

  preUpload() {
    String key1 = "${widget.snapshot.get("FilePath1")}_Thumbnail1";
    String key2 = "${widget.snapshot.get("FilePath1")}_Thumbnail2";
    print("Coming to this method");
    return Container(
        color: Colors.blue,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: 10,
                  sigmaY: 10,
                ),
                child: widget.snapshot.get("Sender") == Constants.uid
                    ? StreamBuilder<BoxEvent>(
                        stream: Hive.box(widget.chatRoomID).watch(key: key1),
                        builder: (context, snapshot) {
                          return snapshot.hasData
                              ? Image.file(
                                  File(snapshot.data.value),
                                  fit: BoxFit.cover,
                                )
                              : Hive.box(widget.chatRoomID).get(key1) == null
                                  ? Container(
                                      color: Colors.blue.shade400,
                                    )
                                  : Image.file(
                                      File(
                                        Hive.box(widget.chatRoomID).get(key1),
                                      ),
                                      fit: BoxFit.cover,
                                    );
                        })
                    : StreamBuilder<BoxEvent>(
                        stream: Hive.box(widget.chatRoomID).watch(key: key2),
                        builder: (context, snapshot) {
                          return Image.file(
                            File(
                              snapshot.hasData
                                  ? snapshot.data.value
                                  : Hive.box(widget.chatRoomID).get(key2),
                            ),
                            fit: BoxFit.cover,
                          );
                        }),
              ),
              Container(
                alignment: Alignment.center,
                child: Container(
                  width: 90,
                  height: 90,
                  child: StreamBuilder<BoxEvent>(
                      stream: Hive.box(widget.chatRoomID)
                          .watch(key: widget.snapshot.get("FilePath1")),
                      builder: (context, snapshot) {
                        return CircularProgressIndicator(
                          value: snapshot.hasData
                              ? snapshot.data.value
                              : Hive.box(widget.chatRoomID)
                                  .get(widget.snapshot.get("FilePath1")),
                          strokeWidth: 1.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        );
                      }),
                ),
              ),
            ],
          ),
        ));
  }

  networkVideo(bool needLoader) {
    return Container(
      color: Colors.blue,
    );
  }
}
