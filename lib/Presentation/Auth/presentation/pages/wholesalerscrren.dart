import 'package:flutter/material.dart';

class WholesalerScreen extends StatefulWidget {
  const WholesalerScreen({Key? key}) : super(key: key);

  @override
  State<WholesalerScreen> createState() => _WholesalerScreenState();
}

class _WholesalerScreenState extends State<WholesalerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wholesaler Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.store, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Welcome to the Wholesaler Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Manage your inventory and connect with farmers and clients',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}