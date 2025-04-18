// Stub file for non-web platforms
// This file provides empty implementations of the html library classes
// to avoid compile errors on mobile platforms

class AnchorElement {
  AnchorElement({String? href});
  String? href;
}

class Blob {}

class File {
  String get name => '';
  String get type => 'image/jpeg';
  dynamic get size => 0;
}

class FileReader {
  dynamic result;
  Stream<dynamic> get onLoad => const Stream.empty();
  Stream<dynamic> get onError => const Stream.empty();
  void readAsArrayBuffer(dynamic blob) {}
}

class HttpRequest {
  int status = 0;
  String statusText = '';
  dynamic response;
  String responseType = '';

  void open(String method, String url, {bool async = false}) {}
  void send() {}

  Stream<dynamic> get onLoad => const Stream.empty();
  Stream<dynamic> get onError => const Stream.empty();
}

class Window {
  Map<String, dynamic> sessionStorage = {};
}

Window window = Window();