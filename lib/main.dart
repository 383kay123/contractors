import 'package:apper/auth/login_page.dart';
import 'package:apper/home/homepage.dart';
import 'package:apper/loadingscreen.dart';
import 'package:apper/registerfarmer.dart';
import 'package:apper/report_activity.dart';
import 'package:apper/services/database_helper.dart';
import 'package:apper/splash_screen';
import 'package:apper/viewfarmer.dart';

import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = FarmerDatabaseHelper.instance;
  await dbHelper.printTableSchema();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(contractorName: 'Edward'),
        '/registerFarmer': (context) => const RegisterFarmerPage(),
        '/viewFarmers': (context) => const ViewFarmersPage(),
        '/loading': (context) => LoadingPage(),
      },
    );
  }
}
