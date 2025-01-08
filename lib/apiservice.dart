import 'dart:convert';
import 'package:apper/home/auth/login_controller.dart';

import 'package:http/http.dart' as http; // Import http package
import 'package:get/get.dart';

class ApiService {
  final String apiUrl = 'http://192.168.100.56:8000/api/'; // Set the base URL

  final loginController = Get.put(LoginController());

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

  // Function to register the farmer
  Future<Map<String, dynamic>> registerFarmer(
      String fullName,
      String dateOfBirth,
      String gender,
      String contactNumber,
      String email,
      String address,
      String imagePath) async {
    try {
      final uri = Uri.parse('${apiUrl}register/farmer/');

      var request = http.MultipartRequest('POST', uri);

      request.fields['full_name'] = fullName;
      request.fields['date_of_birth'] = dateOfBirth;
      request.fields['gender'] = gender;
      request.fields['contact_number'] = contactNumber;
      request.fields['email'] = email;
      request.fields['address'] = address;

      if (imagePath.isNotEmpty) {
        var imageFile = await http.MultipartFile.fromPath('photo', imagePath);
        request.files.add(imageFile);
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        final responseString = await response.stream.bytesToString();
        return {'success': true, 'message': 'Farmer registered successfully'};
      } else {
        final responseString = await response.stream.bytesToString();
        print('Failed to register farmer. Status code: ${response.statusCode}');
        print('Response: $responseString');
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

  Future<List<Map<String, dynamic>>> getFarmers() async {
    try {
      final response = await http.get(
        Uri.parse('${apiUrl}farmers/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Debugging the fetched data
        print('Farmers fetched: $data');

        // Define your base URL here
        String baseUrl =
            'http://192.168.100.56:8000'; // Replace with your actual backend URL

        // Process the data and ensure the photo field is correctly handled
        List<Map<String, dynamic>> farmers = [];
        for (var farmer in data) {
          // Check if the photo field exists and is not null or empty
          if (farmer['photo'] == null || farmer['photo'].isEmpty) {
            farmer['photo'] =
                'assets/images/user1.png'; // Default image if no photo is available
          } else {
            // If the photo is a relative URL, make it a full URL
            if (farmer['photo'].startsWith('/media/')) {
              farmer['photo'] =
                  '$baseUrl${farmer['photo']}'; // Make sure to join with base URL
            }
          }

          // Add the farmer data to the list
          farmers.add(farmer);
        }

        return farmers;
      } else {
        print('Failed to fetch farmers: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching farmers: $e');
      return [];
    }
  }

  // Function to send a password reset request
  Future<String> sendPasswordResetRequest(String email) async {
    final url = Uri.parse('${apiUrl}password-reset/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email, // Email to send reset link
        }),
      );

      if (response.statusCode == 200) {
        return 'Password reset email sent successfully';
      } else {
        // Attempt to return a meaningful error message from the server response
        final responseBody = json.decode(response.body);
        return responseBody['message'] ?? 'Failed to send password reset email';
      }
    } catch (e) {
      print('Error sending password reset request: $e');
      return 'An error occurred while sending the reset email';
    }
  }
}
