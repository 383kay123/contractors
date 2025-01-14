import 'dart:io';

import 'package:apper/model/farmer_model.dart';
import 'package:apper/services/database_helper.dart';
import 'package:flutter/material.dart';

class FarmerDetailsPage extends StatelessWidget {
  final Farmer farmer;

  const FarmerDetailsPage({Key? key, required this.farmer}) : super(key: key);

  Widget _buildProfileImage(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (farmer.photo.isNotEmpty) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: Colors.transparent,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: InteractiveViewer(
                    child: _buildImage(farmer.photo, fit: BoxFit.contain),
                  ),
                ),
              );
            },
          );
        }
      },
      child: Hero(
        tag: 'farmer_photo_${farmer.fullName}',
        child: ClipOval(
          child: farmer.photo.isNotEmpty
              ? _buildImage(farmer.photo, width: 200, height: 200)
              : _buildDefaultImage(),
        ),
      ),
    );
  }

  Widget _buildImage(String photoPath,
      {double? width, double? height, BoxFit? fit}) {
    if (photoPath.startsWith('http')) {
      return Image.network(
        photoPath,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultImage(),
      );
    } else {
      return Image.file(
        File(photoPath),
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultImage(),
      );
    }
  }

  Widget _buildDefaultImage() {
    return Container(
      width: 200,
      height: 200,
      color: Colors.grey[200],
      child: const Icon(
        Icons.person,
        size: 100,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildDetailField({
    required String icon,
    required String value,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: Image.asset(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      textAlign: TextAlign.center,
      initialValue: value,
      readOnly: true,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        color: Colors.black45,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00754B),
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
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/compact.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Center(child: _buildProfileImage(context)),
              const SizedBox(height: 30),
              Form(
                child: Column(
                  children: [
                    _buildDetailField(
                      icon: 'assets/images/userd.png',
                      value: farmer.fullName,
                    ),
                    const SizedBox(height: 20),
                    _buildDetailField(
                      icon: 'assets/images/date-of-birth.png',
                      value: farmer.dateOfBirth,
                    ),
                    const SizedBox(height: 20),
                    _buildDetailField(
                      icon: 'assets/images/gender.png',
                      value: farmer.gender,
                    ),
                    const SizedBox(height: 20),
                    _buildDetailField(
                      icon: 'assets/images/smartphone.png',
                      value: farmer.contactNumber ?? '',
                    ),
                    const SizedBox(height: 20),
                    _buildDetailField(
                      icon: 'assets/images/email.png',
                      value: farmer.email,
                    ),
                    const SizedBox(height: 20),
                    _buildDetailField(
                      icon: 'assets/images/location.png',
                      value: farmer.address,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
