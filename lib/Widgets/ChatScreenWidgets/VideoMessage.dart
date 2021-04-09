import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import 'package:thumbnails/thumbnails.dart';
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
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant VideoMessage oldWidget) {
    setThumbnail();

    super.didUpdateWidget(oldWidget);
  }

  @override
  void deactivate() {
    if (progress != 0) {
      super.deactivate();
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

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
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      width: 200,
                      height: 170,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Visibility(
                            visible: widget.snapshot.get('VideoURL') != '',
                            child: Container(
                              height: 100,
                              width: 100,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            child:
                                (widget.snapshot.get("Sender") == Constants.uid)
                                    ? (widget.snapshot.get("VideoURL") != ''
                                        ? postUpload()
                                        : preUpload())
                                    : networkVideo(true),
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

  postUpload() {
    return Container(
      color: Colors.pink,
    );
  }

  setThumbnail() {
    if (widget.snapshot.get("Sender") == Constants.uid) {
      if (widget.snapshot.get("ThumbnailPath1") == '') {
        setState(() {
          Thumbnails.getThumbnail(
                  videoFile: widget.snapshot.get("FilePath1"),
                  imageType: ThumbFormat.PNG,
                  quality: 100)
              .then((value) {
            widget.snapshot.reference.update({
              "ThumbnailPath1": value,
            });
          });
        });
      }
    } else {
      if (widget.snapshot.get("ThumbnailPath2") == '') {
        setState(() {
          Thumbnails.getThumbnail(
                  videoFile: widget.snapshot.get("VideoURL"),
                  imageType: ThumbFormat.JPEG,
                  quality: 30)
              .then((value) {
            widget.snapshot.reference.update({
              "ThumbnailPath2": value,
            });
          });
        });
      }
    }
  }

  preUpload() {
    return Container(
        child: Center(
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX:
                  (progress > 0 && progress < 10) ? 10 - progress * 10 : 0.0,
              sigmaY:
                  (progress > 0 && progress < 10) ? 10 - progress * 10 : 0.0,
            ),
            child: widget.snapshot.get('ThumbnailPath1') == ''
                ? Container()
                : Image.file(
                    File(widget.snapshot.get('ThumbnailPath1')),
                    fit: BoxFit.cover,
                  ),
          ),
          Container(
            alignment: Alignment.center,
            child: Container(
              width: 90,
              height: 90,
              child: CircularProgressIndicator(
                value: (progress >= 0 && progress < 1) ? progress : null,
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (progress == 0) {
                uploadFile().then((value) {
                  print("Uploading is done");
                });
              } else {
                Fluttertoast.showToast(
                  msg: "Already uploading",
                  backgroundColor: Colors.red,
                  gravity: ToastGravity.TOP,
                  textColor: Colors.white,
                );
              }
            },
            child: Icon(Icons.upload_file),
          )
        ],
      ),
    ));
  }

  networkVideo(bool needLoader) {
    return Container(
      color: Colors.blue,
    );
  }

  Future uploadFile() async {
    if ((widget.snapshot.get("Sender") == Constants.uid) &&
        widget.snapshot.get("VideoURL") == '') {
      uploadImage(widget.snapshot.get('FilePath1'));
    }
  }

  uploadImage(String filePath) async {
    Reference reference = FirebaseStorage.instance.ref().child(
        "${widget.chatRoomID}/${Constants.uid}/videos/${basename(filePath)}");
    UploadTask uploadTask = reference.putFile(File(filePath));
    uploadTask.snapshotEvents.listen((event) {
      setState(() {
        progress =
            event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
        print('Progress : $progress');
      });
    }).onError((e) {
      print('There is an error : $e');
    });
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() async {
      String downloadURL = await reference.getDownloadURL();
      setState(() {
        widget.snapshot.reference.update({
          "VideoURL": downloadURL,
        });
      });
    });
  }
}
