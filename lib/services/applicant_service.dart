import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

class ApplicantService {
  // ============================================================
  // GET CURRENT USER PROFILE
  // ============================================================

  Future<Map<String, dynamic>?> getMyProfile() async {
    try {
      final prefs =
      await SharedPreferences.getInstance();

      final String? token =
      prefs.getString("token");

      print("");
      print("========================================");
      print("GET MY PROFILE");
      print("========================================");

      if (token == null || token.isEmpty) {
        print("GET PROFILE: JWT token missing");
        print("========================================");
        return null;
      }

      final url =
          "${ApiConfig.baseUrl}/api/applicants/me";

      print("PROFILE URL: $url");
      print("PROFILE HOST: ${Uri.parse(url).host}");
      print("PROFILE PORT: ${Uri.parse(url).port}");
      print("Sending profile request...");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      print(
        "Profile Status: ${response.statusCode}",
      );

      print(
        "Profile Response: ${response.body}",
      );

      print("========================================");

      // --------------------------------------------------------
      // SUCCESS
      // --------------------------------------------------------

      if (response.statusCode == 200) {
        try {
          final data =
          jsonDecode(response.body);

          if (data is Map<String, dynamic>) {
            return data;
          }

          print(
            "GET PROFILE: Invalid response format",
          );

          return null;
        } catch (e) {
          print(
            "GET PROFILE JSON ERROR: $e",
          );

          return null;
        }
      }

      // --------------------------------------------------------
      // UNAUTHORIZED
      // --------------------------------------------------------

      if (response.statusCode == 401) {
        print(
          "GET PROFILE: 401 Unauthorized",
        );
        print(
          "JWT token may be expired.",
        );

        return null;
      }

      // --------------------------------------------------------
      // FORBIDDEN
      // --------------------------------------------------------

      if (response.statusCode == 403) {
        print(
          "GET PROFILE: 403 Forbidden",
        );

        return null;
      }

      // --------------------------------------------------------
      // OTHER ERROR
      // --------------------------------------------------------

      print(
        "GET PROFILE: HTTP ${response.statusCode}",
      );

      return null;
    } on http.ClientException catch (e) {
      print("");
      print("========================================");
      print("GET PROFILE CLIENT ERROR");
      print("========================================");
      print(e);
      print("========================================");

      return null;
    } catch (e) {
      print("");
      print("========================================");
      print("GET PROFILE ERROR");
      print("========================================");
      print(e);
      print("========================================");

      return null;
    }
  }

  // ============================================================
  // UPDATE CURRENT USER PROFILE
  // ============================================================

  Future<bool> updateProfile(
      Map<String, dynamic> profile,
      ) async {
    try {
      final prefs =
      await SharedPreferences.getInstance();

      final String? token =
      prefs.getString("token");

      print("");
      print("========================================");
      print("UPDATE MY PROFILE");
      print("========================================");

      if (token == null || token.isEmpty) {
        print(
          "UPDATE PROFILE: JWT token missing",
        );

        print("========================================");

        return false;
      }

      final url =
          "${ApiConfig.baseUrl}/api/applicants/me";

      print("UPDATE PROFILE URL: $url");

      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(profile),
      );

      print(
        "Update Status: ${response.statusCode}",
      );

      print(
        "Update Response: ${response.body}",
      );

      print("========================================");

      if (response.statusCode == 200) {
        return true;
      }

      if (response.statusCode == 401) {
        print(
          "UPDATE PROFILE: 401 Unauthorized",
        );
      } else if (response.statusCode == 403) {
        print(
          "UPDATE PROFILE: 403 Forbidden",
        );
      } else {
        print(
          "UPDATE PROFILE: HTTP ${response.statusCode}",
        );
      }

      return false;
    } on http.ClientException catch (e) {
      print("");
      print("========================================");
      print("UPDATE PROFILE CLIENT ERROR");
      print("========================================");
      print(e);
      print("========================================");

      return false;
    } catch (e) {
      print("");
      print("========================================");
      print("UPDATE PROFILE ERROR");
      print("========================================");
      print(e);
      print("========================================");

      return false;
    }
  }
}