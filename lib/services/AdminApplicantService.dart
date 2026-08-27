import 'dart:convert';

import '../config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminApplicantService {
  final String baseUrl = ApiConfig.baseUrl;

  // =========================================================
  // GET JWT TOKEN
  // =========================================================

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      print("ADMIN APPLICANT SERVICE: JWT TOKEN NOT FOUND");
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
  // GET ALL APPLICANTS
  //
  // GET /api/admin/applicants
  // =========================================================

  Future<List<dynamic>?> getAllApplicants() async {
    try {
      final headers = await _headers();

      if (headers == null) {
        return null;
      }

      final url = Uri.parse(
        "$baseUrl/api/admin/applicants",
      );

      print("=================================");
      print("ADMIN - GET ALL APPLICANTS");
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
        print("ADMIN APPLICANTS: UNAUTHORIZED");
        return null;
      }

      if (response.statusCode == 403) {
        print("ADMIN APPLICANTS: FORBIDDEN");
        return null;
      }

      return null;
    } catch (e) {
      print("GET ALL APPLICANTS ERROR: $e");
      return null;
    }
  }

  // =========================================================
  // GET APPLICANT BY ID
  //
  // GET /api/admin/applicants/{id}
  // =========================================================

  Future<Map<String, dynamic>?> getApplicantById(
      int id,
      ) async {
    try {
      final headers = await _headers();

      if (headers == null) {
        return null;
      }

      final url = Uri.parse(
        "$baseUrl/api/admin/applicants/$id",
      );

      final response = await http.get(
        url,
        headers: headers,
      );

      print(
        "GET APPLICANT $id STATUS: "
            "${response.statusCode}",
      );

      print(
        "GET APPLICANT $id RESPONSE: "
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
      print("GET APPLICANT BY ID ERROR: $e");
      return null;
    }
  }

  // =========================================================
  // DELETE APPLICANT
  //
  // DELETE /api/admin/applicants/{id}
  // =========================================================

  Future<bool> deleteApplicant(
      int id,
      ) async {
    try {
      final headers = await _headers();

      if (headers == null) {
        return false;
      }

      final url = Uri.parse(
        "$baseUrl/api/admin/applicants/$id",
      );

      print("=================================");
      print("DELETE APPLICANT");
      print("APPLICANT ID: $id");
      print("URL: $url");
      print("=================================");

      final response = await http.delete(
        url,
        headers: headers,
      );

      print(
        "DELETE APPLICANT STATUS: "
            "${response.statusCode}",
      );

      print(
        "DELETE APPLICANT RESPONSE: "
            "${response.body}",
      );

      return response.statusCode == 200;
    } catch (e) {
      print("DELETE APPLICANT ERROR: $e");
      return false;
    }
  }
}