import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:zopek/Screens/HomeScreens/Homepage.dart';
import 'package:zopek/Screens/HomeScreens/SearchScreen.dart';

class YourStory extends StatefulWidget {
  @override
  _YourStoryState createState() => _YourStoryState();
}

class _YourStoryState extends State<YourStory> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            PageTransition(
                child: SearchScreen(),
                alignment: Alignment.topCenter,
                childCurrent: Homepage(),
                duration: Duration(milliseconds: 300),
                type: PageTransitionType.fade));
      },
      child: Container(
        padding: EdgeInsets.only(right: 10, left: 10),
        constraints: BoxConstraints(
          minWidth: 100,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              minRadius: 32,
              backgroundColor: Color(0xff444446),
              child: CircleAvatar(
                backgroundColor: Color(0xff444446),
                minRadius: 30,
                child: Icon(
                  Icons.add,
                  color: Colors.white38,
                  size: 30,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Add Friend',
              style: TextStyle(
                color: Color.fromRGBO(203, 201, 201, 1),
                //rgb(203,201,201)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
