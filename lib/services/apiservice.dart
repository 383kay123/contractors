import 'dart:convert';
import 'package:apper/auth/login_controller.dart';
import 'package:apper/model/farmer_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ApiService {
  final String apiUrl =
      'http://192.168.100.56:8000/api/'; // Base URL for the API
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
    print("Initializing database at path: $path");
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  static const String tableName = 'farmers';

  // Create tables for SQLite
  Future _createDB(Database db, int version) async {
    print("Creating farmers table...");
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        date_of_birth TEXT NOT NULL,
        gender TEXT NOT NULL,
        contact_number TEXT NOT NULL,
        email TEXT NOT NULL,
        address TEXT NOT NULL,
        photo TEXT NOT NULL
      )
    ''');
    print("Farmers table created successfully.");
  }

  // Function to handle user login
  Future<bool> login(String username, String password) async {
    try {
      print("Attempting login for user: $username");
      final response = await http.post(
        Uri.parse('${apiUrl}login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Login successful: ${data['username']}');
        loginController.username.value = data['username'];
        return true;
      } else {
        print('Login failed with response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  }

  // Function to handle user signup
  Future<Map<String, dynamic>> signup(String email, String password) async {
    try {
      print("Attempting signup with email: $email");
      final response = await http.post(
        Uri.parse('${apiUrl}contractors/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        print("Signup successful.");
        return json.decode(response.body);
      } else {
        print("Signup failed with status: ${response.statusCode}");
        throw Exception('Failed to signup');
      }
    } catch (e) {
      print('Error during signup: $e');
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
    String imagePath,
  ) async {
    try {
      print("Registering farmer: $fullName");
      final uri = Uri.parse('${apiUrl}register/farmer/');
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
        print("Image added to the request.");
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        print("Farmer registration successful.");
        final responseString = await response.stream.bytesToString();
        final responseData = jsonDecode(responseString);

        // Save farmer data to local database (passing a single farmer object)
        saveFarmersToDatabase([responseData]);

        // Also save to SharedPreferences
        await saveFarmerToPrefs(responseData);

        return {'success': true, 'message': 'Farmer registered successfully'};
      } else {
        final responseString = await response.stream.bytesToString();
        print('Registration failed. Status: ${response.statusCode}');
        print('Response: $responseString');
        return {
          'success': false,
          'message': jsonDecode(responseString)['message']
        };
      }
    } catch (e) {
      print("Error during farmer registration: $e");
      return {
        'success': false,
        'message': 'Error occurred: $e',
      };
    }
  }

  // Function to fetch farmers (online & offline)
  Future<List<Farmer>> getFarmers() async {
    try {
      // Check connectivity status
      var connectivityResult = await (Connectivity().checkConnectivity());
      print('Connectivity result: $connectivityResult');

      if (connectivityResult == ConnectivityResult.none) {
        print(
            'No internet connection. Fetching farmers from local database...');
        // Fetch farmers from SQLite database
        final dbFarmers = await getFarmersFromDatabase();
        return dbFarmers.map((map) => Farmer.fromMap(map)).toList();
      } else {
        // Fetch farmers from API
        final response = await http.get(
          Uri.parse('${apiUrl}farmers/'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          print('Farmers fetched from API: $data');

          String baseUrl = 'http://192.168.100.56:8000/';
          List<Farmer> farmers = data.map((farmerData) {
            if (farmerData['photo'] == null ||
                farmerData['photo'].toString().isEmpty) {
              farmerData['photo'] = 'assets/images/user1.png';
            } else if (farmerData['photo'].toString().startsWith('/media/')) {
              farmerData['photo'] = '$baseUrl${farmerData['photo']}';
            }
            return Farmer.fromMap(farmerData);
          }).toList();

          // Save to SQLite database for offline use
          saveFarmersToDatabase(
              farmers.map((farmer) => farmer.toMap()).toList());

          return farmers;
        } else {
          print('Failed to fetch farmers from API: ${response.body}');
          return [];
        }
      }
    } catch (e) {
      print('Error fetching farmers: $e');
      return [];
    }
  }

  // Save farmer data to local SQLite database
  Future<void> saveFarmersToDatabase(List<Map<String, dynamic>> farmers) async {
    final db = await database;
    for (var farmer in farmers) {
      await db.insert(
        ApiService.tableName,
        farmer,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    print('Farmers saved to database.');
  }

  // Fetch farmer data from local SQLite database
  Future<List<Map<String, dynamic>>> getFarmersFromDatabase() async {
    final db = await database;
    final farmers = await db.query(ApiService.tableName);
    print('Farmers from SQLite: $farmers');
    return farmers;
  }

  Future<void> saveFarmerToPrefs(Map<String, dynamic> farmerData) async {
    final prefs = await SharedPreferences.getInstance();
    final farmersJson = prefs.getString('farmers') ?? '[]';
    List<dynamic> farmers = jsonDecode(farmersJson);
    farmers.add(farmerData);
    await prefs.setString('farmers', jsonEncode(farmers));
  }

  // Method to get all farmers from SharedPreferences
  Future<List<dynamic>> getFarmersFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final farmersJson = prefs.getString('farmers') ?? '[]';
    return jsonDecode(farmersJson);
  }

  Future<void> testFarmerStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final farmersJson = prefs.getString('farmers') ?? '[]';
    print('Stored Farmers: $farmersJson');
  }

  // Reporting
  Future<Map<String, dynamic>> createReport(
      Map<String, dynamic> reportData) async {
    final url = Uri.parse('${apiUrl}reports/'); // Ensure API URL is correct

    try {
      // ✅ Print the exact JSON data being sent
      String jsonData = jsonEncode(reportData);
      print('Sending JSON data: $jsonData');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // ✅ Ensure API expects JSON response
        },
        body: jsonData, // ✅ Ensure JSON encoding
      );

      // ✅ Print the full response body for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return jsonDecode(
            response.body); // ✅ Return parsed response if successful
      } else {
        return {
          'error':
              'Failed to create report. Server returned status code: ${response.statusCode}',
          'details': response.body, // ✅ Include error details
        };
      }
    } catch (error) {
      print('Request error: $error'); // ✅ Print errors if network request fails
      return {'error': 'Something went wrong: $error'};
    }
  }
}
