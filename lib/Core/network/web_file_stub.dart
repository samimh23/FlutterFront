// lib/Core/network/web_file_stub.dart
class File {
  final String path;

  File(this.path);

  Future<int> length() async {
    return 0; // Mock implementation for web
  }

  int lengthSync() {
    return 0; // Mock implementation for web
  }
}