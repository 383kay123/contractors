import 'dart:convert';

import 'package:apper/home/auth/login_controller.dart';
import 'package:apper/model/farmer_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ApiService {
  final String apiUrl =
      'http://192.168.3.140:8000/api/'; // Base URL for the API
  final loginController = Get.put(LoginController());

  // SQLite instance
  Database? _database;

  // Function to get the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'contractor_farmers.db');
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Create tables for SQLite
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE farmers (
        id INTEGER PRIMARY KEY,
        full_name TEXT NOT NULL,
        date_of_birth TEXT NOT NULL,
        gender TEXT NOT NULL,
        contact_number TEXT NOT NULL,
        email TEXT NOT NULL,
        address TEXT NOT NULL,
        photo TEXT NOT NULL
      )
    ''');
  }

  // Function to handle user login
  // Function to handle user login
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${apiUrl}login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Login successful: ${data['username']}');
        loginController.username.value = data['username'];
        return true; // Login successful
      } else {
        print('Login failed: ${response.body}');
        return false; // Login failed
      }
    } catch (e) {
      print('Error logging in: $e');
      return false;
    }
  }

  // Function to handle user signup
  Future<Map<String, dynamic>> signup(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${apiUrl}contractors/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to signup');
      }
    } catch (e) {
      throw Exception('Failed to connect to API: $e');
    }
  }

  // Function to register a farmer (includes offline storage)
  Future<Map<String, dynamic>> registerFarmer(
      String fullName,
      String dateOfBirth,
      String gender,
      String contactNumber,
      String email,
      String address,
      String imagePath) async {
    try {
      final uri = Uri.parse('${apiUrl}farmers/');
      var request = http.MultipartRequest('POST', uri);

      // Add form fields
      request.fields['full_name'] = fullName;
      request.fields['date_of_birth'] = dateOfBirth;
      request.fields['gender'] = gender;
      request.fields['contact_number'] = contactNumber;
      request.fields['email'] = email;
      request.fields['address'] = address;

      // Add image file if selected
      if (imagePath.isNotEmpty) {
        var imageFile = await http.MultipartFile.fromPath('photo', imagePath);
        request.files.add(imageFile);
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        // Save to SQLite for offline use
        final responseString = await response.stream.bytesToString();
        final responseData = jsonDecode(responseString);
        _saveFarmerToDatabase(responseData);

        return {'success': true, 'message': 'Farmer registered successfully'};
      } else {
        final responseString = await response.stream.bytesToString();
        return {
          'success': false,
          'message': jsonDecode(responseString)['message']
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error occurred: $e',
      };
    }
  }

  // Function to fetch farmers (online & offline)
  Future<List<Farmer>> getFarmers() async {
    try {
      // Check if the device has internet connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult == ConnectivityResult.none) {
        // If no internet, fetch farmers from the local SQLite database
        print(
            'No internet connection. Fetching farmers from local database...');
        final farmersFromDb = await getFarmersFromDatabase();
        // Convert the list of maps into Farmer objects
        return farmersFromDb.map((e) => Farmer.fromMap(e)).toList();
      } else {
        // If internet is available, fetch farmers from the API
        final response = await http.get(
          Uri.parse('${apiUrl}farmers/'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);

          // Save fetched farmers to local database for offline usage
          await _saveFarmerToDatabase(
            data.map((item) => Farmer.fromMap(item)) as Map<String, dynamic>,
          );

          // Return the fetched farmers as Farmer objects
          return data.map((item) => Farmer.fromMap(item)).toList();
        } else {
          print('Failed to fetch farmers: ${response.body}');
          return [];
        }
      }
    } catch (e) {
      print('Error fetching farmers: $e');
      return [];
    }
  }

  // Save farmer data to local SQLite database
  Future<void> _saveFarmerToDatabase(Map<String, dynamic> farmerData) async {
    final db = await database;
    await db.insert(
      'farmers',
      farmerData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("Farmer saved locally.");
  }

  // Fetch farmer data from local SQLite database (offline access)
  Future<List<Map<String, dynamic>>> getFarmersFromDatabase() async {
    final db = await database;
    final List<Map<String, dynamic>> farmers = await db.query('farmers');
    return farmers;
  }
}
