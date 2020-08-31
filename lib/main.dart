// ignore: avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html';
import 'dart:js';
import 'dart:typed_data';
import 'dart:io' as io;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:webappexample/webclients/treina_webclient.dart';

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

  VideoPlayerController _controller = VideoPlayerController.network('');

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
                // imagemWidget,
                RaisedButton(
                  onPressed: () => _webcamVideoElement.srcObject.active
                      ? _webcamVideoElement.play()
                      : _webcamVideoElement.pause(),
                  child: Text('Iniciar câmera'),
                ),
                Container(width: 750, height: 750, child: _webcamWidget),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            List<Blob> listaBlob = List();
            var captureStream = _webcamVideoElement.captureStream();
            var mediaRecorder = MediaRecorder(captureStream);
            mediaRecorder.addEventListener('dataavailable', (event) {
              print("datavailable ${event.runtimeType}");
              final Blob blob = JsObject.fromBrowserObject(event)['data'];
              listaBlob.add(blob);
            });
            mediaRecorder.start(5);
            Future.delayed(Duration(seconds: 5), () {
              mediaRecorder.stop();
              var video = Blob(listaBlob);
              print("Blob size: ${video.size}");
              var reader = FileReader();
              reader.onLoad.listen((e) {
                _handleData(reader, context);
              });
              reader.readAsArrayBuffer(video);
            });
            // var track = captureStream.getVideoTracks().first;
            // var imageCapture = ImageCapture(track);
            // var imageBlob = await imageCapture.;
          },
          tooltip: 'Start stream, stop stream',
          child: Icon(Icons.camera_alt),
        ),
      );

  void _handleData(FileReader reader, BuildContext context) {
    // Uint8List uintlist = new Uint8List.fromList(reader.result);
    var encode = base64.encode(reader.result);
    TreinaWebClient.postVideo(encode);
  }
}
