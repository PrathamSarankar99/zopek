import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:video_player/video_player.dart';
import 'package:zopek/Modals/revert.dart';
import 'package:zopek/Widgets/CameraScreenWidgets/BlinkingButton.dart';

class Capture extends StatefulWidget {
  final List<CameraDescription> cameraDescriptions;

  const Capture({
    Key key,
    @required this.cameraDescriptions,
  }) : super(key: key);

  @override
  CaptureState createState() => CaptureState();
}

class CaptureState extends State<Capture> with SingleTickerProviderStateMixin {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  AnimationController videoRecorderIndicator;
  int reconds; // Recorded Seconds
  bool flashOn;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    reconds = -1;
    flashOn = false;
    videoRecorderIndicator = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    videoRecorderIndicator.repeat();
    // To display the current output from the Camera,
    // create a CameraController
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.cameraDescriptions.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back),
      // Define the resolution to use.
      ResolutionPreset.ultraHigh,
      enableAudio: true,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    videoRecorderIndicator.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initCamera(CameraDescription description) async {
    _controller = CameraController(description, ResolutionPreset.ultraHigh,
        enableAudio: true);

    try {
      await _controller.initialize();
      // to notify the widgets that camera has been initialized and now camera preview can be done
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  double factor = 0.20;
  Color splashColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  onDoubleTap: () {
                    ToggleCameraLens();
                  },
                  child: _controller.buildPreview(),
                ),
                Visibility(
                  visible: _controller.value.isRecordingVideo,
                  child: Positioned(
                      top: height * 0.08,
                      left: width * 0.05,
                      child: Row(
                        children: [
                          BlinkingButton(),
                          Text(
                            "  REC",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      )),
                ),
                Visibility(
                  visible: _controller.value.isRecordingVideo,
                  child: Positioned(
                    bottom: height * 0.19,
                    right: 0,
                    left: 0,
                    child: Center(
                        child: Text(FormatSeconds(reconds),
                            style: TextStyle(
                              color: Colors.redAccent,
                            ))),
                  ),
                ),
                Positioned(
                  bottom: height * 0.03,
                  right: 0,
                  left: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(height: width * 0.35, width: width * 0.1),
                      TextButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(CircleBorder()),
                            overlayColor: MaterialStateProperty.all(
                                Colors.white.withOpacity(0.3)),
                            minimumSize: MaterialStateProperty.all(
                                Size(width * 0.15, width * 0.15))),
                        onPressed: () {
                          if (_controller.value.isRecordingVideo) {
                            if (_controller.value.isRecordingPaused) {
                              _controller.resumeVideoRecording();
                            } else {
                              _controller.pauseVideoRecording();
                            }
                          } else {
                            ToggleCameraLens();
                          }
                        },
                        child: _controller.value.isRecordingVideo
                            ? (_controller.value.isRecordingPaused
                                ? Icon(
                                    Icons.play_arrow_rounded,
                                    size: 35,
                                    color: Colors.white,
                                  )
                                : Icon(
                                    Icons.pause,
                                    size: 35,
                                    color: Colors.white,
                                  ))
                            : Icon(
                                Icons.flip_camera_android,
                                size: 35,
                                color: Colors.white,
                              ),
                      ),
                      Container(height: width * 0.35, width: width * 0.1),
                      Container(
                        width: width * 0.3,
                        height: width * 0.3,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedContainer(
                              curve: Curves.elasticInOut,
                              duration: Duration(milliseconds: 1000),
                              width: width * factor,
                              height: width * factor,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                                value: factor == 0.20 ? 0 : null,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (_controller.value.isRecordingVideo) {
                                  EndVideoRecording();
                                } else {
                                  CapturePhoto();
                                }
                              },
                              onTapDown: (details) {
                                Toggle(Tap.down);
                              },
                              onTapUp: (details) {
                                Toggle(Tap.up);
                              },
                              onLongPressStart: (details) {
                                setState(() {
                                  reconds = -1;
                                });
                                Listen();
                                StartVideoRecording();
                              },
                              onLongPressUp: () {},
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 100),
                                width: width *
                                    ((factor == 0.2 ? 0.37 : 0.44) - factor),
                                height: width *
                                    ((factor == 0.2 ? 0.37 : 0.44) - factor),
                                decoration: BoxDecoration(
                                  color:
                                      factor == 0.20 ? splashColor : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(height: width * 0.35, width: width * 0.1),
                      TextButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(CircleBorder()),
                            overlayColor: MaterialStateProperty.all(
                                Colors.white.withOpacity(0.3)),
                            minimumSize: MaterialStateProperty.all(
                                Size(width * 0.15, width * 0.15))),
                        onPressed: () {},
                        child: Icon(
                          Icons.photo_library_outlined,
                          size: 35,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        height: width * 0.35,
                        width: width * 0.1,
                      ),
                    ],
                  ),
                )
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  // ignore: non_constant_identifier_names

  // ignore: non_constant_identifier_names
  void Toggle(Tap tap) {
    switch (tap) {
      case Tap.down:
        setState(() {
          splashColor = Colors.red;
        });
        break;
      case Tap.up:
        setState(() {
          splashColor = Colors.white;
        });
        break;
    }
  }

  void Listen() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (!_controller.value.isRecordingPaused) {
          reconds++;
        }
      });
      if (!_controller.value.isRecordingVideo) {
        timer.cancel();
      }
    });
  }

  // ignore: non_constant_identifier_names
  void ToggleCameraLens() {
    // get current lens direction (front / rear)
    if (_controller.value.isRecordingVideo) {
      Fluttertoast.showToast(
          msg: "Recording is on!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blueAccent[400],
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    final lensDirection = _controller.description.lensDirection;
    CameraDescription newDescription;
    if (lensDirection == CameraLensDirection.front) {
      newDescription = widget.cameraDescriptions.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.back);
    } else {
      newDescription = widget.cameraDescriptions.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.front);
    }

    if (newDescription != null) {
      _initCamera(newDescription);
    } else {
      print('Asked camera not available');
    }
  }

  // ignore: non_constant_identifier_names
  StartVideoRecording() {
    setState(() {
      factor = 0.27;
    });
    _controller.prepareForVideoRecording().then((value) {
      if (!_controller.value.isRecordingVideo) {
        print("Recording started");
        _controller.startVideoRecording();
      }
    });
    print("Tap down");
  }

  // ignore: non_constant_identifier_names
  String FormatSeconds(int value) {
    var minutes = (value / 60).round().toString().padLeft(2, '0');
    var seconds = (value % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // ignore: non_constant_identifier_names
  EndVideoRecording() async {
    setState(() {
      factor = 0.20;
      splashColor = Colors.white;

      print("Tap up");
    });
    if (_controller.value.isRecordingVideo) {
      await _controller.stopVideoRecording().then((value) {
        Navigator.push(
            context,
            PageTransition(
              child: Displayer(
                videoPath: value.path,
              ),
              type: PageTransitionType.fade,
            )).then(
          (boolean) => (boolean != null && boolean)
              ? Navigator.pop(
                  context,
                  Revert(
                    media: Media.video,
                    path: value.path,
                  ),
                )
              : null,
        );
      });
    }
    setState(() {
      reconds = -1;
    });
  }

  // ignore: non_constant_identifier_names
  CapturePhoto() async {
    // Take the Picture in a try / catch block. If anything goes wrong,
    // catch the error.
    try {
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;

      // Attempt to take a picture and get the file `image`
      // where it was saved.
      if (!_controller.value.isTakingPicture) {
        final image = await _controller.takePicture();
        // If the picture was taken, display it on a new screen.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Displayer(
              // Pass the automatically generated path to
              // the DisplayPictureScreen widget.
              imagePath: image?.path,
            ),
          ),
        ).then(
          (value) => (value != null && value)
              ? Navigator.pop(
                  context,
                  Revert(
                    media: Media.image,
                    path: image?.path,
                  ),
                )
              : null,
        );
      }
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
  }
}

