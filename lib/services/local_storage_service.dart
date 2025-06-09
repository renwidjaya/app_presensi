import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static Future<void> saveUserData(
    Map<String, dynamic> userData,
    String token,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user', jsonEncode(userData));
    prefs.setString('token', token);
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('user');
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
