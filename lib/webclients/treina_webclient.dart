import 'dart:convert';
import 'dart:typed_data';

import 'dart:html';

import 'package:webappexample/models/treina_request.dart';

class TreinaWebClient {
  static void postVideo(String video) async {
    var treinaRequest =
        TreinaRequest(nome: 'Garcia', email: 'garcia@garcia.com', video: video);
    HttpRequest.request('http://localhost:8085/envioTreinamento',
        method: 'POST',
        sendData: jsonEncode(treinaRequest.toJson()),
        requestHeaders: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        }).then((resp) {
      print(resp.responseText);
    });
  }
}
