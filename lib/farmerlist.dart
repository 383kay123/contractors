import 'package:apper/apiservice.dart';

import 'package:flutter/material.dart';
// Replace with your actual service file path

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

  Future<void> _loadFarmers() async {
    final farmers = await _apiService.getFarmers();
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
                    return ListTile(
                      leading: farmer['photo'] != null
                          ? Image.network(
                              farmer['photo'], // Assuming photo is a URL
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.person),
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
