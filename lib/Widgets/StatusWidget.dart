import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:zopek/Screens/StatusScreens/HeadStatus.dart';

class StatusWidget extends StatefulWidget {
  final String username;
  final String photoURL;
  final String uid;
  final Color color;

  const StatusWidget(
      {Key key,
      @required this.username,
      @required this.photoURL,
      @required this.color,
      @required this.uid})
      : super(key: key);
  @override
  _StatusWidgetState createState() => _StatusWidgetState();
}

class _StatusWidgetState extends State<StatusWidget> {
  double factor = 0.1;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.only(right: 10, left: 10),
      constraints: BoxConstraints(
        minWidth: 100,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onLongPress: () {
              print("Long pressed");
            },
            onTapDown: (details) {
              print("Down ${details.localPosition}");
              setState(() {
                factor = 0.09;
              });
            },
            onTapCancel: () {
              print("Canceled");
              setState(() {
                factor = 0.1;
              });
            },
            onTapUp: (details) {
              print("Up ${details.localPosition}");
              setState(() {
                factor = 0.1;
              });
              Navigator.push(
                  context,
                  PageTransition(
                      child: HeadStatus(
                        sources: [
                          "https://firebasestorage.googleapis.com/v0/b/zopek-de839.appspot.com/o/1stVideo.mp4?alt=media&token=c6f78921-1333-4a46-a1f8-06b7d5403ca4",
                          "https://firebasestorage.googleapis.com/v0/b/zopek-de839.appspot.com/o/2ndVideo.mp4?alt=media&token=a5b4e523-384f-4f36-8869-7485b08297bd",
                          "https://firebasestorage.googleapis.com/v0/b/zopek-de839.appspot.com/o/3rdVideo.mp4?alt=media&token=778fcda3-8159-4b46-89a5-74faed0ad69a",
                          "https://firebasestorage.googleapis.com/v0/b/zopek-de839.appspot.com/o/2ndVideo.mp4?alt=media&token=a5b4e523-384f-4f36-8869-7485b08297bd",
                        ],
                        uid: widget.uid,
                      ),
                      type: PageTransitionType.fade));
            },
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      end: Alignment.topRight,
                      colors: [
                        Color.fromRGBO(163, 197, 242, 1),
                        Color.fromRGBO(41, 192, 179, 1),
                        Color.fromRGBO(18, 232, 109, 1),
                      ])),
              child: CircleAvatar(
                minRadius: width * factor,
                backgroundColor: Colors.black.withBlue(40),
                child: CircleAvatar(
                  minRadius: width * factor - 3,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(widget.photoURL),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            widget.username,
            style: TextStyle(
              color: Color.fromRGBO(203, 201, 201, 1),
              //rgb(203,201,201)
            ),
          ),
        ],
      ),
    );
  }
}
