import 'package:flutter/material.dart';
import 'package:apper/services/apiservice.dart'; // Replace with your actual service file path
import 'dart:io'; // For Image.file usage

class FarmerListScreen extends StatefulWidget {
  @override
  _FarmerListScreenState createState() => _FarmerListScreenState();
}

class _FarmerListScreenState extends State<FarmerListScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _farmers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFarmers();
  }

  // Fetch farmers from the local database (SQLite)
  Future<void> _loadFarmers() async {
    final farmers = await _apiService
        .getFarmersFromDatabase(); // Fetching from the local database
    setState(() {
      _farmers = farmers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registered Farmers")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _farmers.isEmpty
              ? Center(child: Text("No farmers found."))
              : ListView.builder(
                  itemCount: _farmers.length,
                  itemBuilder: (context, index) {
                    final farmer = _farmers[index];

                    // Check if the photo is a URL or file path and display accordingly
                    Widget photoWidget;
                    if (farmer['photo'] != null) {
                      if (farmer['photo'].startsWith('http')) {
                        // If it's a URL, display it using Image.network
                        photoWidget = Image.network(
                          farmer['photo'], // Assuming photo is a URL
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        );
                      } else {
                        // If it's a local file path, use Image.file
                        photoWidget = Image.file(
                          File(farmer['photo']),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        );
                      }
                    } else {
                      photoWidget =
                          Icon(Icons.person); // Default icon if no photo
                    }

                    return ListTile(
                      leading: photoWidget,
                      title: Text(farmer['full_name']),
                      subtitle:
                          Text(farmer['contact_number'] ?? "No contact number"),
                      onTap: () {
                        // Handle farmer details or actions
                      },
                    );
                  },
                ),
    );
  }
}
