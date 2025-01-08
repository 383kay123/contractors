import 'package:flutter/material.dart';

class FarmerDetailsPage extends StatelessWidget {
  final Map<String, dynamic> farmer;

  const FarmerDetailsPage({super.key, required this.farmer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color(0xFF00754B),
          elevation: 0,
          title: const Text(
            'Farmer Details',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                    'assets/images/compact.png'), // Add your image here
                fit: BoxFit
                    .cover // Adjust this based on how you want the image to scale
                ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 30),
                  // Farmer's Photo
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        if (farmer['photo'] != null) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                backgroundColor: Colors.transparent,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: InteractiveViewer(
                                    child: Image.network(
                                      farmer['photo'],
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                      child: ClipOval(
                        child: farmer['photo'] != null
                            ? Image.network(
                                farmer['photo'],
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.person,
                                size: 100,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Farmer Details Form (Read-Only)
                Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: Image.asset('assets/images/userd.png'),
                        ),
                        textAlign: TextAlign.center,
                        initialValue: farmer['full_name'] ?? '',
                        readOnly: true,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color:
                              Colors.black45, // Customize the input text color
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                            prefixIcon: Image.asset(
                          'assets/images/date-of-birth.png',
                          width: 20,
                          height: 20,
                        )),
                        textAlign: TextAlign.center,
                        initialValue: farmer['date_of_birth'] ?? '',
                        readOnly: true,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color:
                              Colors.black45, // Customize the input text color
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                            prefixIcon:
                                Image.asset('assets/images/gender.png')),
                        textAlign: TextAlign.center,
                        initialValue: farmer['gender'] ?? '',
                        readOnly: true,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color:
                              Colors.black45, // Customize the input text color
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                            prefixIcon:
                                Image.asset('assets/images/smartphone.png')),
                        textAlign: TextAlign.center,
                        initialValue: farmer['contact_number'] ?? '',
                        readOnly: true,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color:
                              Colors.black45, // Customize the input text color
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                            prefixIcon: Image.asset('assets/images/email.png')),
                        textAlign: TextAlign.center,
                        initialValue: farmer['email'] ?? '',
                        readOnly: true,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color:
                              Colors.black45, // Customize the input text color
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                            prefixIcon:
                                Image.asset('assets/images/location.png')),
                        textAlign: TextAlign.center,
                        initialValue: farmer['address'] ?? '',
                        readOnly: true,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color:
                              Colors.black45, // Customize the input text color
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
