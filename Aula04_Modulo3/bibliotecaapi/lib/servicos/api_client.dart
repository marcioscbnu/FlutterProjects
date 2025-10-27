import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8080'; // Web
    if (Platform.isAndroid) return 'http://10.0.2.2:8080'; // Emulador Android
    return 'http://127.0.0.1:8080'; // iOS Simulator / desktop
  }

  static Future<List<dynamic>> getJsonList(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.get(uri);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('GET $path falhou: ${res.statusCode} ${res.body}');
  }

  static Future<Map<String, dynamic>> getJson(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.get(uri);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('GET $path falhou: ${res.statusCode} ${res.body}');
  }

  static Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('POST $path falhou: ${res.statusCode} ${res.body}');
  }

  static Future<Map<String, dynamic>> putJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('PUT $path falhou: ${res.statusCode} ${res.body}');
  }

  static Future<void> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.delete(uri);
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw Exception('DELETE $path falhou: ${res.statusCode} ${res.body}');
  }
}
