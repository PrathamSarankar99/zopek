import 'package:flutter/material.dart';

class StatusWidget extends StatefulWidget {
  final String username;
  final String photoURL;
  final Color color;

  const StatusWidget(
      {Key key,
      @required this.username,
      @required this.photoURL,
      @required this.color})
      : super(key: key);
  @override
  _StatusWidgetState createState() => _StatusWidgetState();
}

class _StatusWidgetState extends State<StatusWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 10, left: 10),
      constraints: BoxConstraints(
        minWidth: 100,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
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
              minRadius: 33,
              backgroundColor: Colors.black.withBlue(40),
              child: CircleAvatar(
                minRadius: 30,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(widget.photoURL),
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
