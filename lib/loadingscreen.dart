import 'package:apper/viewfarmer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Simulate a data-loading or initialization process
  Future<void> _loadData() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate a 2-second delay
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ViewFarmersPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00754B),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpinKitDualRing(
              color: Colors.white,
              size: 70.0,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