enum Tap { down, up }

// A widget that displays the picture taken by the user.
class Displayer extends StatefulWidget {
  final String imagePath;
  final String videoPath;

  const Displayer({Key key, this.imagePath, this.videoPath}) : super(key: key);

  @override
  _DisplayerState createState() => _DisplayerState();
}

class _DisplayerState extends State<Displayer> {
  VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    if (widget.videoPath != null) {
      controller = VideoPlayerController.file(File(widget.videoPath));
      controller.addListener(() {
        setState(() {});
      });
      controller.initialize().then((_) => setState(() {}));
      controller.play();
    }
  }

  @override
  void dispose() {
    if (widget.videoPath != null) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          (widget.videoPath != null ? VideoPlayer(controller) : Container()),
          (widget.videoPath != null
              ? Positioned(
                  bottom: 0,
                  width: width,
                  height: height * 0.1,
                  child: VideoProgressIndicator(
                    controller,
                    allowScrubbing: true,
                  ),
                )
              : Container(
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.fill,
                  ),
                )),
          Positioned(
            child: TextButton(
              style: ButtonStyle(
                  overlayColor:
                      MaterialStateProperty.all(Colors.white.withOpacity(0.3)),
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                  minimumSize: MaterialStateProperty.all(Size(60, 60)),
                  shape: MaterialStateProperty.all(CircleBorder(
                      side: BorderSide(
                    color: Colors.blue,
                  )))),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 35,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            bottom: height * 0.05,
            right: width * 0.425,
          )
        ],
      ),
    );
  }
}
