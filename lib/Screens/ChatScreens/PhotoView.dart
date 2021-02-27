import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart' as photo;

class PhotoView extends StatefulWidget {
  final String url;

  const PhotoView({Key key, this.url}) : super(key: key);
  @override
  _PhotoViewState createState() => _PhotoViewState();
}

class _PhotoViewState extends State<PhotoView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: photo.PhotoView(
        imageProvider: NetworkImage(widget.url),
      ),
    );
  }
}
