import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:photo_view/photo_view.dart';

class ImageMessage extends StatelessWidget {
  final String username;
  final String imageURL;
  final bool byme;
  final bool isSelected;
  const ImageMessage(
      {Key key, this.username, this.imageURL, this.byme, this.isSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
                    heroAttributes: PhotoViewHeroAttributes(tag: imageURL),
                    imageProvider: NetworkImage(imageURL),
                  ),
                ),
                type: PageTransitionType.fade));
      },
      child: Hero(
        tag: imageURL,
        child: Container(
          alignment: byme ? Alignment.centerRight : Alignment.centerLeft,
          height: 180,
          color: isSelected
              ? (!byme
                  ? Colors.amber.shade300.withOpacity(0.5)
                  : Color.fromRGBO(23, 105, 164, 0.5))
              : Colors.transparent,
          child: Container(
            margin:
                byme ? EdgeInsets.only(right: 22) : EdgeInsets.only(left: 22),
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(imageURL),
              ),
              color: Colors.pink,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            width: 200,
            height: 170,
          ),
        ),
      ),
    );
  }
}
