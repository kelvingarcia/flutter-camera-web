// ignore: avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';
import 'dart:io' as io;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(WebcamApp());

class WebcamApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: WebcamPage(),
      );
}

class WebcamPage extends StatefulWidget {
  @override
  _WebcamPageState createState() => _WebcamPageState();
}

class _WebcamPageState extends State<WebcamPage> {
  // Webcam widget to insert into the tree
  Widget _webcamWidget;
  // VideoElement
  VideoElement _webcamVideoElement;

  final ImagePicker picker = ImagePicker();

  Widget imagemWidget = Container();

  @override
  void initState() {
    super.initState();
    // Create a video element which will be provided with stream source
    _webcamVideoElement = VideoElement();
    // Register an webcam
    ui.platformViewRegistry.registerViewFactory(
        'webcamVideoElement', (int viewId) => _webcamVideoElement);
    // Create video widget
    _webcamWidget =
        HtmlElementView(key: UniqueKey(), viewType: 'webcamVideoElement');
    // Access the webcam stream
    window.navigator.getUserMedia(video: true).then((MediaStream stream) {
      _webcamVideoElement.srcObject = stream;
    });
    _webcamVideoElement.play();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Webcam MediaStream:',
                  style: TextStyle(fontSize: 30, fontStyle: FontStyle.italic),
                ),
                imagemWidget,
                Container(width: 750, height: 750, child: _webcamWidget),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var captureStream = _webcamVideoElement.captureStream();
            var track = captureStream.getVideoTracks().first;
            var imageCapture = ImageCapture(track);
            var imageBlob = await imageCapture.takePhoto();
            var reader = FileReader();
            reader.onLoad.listen((e) {
              _handleData(reader);
            });
            reader.readAsArrayBuffer(imageBlob);
          },
          tooltip: 'Start stream, stop stream',
          child: Icon(Icons.camera_alt),
        ),
      );

  void _handleData(FileReader reader) {
    Uint8List uintlist = new Uint8List.fromList(reader.result);
    setState(() {
      imagemWidget = Container(
        child: Image.memory(uintlist),
      );
    });
  }
}
