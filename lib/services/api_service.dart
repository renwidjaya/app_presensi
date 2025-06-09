import 'dart:convert';
import '../constants/api_base.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final String _baseUrl = ApiBase.baseUrl;

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) {
    return http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> get(String endpoint) {
    return http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
