import 'package:apper/home/home_controller.dart';
import 'package:apper/registerfarmer.dart';
import 'package:apper/report_activity.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  final String contractorName;

  const HomePage({super.key, required this.contractorName});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final homeController = Get.put(HomeController());

  int _selectedIndex = 0;

  // Add the method here, between your variables and existing methods
  void navigateToRegisterFarmer() {
    Navigator.of(context).pushNamed('/registerFarmer');
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      print("Home tapped");
    } else if (index == 1) {
      Navigator.pushNamed(context, '/registerFarmer');
    } else if (index == 2) {
      print("Settings tapped");
    }
  }

  Card buildCard(
    String title,
    IconData icon,
    Function() onTap,
  ) {
    return Card(
      color: Colors.white,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(
          color: Color(0xFF00754B),
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 50, // Adjust height dynamically or set it fixed
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40.0, color: const Color(0xFF00754B)),
                const SizedBox(height: 10.0),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Home",
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF00754B),
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return Padding(
                padding: const EdgeInsets.only(left: 5),
                child: IconButton(
                  icon: Image.asset('assets/images/menu.png',
                      width: 40, height: 60),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ));
          },
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF00754B),
              ),
              child: Center(
                child: Text(
                  "Contractor Menu",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            ListTile(
              title: const Text(
                "Profile",
                style: TextStyle(fontFamily: 'Poppins'),
              ),
              onTap: () {
                // Navigate to Profile page
              },
            ),
            ListTile(
              title: const Text(
                "Settings",
                style: TextStyle(fontFamily: 'Poppins'),
              ),
              onTap: () {
                // Navigate to Settings page
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCB343F),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      )),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${homeController.username.value}!',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterFarmerPage()),
                  );
                },
                child: Container(
                  height: 180,
                  width: double.infinity, // Full width
                  child: Card(
                    elevation: 4, // Shadow effect for the card
                    color: const Color(0xFF00754B), // Card color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(
                          16.0), // Padding around content inside the card
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Align content to the center vertically
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Align content to the start horizontally
                        children: [
                          Image.asset(
                            'assets/images/adduser1.png',
                            width: 70,
                            height: 70,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Register\nFarmer",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                              Image.asset(
                                'assets/images/next.png',
                                width: 40,
                                height: 40,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20.0,
                mainAxisSpacing: 16.0,
                shrinkWrap: true, // Ensure GridView is sized correctly
                physics:
                    const NeverScrollableScrollPhysics(), // Prevent nested scrolling
                children: [
                  buildCard('View Farmers', Icons.person, () {
                    Navigator.pushNamed(context, '/loading'); // Handle onTap
                  }),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReportFormPage()),
                  );
                },
                child: Container(
                  height: 180,
                  width: double.infinity, // Full width
                  child: Card(
                    elevation: 4, // Shadow effect for the card
                    color: const Color(0xFF00754B), // Card color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(10), // Rounded corners
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(
                          16.0), // Padding around content inside the card
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Align content to the center vertically
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Align content to the start horizontally
                        children: [
                          Image.asset(
                            'assets/images/report.png',
                            width: 70,
                            height: 70,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Activity\nReporting",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                              Image.asset(
                                'assets/images/next.png',
                                width: 40,
                                height: 40,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/home1.png',
              width: 22,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/cogwheel.png',
              width: 20,
            ),
            label: 'Settings',
          ),
        ],
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w300,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: Colors.grey,
        ),
        selectedItemColor: const Color(0xFF00754B),
        unselectedItemColor: Colors.black,
      ),
    );
  }
}
