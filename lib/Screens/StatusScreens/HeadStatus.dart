import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:zopek/Services/database.dart';

class HeadStatus extends StatefulWidget {
  final String uid;
  final List<String> sources;
  const HeadStatus({Key key, @required this.uid, @required this.sources})
      : super(key: key);
  @override
  _HeadStatusState createState() => _HeadStatusState();
}

class _HeadStatusState extends State<HeadStatus>
    with SingleTickerProviderStateMixin {
  VideoPlayerController vipC;
  AnimationController animC;

  int pointer = 0;
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    vipC = VideoPlayerController.network(
      widget.sources[pointer],
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
      ),
    );
    super.initState();
    animC = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    vipC.addListener(() => setState(() {}));
    vipC.addListener(playNext);
    vipC.initialize().then((_) => setState(() {}));
    vipC.play();
    animC.forward();
  }

  void playNext() {
    if (pointer + 1 >= widget.sources.length) {
      return;
    }
    if (vipC.value.position == vipC.value.duration) {
      print("Pointers  : Printing the pointer: $pointer");
      setState(() {
        pointer++;
        print("Pointers added $pointer");
        vipC = VideoPlayerController.network(
          widget.sources[pointer],
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true,
          ),
        );
        vipC.addListener(() {
          setState(() {});
        });
        vipC.addListener(() {
          playNext();
        });
        vipC.initialize().then((_) => setState(() {}));
        vipC.play();
      });
    }
  }

  @override
  void dispose() {
    vipC.dispose();
    super.dispose();
  }

  bool visible = true;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    Widget indicators(int index) {
      List<Widget> indicator =
          List.generate(widget.sources.length, (currentindex) {
        return Container(
          width: width / widget.sources.length,
          height: height * 0.1,
          child: VideoProgressIndicator(
            vipC,
            padding: EdgeInsets.only(right: 2, left: 2),
            allowScrubbing: false,
            colors: VideoProgressColors(
              backgroundColor: currentindex == index
                  ? Colors.grey
                  : Colors.grey.withOpacity(0.7),
              bufferedColor:
                  currentindex == index ? Colors.grey : Colors.transparent,
              playedColor:
                  currentindex == index ? Colors.white : Colors.transparent,
            ),
          ),
        );
      });
      return Row(
        children: indicator,
      );
    }

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
          stream: DataBaseServices.getUserByID(widget.uid),
          builder: (context, snapshot) {
            return Stack(
              children: [
                Container(
                  color: Colors.blue,
                ),
                VideoPlayer(vipC),
                Positioned(
                    height: width * 0.01,
                    width: width,
                    top: MediaQuery.of(context).padding.top,
                    child: indicators(pointer)),
                Positioned(
                    bottom: 0,
                    top: 0,
                    right: 0,
                    left: 0,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) async {
                        Duration currenDuration = await vipC.position;
                        print(details.delta.distance);
                        vipC.seekTo(Duration(
                            milliseconds: (currenDuration.inMilliseconds +
                                    ((details.delta.dx) * 10))
                                .toInt()));
                        await vipC.pause();
                        await vipC.play();
                      },
                      onTap: () {
                        pauseAndPlay();
                      },
                      onDoubleTap: () {
                        print("Double tapped");
                      },
                      child: Container(
                        color: Colors.transparent,
                      ),
                    )),
                Container(
                    alignment: Alignment.center,
                    child: TextButton(
                        style: ButtonStyle(
                          // shadowColor: MaterialStateProperty.all(Colors.cyan),
                          overlayColor: MaterialStateProperty.all(
                              Colors.cyan.shade100.withOpacity(0.2)),
                          // foregroundColor: MaterialStateProperty.all(Colors.cyan),
                          minimumSize: MaterialStateProperty.all(
                              Size(width * 0.3, width * 0.3)),
                          shape: MaterialStateProperty.all(CircleBorder()),
                        ),
                        onPressed: () async {
                          print("Printing ${animC.isCompleted}");
                          pauseAndPlay();
                        },
                        child: AnimatedIcon(
                            icon: AnimatedIcons.play_pause,
                            progress: animC,
                            size: width * 0.15,
                            color: visible
                                ? Colors.transparent
                                : Colors.cyan.shade100))),
                Positioned(
                  top: MediaQuery.of(context).padding.top + width * 0.01,
                  left: width * 0.02,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        CircleAvatar(
                          minRadius: width * 0.06,
                          backgroundImage: snapshot.hasData
                              ? NetworkImage(snapshot.data.get("PhotoURL"))
                              : null,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width * 0.03),
                          child: Text(
                            snapshot.hasData
                                ? snapshot.data.get("UserName")
                                : "",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: width * 0.05,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width * 0.02),
                          child: Text(
                            "2h",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w400,
                              fontSize: width * 0.05,
                            ),
                          ),
                        ),
                      ]),
                      TextButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(CircleBorder()),
                            minimumSize: MaterialStateProperty.all(
                                Size(width * 0.18, width * 0.18)),
                            overlayColor: MaterialStateProperty.all(
                                Colors.white.withOpacity(0.2))),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.clear,
                            color: Colors.white, size: width * 0.08),
                      )
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }

  void pauseAndPlay() async {
    if (animC.isCompleted) {
      await vipC.pause();
      setState(() {
        visible = false;
      });
      await animC.reverse();
    } else {
      await vipC.play();
      await animC.forward();
      setState(() {
        visible = true;
      });
    }
  }
}
