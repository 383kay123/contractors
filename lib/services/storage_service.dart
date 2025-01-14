import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String dataKey = 'offline_data';

  Future<void> saveData(dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(dataKey, jsonEncode(data));
  }

  Future<dynamic> getData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(dataKey);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }
}
