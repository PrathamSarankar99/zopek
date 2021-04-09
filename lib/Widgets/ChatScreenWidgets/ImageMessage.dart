import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:zopek/Modals/Constants.dart';
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
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    String replyText = replySpecifier(widget.snapshot.get('RepliedTo'));
    Color selectedColor = widget.isSelected
        ? (!(widget.snapshot.get("Sender") == Constants.uid)
            ? Colors.amber.shade300.withOpacity(0.5)
            : Color.fromRGBO(23, 105, 164, 0.5))
        : Colors.transparent;
    print(progress);
    return (widget.snapshot.get("ImageURL") == '' &&
            !(widget.snapshot.get("Sender") == Constants.uid))
        ? Container()
        : Container(
            color: selectedColor,
            child: Hero(
              tag: Path.basename(widget.snapshot.get('FilePath1')),
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
                            child:
                                (widget.snapshot.get("Sender") == Constants.uid)
                                    ? (widget.snapshot.get("ImageURL") != ''
                                        ? postUpload()
                                        : preUpload())
                                    : networkImage(true),
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
                            color: color, width: 2, style: BorderStyle.solid))),
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

  Widget networkImage(bool needLoader) {
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
}
