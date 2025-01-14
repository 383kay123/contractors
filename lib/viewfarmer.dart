import 'package:apper/model/farmer_model.dart';
import 'package:apper/services/apiservice.dart';
import 'package:apper/farmers.dart';
import 'package:apper/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ViewFarmersPage extends StatefulWidget {
  const ViewFarmersPage({super.key});

  @override
  _ViewFarmersPageState createState() => _ViewFarmersPageState();
}

class _ViewFarmersPageState extends State<ViewFarmersPage> {
  final ApiService apiService = ApiService();
  late Future<List<Farmer>> _farmers;

  List<Farmer> _filteredFarmers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _farmers = _loadFarmers();
  }

  Future<List<Farmer>> _loadFarmers() async {
    List<Farmer> allFarmers = [];
    try {
      // Get farmers from API with timeout
      List<Farmer> apiFarmers = await apiService.getFarmers().timeout(
            const Duration(seconds: 5),
            onTimeout: () => <Farmer>[],
          );
      allFarmers.addAll(apiFarmers);

      // Get farmers from local database
      final dbHelper = FarmerDatabaseHelper.instance;
      List<Farmer> localFarmers = await dbHelper.fetchAllFarmers().timeout(
            const Duration(seconds: 2),
            onTimeout: () => <Farmer>[],
          );

      allFarmers.addAll(localFarmers);

      // Remove duplicates if any
      allFarmers = allFarmers.toSet().toList();

      print('Total farmers loaded: ${allFarmers.length}');
      print('API farmers: ${apiFarmers.length}');
      print('Local farmers: ${localFarmers.length}');

      return allFarmers;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading farmers: ${e.toString()}')),
        );
      }
      return [];
    }
  }
  //farmers = await apiService.getFarmers();

  void _filterFarmers(List<Farmer> farmers) {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFarmers = farmers
          .where((farmer) => farmer.fullName.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> refreshFarmers() async {
    setState(() {
      _farmers = _loadFarmers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder<List<Farmer>>(
            future: _farmers,
            builder: (context, snapshot) {
              return Scaffold(
                  appBar: AppBar(
                    backgroundColor: const Color(0xFF00754B),
                    title: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        if (snapshot.hasData) {
                          _filterFarmers(snapshot.data!);
                        }
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Search farmers...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  body: RefreshIndicator(
                    onRefresh: refreshFarmers,
                    child: FutureBuilder<List<Farmer>>(
                      future: _farmers,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: SpinKitDualRing(
                              color: Color(0xFF00754B),
                              size: 50.0,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Something went wrong: Please try again later',
                              style: const TextStyle(fontFamily: 'Poppins'),
                              textAlign: TextAlign.center,
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text(
                              "No farmers found",
                              style: TextStyle(fontFamily: 'Poppins'),
                            ),
                          );
                        }

                        _filteredFarmers = snapshot.data!;
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
                                    leading: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: const Color(0xFF00754B),
                                      child: Text(
                                        farmer.fullName[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      farmer.fullName,
                                      style: const TextStyle(
                                          fontFamily: 'Poppins'),
                                    ),
                                    subtitle: Text(
                                      farmer.contactNumber ??
                                          "No contact available",
                                      style: const TextStyle(
                                          fontFamily: 'Poppins'),
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
                      },
                    ),
                  ));
            }));
  }
}
