import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SingleVideoPlayer extends StatefulWidget {
  final VideoSource source;

  const SingleVideoPlayer({Key key, @required this.source}) : super(key: key);
  @override
  _SingleVideoPlayerState createState() => _SingleVideoPlayerState();
}

class _SingleVideoPlayerState extends State<SingleVideoPlayer>
    with SingleTickerProviderStateMixin {
  VideoPlayerController videoPlayerController;
  AnimationController animationController;
  bool visible = false;
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void pauseAndPlay() async {
    if (animationController.isCompleted) {
      await videoPlayerController.pause();
      setState(() {
        visible = true;
      });
      await animationController.reverse();
    } else {
      await videoPlayerController.play();
      await animationController.forward();
      setState(() {
        visible = false;
      });
    }
  }

  @override
  void initState() {
    switch (widget.source.sourceType) {
      case SourceType.online:
        {
          videoPlayerController =
              VideoPlayerController.network(widget.source.path);
          videoPlayerController.addListener(() => setState(() {}));
          videoPlayerController.initialize().then((_) => setState(() {}));
          videoPlayerController.play();
        }
        break;
      case SourceType.offline:
        {
          videoPlayerController =
              VideoPlayerController.file(File(widget.source.path));
          videoPlayerController.addListener(() => setState(() {}));
          videoPlayerController.initialize().then((_) => setState(() {}));
          videoPlayerController.play();
        }
        break;
    }
    animationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(videoPlayerController),
          TextButton(
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(Size(100, 100)),
              shape: MaterialStateProperty.all(CircleBorder()),
            ),
            child: Visibility(
              visible: visible,
              child: AnimatedIcon(
                icon: AnimatedIcons.play_pause,
                progress: animationController,
                size: 40,
              ),
            ),
            onPressed: () {
              pauseAndPlay();
            },
          ),
          Positioned(
            bottom: height * 0.1,
            left: width * 0.05,
            right: width * 0.05,
            child: VideoProgressIndicator(
              videoPlayerController,
              allowScrubbing: true,
            ),
          ),
        ],
      ),
    );
  }
}

class VideoSource {
  String path;
  SourceType sourceType;
  VideoSource({this.path, this.sourceType});
}

enum SourceType {
  online,
  offline,
}
