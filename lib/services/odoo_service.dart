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

  Future<List<dynamic>> fetchStrategies(
      String sessionId, Map<String, dynamic> data) async {
    final headers = {
      "Cookie": "session_id=$sessionId",
      'Content-Type': 'application/json',
    };
    final strategiesResponse = await http.post(
      Uri.parse('$baseUrl/api/strategies'),
      headers: headers,
      body: json.encode(data),
    );

    if (strategiesResponse.statusCode == 200) {
      final strategiesData = json.decode(strategiesResponse.body);
      if (strategiesData is List) {
        return strategiesData;
      } else {
        throw Exception(
            "Unexpected response format: ${strategiesResponse.body}");
      }
    } else {
      throw Exception(
          'Failed to fetch strategies, Status Code: ${strategiesResponse.statusCode}');
    }
  }

  Future<List<dynamic>> fetchStrategyRations(
      String sessionId, Map<String, dynamic> data) async {
    final headers = {
      "Cookie": "session_id=$sessionId",
      'Content-Type': 'application/json',
    };
    final rationsResponse = await http.post(
      Uri.parse('$baseUrl/api/rations'),
      headers: headers,
      body: json.encode(data),
    );

    if (rationsResponse.statusCode == 200) {
      final strategiesData = json.decode(rationsResponse.body);
      if (strategiesData is List) {
        return strategiesData;
      } else {
        throw Exception("Unexpected response format: ${rationsResponse.body}");
      }
    } else {
      throw Exception(
          'Failed to fetch rations, Status Code: ${rationsResponse.statusCode}');
    }
  }

  Future<dynamic> fetchConstructors(
      String sessionId, dynamic selectedRestaurantId) async {
    final headers = {
      "Cookie": "session_id=$sessionId",
      'Content-Type': 'application/json',
    };

    Map<String, dynamic> data = {"identifier": selectedRestaurantId};

    final response = await http.post(
      Uri.parse('$baseUrl/api/constructors'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final solutionsData = json.decode(response.body);
      if (solutionsData is List) {
        return solutionsData;
      } else {
        print("Unexpected response format: ${response.body}");
        return [];
      }
    } else {
      throw Exception(
          'Failed to fetch constructors, Status Code: ${response.statusCode}');
    }
  }

  Future<dynamic> fetchRestaurants(String sessionId) async {
    final headers = {
      "Cookie": "session_id=$sessionId",
      'Content-Type': 'application/json',
    };
    final response = await http.post(
      Uri.parse('$baseUrl/api/restaurants'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final restaurantsData = json.decode(response.body);
      if (restaurantsData is List) {
        return restaurantsData;
      } else {
        print('Fetching restaurants error ${response.body}');
        return [];
      }
    } else {
      throw Exception(
          'Failed to fetch restaurants, Status Code: ${response.statusCode}');
    }
  }

  Future<dynamic> fetchDiets(String sessionId, String phoneNumber) async {
    final headers = {
      "Cookie": "session_id=$sessionId",
      'Content-Type': 'application/json',
    };

    final data = {"client_phone": phoneNumber};

    final response = await http.post(
      Uri.parse('$baseUrl/api/available_diets'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final dietsData = json.decode(response.body);
      if (dietsData is List) {
        return dietsData;
      } else {
        print('Fetching diets error ${response.body}');
        return [];
      }
    } else {
      throw Exception(
          'Failed to fetch diets data, Status Code: ${response.statusCode}');
    }
  }

  Future<dynamic> updateDiets(
      String sessionId, List selectedDiets, String phoneNumber) async {
    final headers = {
      "Cookie": "session_id=$sessionId",
      'Content-Type': 'application/json',
    };

    final data = {"selected_diets": selectedDiets, "client_phone": phoneNumber};

    final response = await http.post(
      Uri.parse('$baseUrl/api/client/update_client_diets'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final updatedDietsData = json.decode(response.body);
      if (updatedDietsData is Map<String, dynamic>) {
        return updatedDietsData;
      } else {
        print('Updating diets error ${response.body}');
        return [];
      }
    } else {
      throw Exception(
          'Failed to update diets, Status Code: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> createKitchenOrder(String sessionId,
      String identifier, String restaurant, dynamic phoneNumber) async {
    final headers = {
      "Cookie": "session_id=$sessionId",
      'Content-Type': 'application/json',
    };

    final data = {
      "identifier": identifier,
      "restaurant_identifier": restaurant,
      "client_phone": phoneNumber
    };

    final orderResponse = await http.post(
      Uri.parse('$baseUrl/api/create_kitchen_order'),
      headers: headers,
      body: json.encode(data),
    );

    if (orderResponse.statusCode == 200) {
      final orderData = json.decode(orderResponse.body);
      if (orderData is Map<String, dynamic>) {
        return orderData;
      } else {
        throw Exception("Unexpected response format: ${orderResponse.body}");
      }
    } else {
      throw Exception(
          'Failed to create kitchen order, Status Code: ${orderResponse.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getOrCreateOdooClient(
      String sessionId, String phoneNumber) async {
    final headers = {
      "Cookie": "session_id=$sessionId",
      'Content-Type': 'application/json',
    };

    final data = {"client_phone": phoneNumber};

    final orderResponse = await http.post(
      Uri.parse('$baseUrl/api/get_or_create_client'),
      headers: headers,
      body: json.encode(data),
    );

    if (orderResponse.statusCode == 200) {
      final clientData = json.decode(orderResponse.body);
      if (clientData is Map<String, dynamic>) {
        return clientData;
      } else {
        throw Exception("Unexpected response format: ${orderResponse.body}");
      }
    } else {
      throw Exception(
          'Failed to create client, Status Code: ${orderResponse.statusCode}');
    }
  }

  Future<Map<String, String>> updateClientField(String sessionId,
      String phoneNumber, String fieldName, dynamic fieldValue) async {
    final headers = {
      "Cookie": "session_id=$sessionId",
      'Content-Type': 'application/json',
    };

    final data = {
      "client_phone": phoneNumber,
      "field": fieldName,
      "value": fieldValue
    };

    final updateResponse = await http.post(
      Uri.parse('$baseUrl/api/update_client_field'),
      headers: headers,
      body: json.encode(data),
    );

    if (updateResponse.statusCode == 200) {
      final updateData = json.decode(updateResponse.body);

      // Accept any value types and convert them to strings
      if (updateData is Map<String, dynamic>) {
        return updateData.map((key, value) => MapEntry(key, value.toString()));
      } else {
        throw Exception("Unexpected response format: ${updateResponse.body}");
      }
    } else {
      throw Exception(
          'Failed to update client, Status Code: ${updateResponse.statusCode}');
    }
  }
}
