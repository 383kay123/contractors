class Farmer {
  final int id;
  final String FullName;
  final String dateOfBirth;
  final String gender;
  final String contactNumber;
  final String email;
  final String address;
  final String photo;

  Farmer({
    required this.id,
    required this.FullName,
    required this.dateOfBirth,
    required this.gender,
    required this.contactNumber,
    required this.email,
    required this.address,
    required this.photo,
  });

//Convert a farmer object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'FullName': FullName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'contactNumber': contactNumber,
      'email': email,
      'address': address,
      'photo': photo,
    };
  }

//Convert a map to a farmer object
  factory Farmer.fromMap(Map<String, dynamic> map) {
    return Farmer(
      id: map['id'],
      FullName: map['FullName'],
      dateOfBirth: map['dateOfBirth'],
      gender: map['gender'],
      contactNumber: map['contactNumber'],
      email: map['email'],
      address: map['address'],
      photo: map['photo'],
    );
  }
}
