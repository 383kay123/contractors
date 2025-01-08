import 'package:apper/home/homepage.dart';

import 'package:flutter/material.dart';

class LoadingToSuccessScreen extends StatefulWidget {
  @override
  _LoadingToSuccessScreenState createState() => _LoadingToSuccessScreenState();
}

class _LoadingToSuccessScreenState extends State<LoadingToSuccessScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  void _simulateLoading() async {
    // Simulate a loading process (replace with actual logic)
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00754B),
      body: Center(
        child: _isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Loading...',
                    style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontFamily: 'Poppins'),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 80),
                  const SizedBox(height: 20),
                  const Text(
                    'Success!',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the next page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage(
                                  contractorName: '',
                                )),
                      );
                    },
                    child: const Text('Continue',
                        style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF00754B),
                            fontFamily: 'Poppins')),
                  ),
                ],
              ),
      ),
    );
  }
}
