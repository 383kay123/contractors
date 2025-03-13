import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:apper/services/apiservice.dart';
import 'package:apper/success.dart';

class ReportFormPage extends StatefulWidget {
  const ReportFormPage({super.key});

  @override
  _ReportFormPageState createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  String _selectedActivity = 'Establishment';
  String? _selectedSubActivity;
  final List<String> _activities = [
    'Initial Treatment',
    'Establishment',
    'Maintenance'
  ];
  final Map<String, List<String>> _subActivities = {
    'Initial Treatment': [
      'Slashing before cutting (T5)',
      'Tree Cutting (T7)',
      'Aboricide application (T1)',
      'Hacking (T2)'
    ],
    'Establishment': [
      'Slashing before lining and pegging',
      'Lining/lining and marking,',
      'Holing for plantain',
      'Planting for plantain',
      'Holing for Cocoa',
      'Planting for cocoa',
    ],
    'Maintenance': [
      'Maintenance weeding',
      'Refiling of Cocoa (Holing and Planting)',
      'Refiling of plantain (Holing and Planting)',
      'Pesticide Application',
      'Fertilizer Application'
    ],
  };

  final _formKey = GlobalKey<FormState>();
  final _completionDateController = TextEditingController();
  final _reportingDateController = TextEditingController();
  final _farmReferenceController = TextEditingController();
  final _farmerNameController = TextEditingController();
  final _farmSizeController = TextEditingController();
  final _farmLocationController = TextEditingController();
  final ApiService _apiService = ApiService();

  // String _mapActivityToModelValue(String displayValue) {
  //   return displayValue.toLowerCase().replaceAll(' ', '_');
  // }

  Future<void> _submitReport(BuildContext context) async {
    debugPrint('Submitting report... $_selectedActivity');

    if (_formKey.currentState?.validate() ?? false) {
      final reportData = {
        'completion_date': _completionDateController.text,
        'reporting_date': _reportingDateController.text,
        'farm_reference': _farmReferenceController.text,
        'farmer_name': _farmerNameController.text,
        'farm_size': _farmSizeController.text,
        'farm_location': _farmLocationController.text,
        'activity_done': _selectedActivity,
        'sub_activity_done': _selectedSubActivity
      };

      try {
        final response = await _apiService.createReport(reportData);
        debugPrint('Response: $response'); // ✅ Print full response

        if (response.containsKey('error')) {
          print('Error: ${response['error']}'); // ✅ Print error message

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response['error']}')),
          );
        } else {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoadingToSuccessScreen()),
          );
        }
      } catch (e, stacktrace) {
        debugPrint('Exception: $e'); // ✅ Print exception
        debugPrint('Stacktrace: $stacktrace'); // ✅ Print stacktrace

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
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
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    String validationMessage,
  ) {
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
            borderSide: const BorderSide(width: 1.0, color: Colors.grey),
          ),
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

  Widget _buildDateField(
    TextEditingController controller,
    String hint,
    String validationMessage,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Colors.black26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
        suffixIcon: const Icon(Icons.calendar_month, color: Colors.grey),
      ),
      readOnly: true,
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        return null;
      },
    );
  }

  Widget _buildActivityDropdowns() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _selectedActivity,
          items: _activities.map((String activity) {
            return DropdownMenuItem<String>(
              value: activity,
              child: Text(
                activity,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.black45,
                ),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedActivity = newValue!;
              _selectedSubActivity = null;
            });
          },
          onSaved: (newValue) {
            setState(() {
              _selectedActivity = newValue!;
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
        ),
        const SizedBox(height: 10),
        if (_subActivities[_selectedActivity] != null)
          DropdownButtonFormField<String>(
            value: _selectedSubActivity,
            items: _subActivities[_selectedActivity]!.map((String subActivity) {
              return DropdownMenuItem<String>(
                value: subActivity,
                child: Text(
                  subActivity,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.black45,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedSubActivity = newValue;
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
                return 'Please select a sub-activity';
              }
              return null;
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Color(0xFF00754B),
        ),
        title: const Text(
          'Report',
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
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
              const SizedBox(height: 10),
              _buildDateField(
                _completionDateController,
                "Select completion date",
                "Please enter your completion date",
              ),
              const SizedBox(height: 10),
              _buildLabel('Reporting Date'),
              const SizedBox(height: 10),
              _buildDateField(
                _reportingDateController,
                "Select reporting date",
                "Please enter the reporting date",
              ),
              const SizedBox(height: 10),
              _buildLabel('Farm Reference'),
              const SizedBox(height: 10),
              _buildTextField(
                _farmReferenceController,
                "Enter farm reference",
                "Please enter the farm reference",
              ),
              const SizedBox(height: 10),
              _buildLabel('Activity Done'),
              const SizedBox(height: 10),
              _buildActivityDropdowns(),
              const SizedBox(height: 10),
              _buildLabel('Farmer Name'),
              const SizedBox(height: 10),
              _buildTextField(
                _farmerNameController,
                "Enter farmer name",
                "Please enter the farmer's name",
              ),
              const SizedBox(height: 10),
              _buildLabel('Farm Size'),
              const SizedBox(height: 10),
              _buildTextField(
                _farmSizeController,
                "Enter farm size",
                "Please enter the farm size",
              ),
              const SizedBox(height: 10),
              _buildLabel('Farm Location'),
              const SizedBox(height: 10),
              _buildTextField(
                _farmLocationController,
                "Enter farm location",
                "Please enter the farm location",
              ),
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
                onPressed: () => _submitReport(context),
                child: const Text(
                  'Submit Report',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _completionDateController.dispose();
    _reportingDateController.dispose();
    _farmReferenceController.dispose();
    _farmerNameController.dispose();
    _farmSizeController.dispose();
    _farmLocationController.dispose();
    super.dispose();
  }
}
