import 'dart:convert';

class Farmer {
  final String fullName;
  final String dateOfBirth;
  final String gender;
  final String? contactNumber;
  final String email;
  final String address;
  final String photo;

  Farmer({
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    this.contactNumber,
    required this.email,
    required this.address,
    required this.photo,
  });

  // Convert Farmer object to a Map
  Map<String, dynamic> toMap() {
    return {
      'full_name': fullName,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'contact_number': contactNumber,
      'email': email,
      'address': address,
      'photo': photo,
    };
  }

  // Convert Map to a Farmer object
  factory Farmer.fromMap(Map<String, dynamic> map) {
    return Farmer(
      fullName: map['full_name'] ?? '',
      dateOfBirth: map['date_of_birth'] ?? '',
      gender: map['gender'] ?? '',
      contactNumber: map['contact_number']?.toString(),
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      photo: map['photo'] ?? '',
    );
  }

  // Convert Farmer object to JSON string
  String toJson() => json.encode(toMap());

  // Convert JSON string to a list of Farmer objects
  static List<Farmer> fromJson(String source) {
    final List<dynamic> farmerList = json.decode(source);
    return farmerList.map((map) => Farmer.fromMap(map)).toList();
  }
}
