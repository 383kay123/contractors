import 'package:apper/services/apiservice.dart';
import 'package:apper/success.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportFormPage extends StatefulWidget {
  @override
  _ReportFormPageState createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  String? _selectedactivity = 'Establishment';
  final List<String> _activity = [
    'Initial Treatment',
    'Establishment',
    'Maintenance'
  ];
  // Map display value to model value
  String mapActivityToModelValue(String displayValue) {
    switch (displayValue) {
      case 'Initial Treatment':
        return 'initial_treatment';
      case 'Establishment':
        return 'establishment';
      case 'Maintenance':
        return 'maintenance';
      default:
        return 'initial_treatment';
    }
  }

  final _formKey = GlobalKey<FormState>();
  final _completionDateController = TextEditingController();
  final _reportingDateController = TextEditingController();
  final _farmReferenceController = TextEditingController();
  final _farmerNameController = TextEditingController();
  final _farmSizeController = TextEditingController();
  final _farmLocationController = TextEditingController();

  // Create an instance of ApiService
  final ApiService _apiService = ApiService();

  Future<void> submitReport(BuildContext context) async {
    print('Selected activity: $_selectedactivity');
    if (_formKey.currentState?.validate() ?? false) {
      // Get form data
      final reportData = {
        'completion_date': _completionDateController.text,
        'reporting_date': _reportingDateController.text,
        'farm_reference': _farmReferenceController.text,
        'activity': mapActivityToModelValue(_selectedactivity!),
        'farmer_name': _farmerNameController.text,
        'farm_size': _farmSizeController.text,
        'farm_location': _farmLocationController.text,
      };

      // Call the API service to create the report
      final response = await _apiService.createReport(reportData);

      if (response.containsKey('error')) {
        // Handle error

        // Navigate to the SuccessPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoadingToSuccessScreen()),
        );
      }
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
              borderSide: BorderSide(width: 1.0, color: Colors.grey)),
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

  Widget _buildActivityDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedactivity,
      items: _activity.map((String activity) {
        return DropdownMenuItem<String>(
          value: activity,
          child: Text(
            activity,
            style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 14, color: Colors.black45),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        print('Selected activity: $newValue');
        setState(() {
          _selectedactivity = newValue!;
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
          return 'Please select an activity';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Color(0xFF00754B),
        ),
        title: Text(
          ' Report',
          style: TextStyle(
              fontSize: 24, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildLabel('Completion Date'),
              SizedBox(height: 10),
              TextFormField(
                controller: _completionDateController,
                decoration: InputDecoration(
                  hintText: "Select completion date",
                  hintStyle:
                      const TextStyle(fontSize: 14, color: Colors.black26),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 12.0),
                  suffixIcon: Icon(Icons.calendar_month, color: Colors.grey),
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
                    _completionDateController.text =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your completion date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10.0),
              _buildLabel('Reporting Date'),
              SizedBox(height: 10),
              TextFormField(
                controller: _reportingDateController,
                decoration: InputDecoration(
                  hintText: "Select reporting date",
                  hintStyle:
                      const TextStyle(fontSize: 14, color: Colors.black26),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 12.0),
                  suffixIcon: Icon(Icons.calendar_month, color: Colors.grey),
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
                    _reportingDateController.text =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the reporting date';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 10,
              ),
              _buildLabel('Farm Reference'),
              SizedBox(height: 10),
              _buildTextField(_farmReferenceController, "Enter farm reference",
                  "Please enter your full name"),
              SizedBox(
                height: 10,
              ),
              _buildLabel('Activity Done'),
              SizedBox(height: 10),
              _buildActivityDropdown(),
              const SizedBox(height: 10),
              _buildLabel('Farmer Name'),
              SizedBox(height: 10),
              _buildTextField(_farmerNameController, "Enter farmer name",
                  "Please enter the farmer's name"),
              SizedBox(
                height: 10,
              ),
              _buildLabel('Farm Size'),
              SizedBox(height: 10),
              _buildTextField(_farmSizeController, "Enter farm size",
                  "Please enter the farm size"),
              SizedBox(height: 10),
              _buildLabel('Farm Location'),
              SizedBox(height: 10),
              _buildTextField(_farmLocationController, "Enter farm location",
                  "Please enter the farm location"),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF00754B),
                ),
                onPressed: () =>
                    submitReport(context), // Call the method when pressed
                child: Text(
                  'Submit Report',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
