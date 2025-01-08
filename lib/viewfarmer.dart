import 'package:apper/apiservice.dart';
import 'package:apper/farmers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ViewFarmersPage extends StatefulWidget {
  const ViewFarmersPage({super.key});

  @override
  _ViewFarmersPageState createState() => _ViewFarmersPageState();
}

class _ViewFarmersPageState extends State<ViewFarmersPage> {
  final ApiService apiService = ApiService();
  late Future<List<Map<String, dynamic>>> _farmers;
  List<Map<String, dynamic>> _filteredFarmers = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _farmers = apiService.getFarmers(); // Fetch farmers data
    _searchController.addListener(_filterFarmers);
  }

  // This method filters the farmers list based on search query
  void _filterFarmers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      // Apply the filter based on the search query
      if (query.isEmpty) {
        _filteredFarmers = []; // If search is empty, reset the list
      } else {
        _filteredFarmers = _filteredFarmers.where((farmer) {
          return farmer['full_name']
              .toLowerCase()
              .contains(query); // Filter based on full name
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(
          color: Color(0xFF00754B),
        ),
        title: const Text(
          "View Farmers",
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF00754B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: FarmerSearchDelegate(_filteredFarmers),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _farmers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SpinKitDualRing(
                color: Colors.white,
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Something went wrong. Please try again later.',
                style: TextStyle(fontFamily: 'Poppins'),
                textAlign: TextAlign.center,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No farmers found",
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            );
          } else {
            // After data is loaded, apply the filter to display results
            final farmers = snapshot.data!;
            _filteredFarmers =
                List.from(farmers); // Initial list of farmers to display

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: _filteredFarmers.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final farmer = _filteredFarmers[index];
                      return ListTile(
                        leading: farmer['full_name'] != null
                            ? CircleAvatar(
                                radius: 25,
                                backgroundColor: const Color(0xFF00754B),
                                child: Text(
                                  farmer['full_name'][0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : CircleAvatar(
                                radius: 25,
                                backgroundColor: const Color(0xFF00754B),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                        title: Text(
                          farmer['full_name'],
                          style: const TextStyle(fontFamily: 'Poppins'),
                        ),
                        subtitle: Text(
                          farmer['contact_number'] ?? "No contact available",
                          style: const TextStyle(fontFamily: 'Poppins'),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FarmerDetailsPage(farmer: farmer),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class FarmerSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> farmers;

  FarmerSearchDelegate(this.farmers);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(
          Icons.clear,
          color: Color(0xFF00754B),
        ),
        onPressed: () {
          query = ''; // Clear the search query
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
        color: Color(0xFF00754B),
      ),
      onPressed: () {
        close(context, null); // Close the search when back button is pressed
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = farmers
        .where((farmer) =>
            farmer['full_name'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Container(
      color: Colors.white, // Set background to white
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final farmer = results[index];
          return ListTile(
            leading: farmer['full_name'] != null
                ? CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFF00754B),
                    child: Text(
                      farmer['full_name'][0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFF00754B),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
            title: Text(
              farmer['full_name'],
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            subtitle: Text(
              farmer['contact_number'] ?? "No contact available",
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            onTap: () {
              close(context,
                  farmer); // Close the search and pass the selected farmer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FarmerDetailsPage(farmer: farmer),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? farmers
        : farmers
            .where((farmer) =>
                farmer['full_name'].toLowerCase().contains(query.toLowerCase()))
            .toList();

    return Container(
      color: Colors.white, // Set background to white
      child: ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final farmer = suggestions[index];
          return ListTile(
            leading: farmer['full_name'] != null
                ? CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFF00754B),
                    child: Text(
                      farmer['full_name'][0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFF00754B),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
            title: Text(
              farmer['full_name'],
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            subtitle: Text(
              farmer['contact_number'] ?? "No contact available",
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            onTap: () {
              query = farmer[
                  'full_name']; // Set the query to the selected farmer's name
              showResults(context); // Show the results immediately
            },
          );
        },
      ),
    );
  }
}
