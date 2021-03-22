import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:file_utils/file_utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zopek/Services/Constants.dart';
import 'package:path/path.dart' as Path;
import 'dart:io';

class ImageMessage extends StatefulWidget {
  final QueryDocumentSnapshot snapshot;
  final bool isSelected;
  final String chatRoomID;
  final VoidCallback ontap;
  const ImageMessage({
    Key key,
    this.snapshot,
    this.isSelected,
    this.chatRoomID,
    this.ontap,
  }) : super(key: key);

  @override
  _ImageMessageState createState() => _ImageMessageState();
}

class _ImageMessageState extends State<ImageMessage> {
  double progress = 0;
  Permission permission1 = Permission.storage;
  double downloadingprogress = 0;
  var path = "No Data";

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    uploadFile();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ImageMessage oldWidget) {
    uploadFile();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    String replyText = replySpecifier(widget.snapshot.get('RepliedTo'));
    Color selectedColor = widget.isSelected
        ? (!(widget.snapshot.get("Sender") == Constants.userName)
            ? Colors.amber.shade300.withOpacity(0.5)
            : Color.fromRGBO(23, 105, 164, 0.5))
        : Colors.transparent;
    print(downloadingprogress);
    return (widget.snapshot.get("ImageURL") == '' &&
            !(widget.snapshot.get("Sender") == Constants.userName))
        ? Container()
        : Container(
            color: selectedColor,
            child: Hero(
              tag: Path.basename(widget.snapshot.get('FilePath1')),
              child: Column(
                children: [
                  repliedAddOn(replyText),
                  Container(
                    alignment:
                        (widget.snapshot.get("Sender") == Constants.userName)
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                    height: 180,
                    color: Colors.transparent,
                    child: Container(
                      margin:
                          (widget.snapshot.get("Sender") == Constants.userName)
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
                            visible: widget.snapshot.get('ImageURL') != '',
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
                            child: (widget.snapshot.get("Sender") ==
                                    Constants.userName)
                                ? (widget.snapshot.get("ImageURL") != ''
                                    ? postUpload()
                                    : preUpload())
                                : (widget.snapshot.get("FilePath2") != ''
                                    ? postDownload()
                                    : preDownload()),
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

  Widget repliedAddOn(String text) {
    if (widget.snapshot.get("RepliedTo").isEmpty) {
      return Container();
    }
    Alignment alignment = (widget.snapshot.get("Sender") == Constants.userName)
        ? Alignment.centerRight
        : Alignment.centerLeft;
    Color color = (widget.snapshot.get('RepliedTo')[0] == Constants.userName
        ? Color.fromRGBO(23, 105, 164, 0.8)
        : Colors.amber.shade300.withOpacity(0.8));
    return GestureDetector(
      onTap: widget.ontap,
      child: Column(
        children: [
          Container(
              alignment: alignment,
              margin: (widget.snapshot.get("Sender") == Constants.userName)
                  ? EdgeInsets.only(right: 20, top: 20)
                  : EdgeInsets.only(left: 20, top: 20),
              child: Text(text)),
          Container(
            margin: (widget.snapshot.get("Sender") == Constants.userName)
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
                border: (widget.snapshot.get("Sender") == Constants.userName)
                    ? Border(
                        right: BorderSide(
                            color: color, width: 2, style: BorderStyle.solid))
                    : Border(
                        left: BorderSide(
                            color: color, width: 2, style: BorderStyle.solid))),
            child: Container(
              padding: widget.snapshot.get('RepliedTo')[1] != ''
                  ? EdgeInsets.only(top: 10, bottom: 10)
                  : EdgeInsets.zero,
              margin: (widget.snapshot.get("Sender") == Constants.userName)
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
                                      Constants.userName)
                                  ? ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(15)),
                                      child: Image.network(
                                          (widget.snapshot.get('RepliedTo')[2]),
                                          fit: BoxFit.cover),
                                    )
                                  : ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(15)),
                                      child: Image.network(
                                          (widget.snapshot.get('RepliedTo')[2]),
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

  Widget postUpload() {
    return Image.file(
      File(widget.snapshot.get('FilePath1')),
      fit: BoxFit.cover,
    );
  }

  String replySpecifier(List repliedTo) {
    if (repliedTo.isEmpty) {
      return '';
    }
    if (Constants.userName == widget.snapshot.get('Sender')) {
      if (widget.snapshot.get('RepliedTo')[0] == Constants.userName) {
        return 'Replied to yourself';
      }
      return 'Replied to them';
    }
    if (widget.snapshot.get('RepliedTo')[0] == Constants.userName) {
      return 'Replied to you';
    }
    return 'Replied to themselves';
  }

  Widget preUpload() {
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
            child: Image.file(
              File(widget.snapshot.get('FilePath1')),
              fit: BoxFit.cover,
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Container(
              width: 90,
              height: 90,
              child: CircularProgressIndicator(
                value: (progress > 0 && progress < 1) ? progress : null,
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget postDownload() {
    try {
      return Image.file(
        File(widget.snapshot.get("FilePath2")),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return preDownload();
        },
      );
    } catch (e) {
      return preDownload();
    }
  }

  Widget preDownload() {
    return Container(
        child: Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: netWorkImage(false)),
        Container(
          alignment: Alignment.center,
          child: Container(
            width: 90,
            height: 90,
            child: CircularProgressIndicator(
              value: (downloadingprogress > 0.0 && downloadingprogress < 1.0)
                  ? downloadingprogress
                  : 0,
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: Container(
            width: 90,
            height: 90,
            child: FlatButton(
              shape: CircleBorder(),
              height: 50,
              onPressed: () {
                downloadFile();
                setState(() {
                  downloadingprogress = 0;
                });
              },
              child: downloadingprogress > 0 && downloadingprogress < 1
                  ? (downloadingprogress == 1
                      ? Container()
                      : Container(
                          child: Text(
                            ((downloadingprogress * 100).toInt()).toString() +
                                "%",
                            style: TextStyle(color: Colors.white),
                          ),
                        ))
                  : Icon(
                      Icons.download_sharp,
                      color: Colors.white,
                    ),
            ),
          ),
        ),
      ],
    ));
  }

  Widget netWorkImage(bool needLoader) {
    return Image.network(
      widget.snapshot.get("ImageURL"),
      fit: BoxFit.cover,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent loadingProgress) {
        if (loadingProgress == null || !needLoader) return child;
        return Center(
          child: Container(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes
                  : null,
            ),
          ),
        );
      },
    );
  }

  Future<void> downloadImage() async {
    Dio dio = Dio();
    PermissionStatus check = await Permission.storage.status;
    if (!check.isGranted) {
      check = await Permission.storage.request();
    }
    String dirloc = "";
    dirloc = (await getApplicationDocumentsDirectory()).path;
    var randid = Random().nextInt(10000);
    try {
      FileUtils.mkdir([dirloc]);
      await dio.download((widget.snapshot.get("ImageURL")),
          dirloc + randid.toString() + ".jpg",
          onReceiveProgress: (receivedBytes, totalBytes) {
        setState(() {
          downloadingprogress = receivedBytes / totalBytes;
          print(downloadingprogress);
        });
      });
    } catch (e) {
      print(e);
    }

    setState(() {
      path = dirloc + randid.toString() + ".jpg";
      widget.snapshot.reference.update({
        "FilePath2": path,
      });
    });
  }

  downloadFile() {
    setState(() {
      if (!(widget.snapshot.get("Sender") == Constants.userName) &&
          widget.snapshot.get("ImageURL") != '') {
        downloadImage();
      }
    });
  }

  uploadFile() {
    setState(() {
      if ((widget.snapshot.get("Sender") == Constants.userName) &&
          widget.snapshot.get("ImageURL") == '') {
        uploadImage(widget.snapshot.get('FilePath1'));
      }
    });
  }

  uploadImage(String filePath) async {
    Reference reference = FirebaseStorage.instance.ref().child(
        "${widget.chatRoomID}/${Constants.userName}/images/${Path.basename(filePath)}");
    UploadTask uploadTask = reference.putFile(File(filePath));
    uploadTask.snapshotEvents.listen((event) {
      setState(() {
        progress =
            event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
      });
    }).onError((e) {
      print('There is an error : $e');
    });
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() async {
      String downloadURL = await reference.getDownloadURL();
      setState(() {
        widget.snapshot.reference.update({
          "ImageURL": downloadURL,
        });
      });
    });
  }
}
