import 'dart:io';
import 'package:apper/model/farmer_model.dart';
import 'package:apper/services/apiservice.dart';
import 'package:apper/services/database_helper.dart';
import 'package:apper/success.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class RegisterFarmerPage extends StatefulWidget {
  const RegisterFarmerPage({super.key});

  @override
  _RegisterFarmerPageState createState() => _RegisterFarmerPageState();
}

class _RegisterFarmerPageState extends State<RegisterFarmerPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedGender = 'Male';
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _contactnumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final List<String> _genders = ['Male', 'Female'];
  FarmerDatabaseHelper? farmerDB;

  Future<void> _registerFarmer() async {
    if (_formKey.currentState!.validate()) {
      ApiService apiService = ApiService();
      var result = await apiService.registerFarmer(
          _fullNameController.text.trim(),
          _dateOfBirthController.text.trim(),
          _selectedGender,
          _contactnumberController.text.trim(),
          _emailController.text.trim(),
          _addressController.text.trim(),
          _selectedImage?.path ?? '');

      if (result['success']) {
        await apiService.testFarmerStorage();
        Farmer farmer = Farmer(
            fullName: _fullNameController.text,
            dateOfBirth: _dateOfBirthController.text,
            gender: _selectedGender,
            contactNumber: _contactnumberController.text,
            email: _emailController.text,
            address: _addressController.text,
            photo: _selectedImage?.path ?? '');

        int? response = await farmerDB!.insertFarmer(farmer);

        if (response != null && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoadingToSuccessScreen()),
          );
        }
      }
    }
  }

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveFarmerOffline() async {
    if (_formKey.currentState!.validate()) {
      Farmer farmer = Farmer(
          fullName: _fullNameController.text,
          dateOfBirth: _dateOfBirthController.text,
          gender: _selectedGender,
          contactNumber: _contactnumberController.text,
          email: _emailController.text,
          address: _addressController.text,
          photo: _selectedImage?.path ?? '');

      int? response = await farmerDB!.insertFarmer(farmer);
      if (response != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoadingToSuccessScreen()),
        );
      }
    }
  }

  Future<void> _checkStoredFarmers() async {
    final db = FarmerDatabaseHelper.instance;
    final List<Farmer> farmers = await db.fetchAllFarmers();
    for (var farmer in farmers) {
      print('''
      Farmer Details:
      Name: ${farmer.fullName}
      Date of Birth: ${farmer.dateOfBirth}
      Gender: ${farmer.gender}
      Contact: ${farmer.contactNumber}
      Email: ${farmer.email}
      Address: ${farmer.address}
      Photo Path: ${farmer.photo}
      ''');
    }
  }

  Widget _buildLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontFamily: 'Poppins',
        ),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, String validationMessage) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: Colors.black26),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(width: 0.1)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validationMessage;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      items: _genders.map((String gender) {
        return DropdownMenuItem<String>(
          value: gender,
          child: Text(
            gender,
            style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 14, color: Colors.black45),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedGender = newValue!;
        });
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a gender';
        }
        return null;
      },
    );
  }

  @override
  void initState() {
    farmerDB = FarmerDatabaseHelper.instance;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color(0xFF00754B)),
        backgroundColor: Colors.white,
        title: const Text(
          "Register Farmer",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF00754B),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Personal Information',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00754B),
                ),
              ),
              const SizedBox(height: 10),
              _buildLabel('Full Name'),
              SizedBox(height: 10),
              _buildTextField(_fullNameController, "Enter full name",
                  "Please enter your full name"),
              const SizedBox(height: 10),
              _buildLabel('Date of Birth'),
              SizedBox(height: 10),
              TextFormField(
                controller: _dateOfBirthController,
                decoration: InputDecoration(
                  hintText: "Select date of birth",
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 12.0),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    _dateOfBirthController.text =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your date of birth';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              _buildLabel('Gender'),
              SizedBox(height: 10),
              _buildGenderDropdown(),
              const SizedBox(height: 10),
              const Text(
                'Contact Information',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 10),
              _buildTextField(_contactnumberController, "Enter contact number",
                  "Please enter a contact number"),
              const SizedBox(height: 10),
              const Text(
                'Email',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 10),
              _buildTextField(
                  _emailController, "Enter your email", "Please enter email"),
              const SizedBox(height: 10),
              const Text(
                'Address',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 10),
              _buildTextField(_addressController, "Enter your address",
                  "Please enter address"),
              const SizedBox(height: 10),
              const Text(
                'Upload Photo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00754B),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 100,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 0.1),
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: _takePhoto,
                  child: Align(
                    alignment: Alignment.center,
                    child: _selectedImage != null
                        ? Image.file(
                            _selectedImage!,
                            width: 400,
                            height: 400,
                            fit: BoxFit.contain,
                          )
                        : Image.asset(
                            'assets/images/camera.png',
                            width: 150,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 40),
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF00754B),
                    ),
                    onPressed: _saveFarmerOffline,
                    child: const Text(
                      'Save',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 15),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 40),
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF00754B),
                    ),
                    onPressed: _registerFarmer,
                    child: const Text(
                      'Register',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 15),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _checkStoredFarmers,
                child: const Text('Check Stored Farmers'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
