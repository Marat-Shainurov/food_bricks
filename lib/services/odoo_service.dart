import 'dart:convert';
import 'package:http/http.dart' as http;

class OdooService {
  final String baseUrl;
  OdooService(this.baseUrl);

  Future<dynamic> fetchSessionId() async {
    const odooUser = 'admin@admin.com';
    const odooPassword = '2qr-MbX-2Eu-Xg9';
    const odooDb = 'db_odoo_head';

    const data = {
      "jsonrpc": "2.0",
      "method": "call",
      "params": {
        "db": odooDb,
        "login": odooUser,
        "password": odooPassword,
      },
    };

    final sessionResponse = await http.post(
      Uri.parse('$baseUrl/web/session/authenticate'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (sessionResponse.statusCode == 200) {
      final sessionData = json.decode(sessionResponse.body);
      if (sessionData['result'] != null) {
        final cookieHeader = sessionResponse.headers['set-cookie']!;
        final sessionId = _getSessionIdFromCookie(cookieHeader);
        print('Cookie header: $cookieHeader');
        return sessionId;
      } else {
        throw Exception('Failed to authenticate session');
      }
    } else {
      throw Exception('Failed to load session');
    }
  }

  String? _getSessionIdFromCookie(String cookieHeader) {
    // Parse the session ID from the cookie header
    final cookies = cookieHeader.split(';');
    for (var cookie in cookies) {
      final cookieParts = cookie.split('=');
      if (cookieParts.length == 2 && cookieParts[0].trim() == 'session_id') {
        return cookieParts[1].trim();
      }
    }
    return null;
  }

  Future<List<dynamic>> fetchRecipeSolutions(
      String sessionId, Map<String, dynamic> data) async {
    final headers = {
      "Cookie": "session_id=$sessionId",
      'Content-Type': 'application/json',
    };
    final solutionsResponse = await http.post(
      Uri.parse('$baseUrl/api/recipe_solutions'),
      headers: headers,
      body: json.encode(data),
    );

    if (solutionsResponse.statusCode == 200) {
      final solutionsData = json.decode(solutionsResponse.body);
      if (solutionsData is List) {
        return solutionsData;
      } else {
        throw Exception(
            "Unexpected response format: ${solutionsResponse.body}");
      }
    } else {
      throw Exception(
          'Failed to fetch solutions, Status Code: ${solutionsResponse.statusCode}');
    }
  }
}
