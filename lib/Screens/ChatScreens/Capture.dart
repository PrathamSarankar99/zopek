import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class Capture extends StatefulWidget {
  final List<CameraDescription> cameraDescriptions;

  const Capture({
    Key key,
    @required this.cameraDescriptions,
  }) : super(key: key);

  @override
  CaptureState createState() => CaptureState();
}

class CaptureState extends State<Capture> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  bool flashOn;
  @override
  void initState() {
    super.initState();
    flashOn = false;
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.cameraDescriptions.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back),
      // Define the resolution to use.
      ResolutionPreset.ultraHigh,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
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

  void _toggleCameraLens() {
    // get current lens direction (front / rear)
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

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final double mirror =
        _controller.description.lensDirection == CameraLensDirection.front
            ? pi
            : 0;
    return Scaffold(
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Transform(
                    alignment: Alignment.center,
                    child: CameraPreview(_controller),
                    transform: Matrix4.rotationY(mirror)),
                Positioned(
                  bottom: height * 0.05,
                  right: 0,
                  left: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(CircleBorder()),
                          overlayColor: MaterialStateProperty.all(
                              Colors.white.withOpacity(0.3)),
                        ),
                        onPressed: () async {
                          // Take the Picture in a try / catch block. If anything goes wrong,
                          // catch the error.
                          try {
                            // Ensure that the camera is initialized.
                            await _initializeControllerFuture;

                            // Attempt to take a picture and get the file `image`
                            // where it was saved.

                            final image = await _controller.takePicture();

                            // If the picture was taken, display it on a new screen.
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DisplayPictureScreen(
                                  // Pass the automatically generated path to
                                  // the DisplayPictureScreen widget.
                                  height: height,
                                  width: width,
                                  imagePath: image?.path,
                                ),
                              ),
                            ).then((value) => (value != null && value)
                                ? Navigator.pop(context, image.path)
                                : null);
                          } catch (e) {
                            // If an error occurs, log the error to the console.
                            print(e);
                          }
                        },
                        child: Icon(
                          Icons.camera,
                          size: 35,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(CircleBorder()),
                          overlayColor: MaterialStateProperty.all(
                              Colors.white.withOpacity(0.3)),
                        ),
                        onPressed: () {
                          _toggleCameraLens();
                        },
                        child: Icon(
                          Icons.flip_camera_ios_outlined,
                          size: 35,
                          color: Colors.white,
                        ),
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
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final double height;
  final double width;
  const DisplayPictureScreen({Key key, this.imagePath, this.height, this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(imagePath), fit: BoxFit.cover),
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
