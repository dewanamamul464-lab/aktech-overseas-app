import 'dart:convert';
import '../config/api_config.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminEmployerService {
  final String baseUrl = ApiConfig.baseUrl;

  // =========================================================
  // GET JWT TOKEN
  // =========================================================

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      print("ADMIN EMPLOYER SERVICE: JWT TOKEN NOT FOUND");
      return null;
    }

    return token;
  }

  // =========================================================
  // HEADERS
  // =========================================================

  Future<Map<String, String>?> _headers() async {
    final token = await _getToken();

    if (token == null) {
      return null;
    }

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // =========================================================
  // GET ALL EMPLOYERS
  //
  // GET /api/admin/employers
  // =========================================================

  Future<List<dynamic>?> getAllEmployers() async {
    try {
      final headers = await _headers();

      if (headers == null) {
        return null;
      }

      final url = Uri.parse(
        "$baseUrl/api/admin/employers",
      );

      print("=================================");
      print("ADMIN - GET ALL EMPLOYERS");
      print("URL: $url");
      print("=================================");

      final response = await http.get(
        url,
        headers: headers,
      );

      print("STATUS: ${response.statusCode}");
      print("RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          return data;
        }

        return [];
      }

      if (response.statusCode == 401) {
        print("ADMIN EMPLOYERS: UNAUTHORIZED");
        return null;
      }

      if (response.statusCode == 403) {
        print("ADMIN EMPLOYERS: FORBIDDEN");
        return null;
      }

      return null;
    } catch (e) {
      print("GET ALL EMPLOYERS ERROR: $e");
      return null;
    }
  }

  // =========================================================
  // GET PENDING EMPLOYERS
  //
  // GET /api/admin/employers/pending
  // =========================================================

  Future<List<dynamic>?> getPendingEmployers() async {
    try {
      final headers = await _headers();

      if (headers == null) {
        return null;
      }

      final url = Uri.parse(
        "$baseUrl/api/admin/employers/pending",
      );

      print("=================================");
      print("ADMIN - GET PENDING EMPLOYERS");
      print("URL: $url");
      print("=================================");

      final response = await http.get(
        url,
        headers: headers,
      );

      print("STATUS: ${response.statusCode}");
      print("RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          return data;
        }

        return [];
      }

      if (response.statusCode == 401) {
        print("PENDING EMPLOYERS: UNAUTHORIZED");
        return null;
      }

      if (response.statusCode == 403) {
        print("PENDING EMPLOYERS: FORBIDDEN");
        return null;
      }

      return null;
    } catch (e) {
      print("GET PENDING EMPLOYERS ERROR: $e");
      return null;
    }
  }

  // =========================================================
  // GET EMPLOYER BY ID
  //
  // GET /api/admin/employers/{id}
  // =========================================================

  Future<Map<String, dynamic>?> getEmployerById(
      int id,
      ) async {
    try {
      final headers = await _headers();

      if (headers == null) {
        return null;
      }

      final url = Uri.parse(
        "$baseUrl/api/admin/employers/$id",
      );

      final response = await http.get(
        url,
        headers: headers,
      );

      print(
        "GET EMPLOYER $id STATUS: "
            "${response.statusCode}",
      );

      print(
        "GET EMPLOYER $id RESPONSE: "
            "${response.body}",
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          return data;
        }
      }

      return null;
    } catch (e) {
      print("GET EMPLOYER BY ID ERROR: $e");
      return null;
    }
  }

  // =========================================================
  // APPROVE EMPLOYER
  //
  // PUT /api/admin/employers/{id}/approve
  // =========================================================

  Future<Map<String, dynamic>?> approveEmployer(
      int id,
      ) async {
    try {
      final headers = await _headers();

      if (headers == null) {
        return null;
      }

      final url = Uri.parse(
        "$baseUrl/api/admin/employers/$id/approve",
      );

      print("=================================");
      print("APPROVE EMPLOYER");
      print("EMPLOYER ID: $id");
      print("URL: $url");
      print("=================================");

      final response = await http.put(
        url,
        headers: headers,
      );

      print("APPROVE STATUS: ${response.statusCode}");
      print("APPROVE RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          return data;
        }
      }

      return null;
    } catch (e) {
      print("APPROVE EMPLOYER ERROR: $e");
      return null;
    }
  }

  // =========================================================
  // REJECT EMPLOYER
  //
  // PUT /api/admin/employers/{id}/reject
  // =========================================================

  Future<Map<String, dynamic>?> rejectEmployer(
      int id,
      ) async {
    try {
      final headers = await _headers();

      if (headers == null) {
        return null;
      }

      final url = Uri.parse(
        "$baseUrl/api/admin/employers/$id/reject",
      );

      print("=================================");
      print("REJECT EMPLOYER");
      print("EMPLOYER ID: $id");
      print("URL: $url");
      print("=================================");

      final response = await http.put(
        url,
        headers: headers,
      );

      print("REJECT STATUS: ${response.statusCode}");
      print("REJECT RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          return data;
        }
      }

      return null;
    } catch (e) {
      print("REJECT EMPLOYER ERROR: $e");
      return null;
    }
  }

  // =========================================================
  // DELETE EMPLOYER
  //
  // DELETE /api/admin/employers/{id}
  // =========================================================

  Future<bool> deleteEmployer(
      int id,
      ) async {
    try {
      final headers = await _headers();

      if (headers == null) {
        return false;
      }

      final url = Uri.parse(
        "$baseUrl/api/admin/employers/$id",
      );

      final response = await http.delete(
        url,
        headers: headers,
      );

      print("DELETE EMPLOYER STATUS: ${response.statusCode}");
      print("DELETE EMPLOYER RESPONSE: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("DELETE EMPLOYER ERROR: $e");
      return false;
    }
  }
}