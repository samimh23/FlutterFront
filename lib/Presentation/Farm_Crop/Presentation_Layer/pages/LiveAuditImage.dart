import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LiveAuditImage extends StatefulWidget {
  final String imageUrl; // e.g. http://192.168.251.62:8002/latest-image

  const LiveAuditImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  State<LiveAuditImage> createState() => _LiveAuditImageState();
}

class _LiveAuditImageState extends State<LiveAuditImage> {
  Uint8List? _imageBytes;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchImage();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _fetchImage());
  }

  Future<void> _fetchImage() async {
    try {
      final response = await http.get(Uri.parse(widget.imageUrl));
      if (response.statusCode == 200) {
        setState(() {
          _imageBytes = response.bodyBytes;
        });
      }
    } catch (e) {
      // Optionally handle error
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _imageBytes != null
        ? Image.memory(_imageBytes!, width: 250, height: 200, fit: BoxFit.cover)
        : SizedBox(
      width: 250,
      height: 200,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}