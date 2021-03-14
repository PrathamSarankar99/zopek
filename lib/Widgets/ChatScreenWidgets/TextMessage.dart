import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:linkable/linkable.dart';
import 'package:zopek/Services/Constants.dart';

class TextMessage extends StatefulWidget {
  final bool isSelected;
  final bool byme;
  final int messagesLength;
  final int index;
  final String repliedToSender;
  final String repliedToMessage;
  final String repliedToImageURL;
  final String message;
  final VoidCallback scrollToIndex;
  final Timestamp timestamp;
  const TextMessage(
      {Key key,
      this.scrollToIndex,
      this.timestamp,
      this.message,
      this.repliedToMessage,
      this.isSelected,
      this.byme,
      this.messagesLength,
      this.index,
      this.repliedToSender,
      this.repliedToImageURL})
      : super(key: key);

  @override
  _TextMessageState createState() => _TextMessageState();
}

class _TextMessageState extends State<TextMessage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: widget.isSelected
            ? (!widget.byme
                ? Colors.amber.shade300.withOpacity(0.5)
                : Color.fromRGBO(23, 105, 164, 0.5))
            : Colors.transparent,
        borderRadius: widget.index == widget.messagesLength - 1
            ? BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              )
            : BorderRadius.zero,
      ),
      child: Container(
          padding: EdgeInsets.only(top: 3, bottom: 3),
          color: Colors.transparent,
          margin: widget.byme
              ? EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.20,
                  right: 22,
                )
              : EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.20,
                  left: 22,
                ),
          alignment: widget.byme ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment:
                widget.byme ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: widget.repliedToSender != "",
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  color: Colors.transparent,
                  child: Text(widget.repliedToSender == Constants.userName
                      ? (widget.byme ? "Replied to yourself" : "Replied to you")
                      : (widget.byme ? "You replied" : "Replied to themself")),
                ),
              ),
              GestureDetector(
                onTap: widget.scrollToIndex,
                child: Visibility(
                    visible: widget.repliedToMessage != "" ||
                        widget.repliedToImageURL != "",
                    child: Container(
                      padding: widget.byme
                          ? EdgeInsets.only(right: 10)
                          : EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        border: widget.byme
                            ? Border(
                                right: BorderSide(
                                color: (widget.repliedToSender !=
                                        Constants.userName
                                    ? Colors.amber.shade300.withOpacity(0.8)
                                    : Color.fromRGBO(23, 105, 164, 0.8)),
                                width: 2,
                              ))
                            : Border(
                                left: BorderSide(
                                color: (widget.repliedToSender !=
                                        Constants.userName
                                    ? Colors.amber.shade300.withOpacity(0.8)
                                    : Color.fromRGBO(23, 105, 164, 0.8)),
                                width: 2,
                              )),
                        color: Colors.transparent,
                      ),
                      child: Container(
                          padding: widget.repliedToImageURL == ""
                              ? EdgeInsets.all(10)
                              : null,
                          decoration: BoxDecoration(
                            color: widget.byme
                                //rgb(255,72,56)
                                ? (widget.repliedToSender != Constants.userName
                                    ? Colors.amber.shade300.withOpacity(0.8)
                                    : Color.fromRGBO(23, 105, 164, 0.8))
                                : (widget.repliedToSender == Constants.userName
                                    ? Color.fromRGBO(23, 105, 164, 0.8)
                                    : Colors.amber.shade300.withOpacity(0.6)),
                            borderRadius: widget.repliedToImageURL == ""
                                ? BorderRadius.all(Radius.circular(30))
                                : BorderRadius.all(Radius.circular(15)),
                          ),
                          child: widget.repliedToImageURL != ""
                              ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                        strokeWidth: 1.5,
                                      ),
                                    ),
                                    Container(
                                      height: 60,
                                      width: 70,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                        child: Image.network(
                                          widget.repliedToImageURL,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  widget.repliedToMessage,
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.6),
                                  ),
                                )),
                    )),
              ),
              SizedBox(
                height: 3,
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: widget.byme
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
                    color: widget.byme
                        ? Color.fromRGBO(23, 105, 164, 1)
                        : Colors.amber.shade300),

                padding:
                    EdgeInsets.only(top: 15, left: 15, bottom: 5, right: 5),
                //rgb(216,242,255)
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: widget.byme
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: widget.byme
                          ? EdgeInsets.only(right: 10)
                          : EdgeInsets.only(right: 10),
                      child: Linkable(
                        linkColor: Colors.white,
                        textColor: Colors.black.withOpacity(0.8),
                        text: widget.message,
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
                      alignment: widget.byme
                          ? Alignment.bottomRight
                          : Alignment.bottomLeft,
                      height: 12,
                      width: 40,
                      color: Colors.transparent,
                      child: Text(
                        getTimeForMessageTile(widget.timestamp),
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
    );
  }

  String getTimeForMessageTile(Timestamp timeStamp) {
    DateTime time = timeStamp.toDate();
    String formatted =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    return formatted;
  }
}
