import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'auth_service.dart';

class ApplicationService {
  // =========================================================
  // BACKEND URL
  // =========================================================
  //
  // The URL is managed centrally through ApiConfig.
  //
  // This prevents the application from depending on your
  // laptop's local Wi-Fi IP address.
  //
  static String get baseUrl => ApiConfig.baseUrl;

  final AuthService authService = AuthService();

  // =========================================================
  // APPLY FOR JOB
  // =========================================================

  Future<bool> applyJob(int jobId) async {
    try {
      final token =
      await authService.getToken();

      if (token == null || token.isEmpty) {
        debugPrint(
          "APPLY ERROR: No authentication token",
        );
        return false;
      }

      final url =
          "$baseUrl/api/applications";

      debugPrint(
        "APPLY URL: $url",
      );

      debugPrint(
        "JOB ID: $jobId",
      );

      debugPrint(
        "TOKEN EXISTS: true",
      );

      final body = {
        "jobId": jobId,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      debugPrint(
        "Apply Status: ${response.statusCode}",
      );

      debugPrint(
        "Apply Response: ${response.body}",
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return true;
      }

      return false;
    } catch (e) {
      debugPrint(
        "Apply Error: $e",
      );

      return false;
    }
  }

  // =========================================================
  // GET MY APPLICATIONS
  // =========================================================

  Future<List<dynamic>> getMyApplications() async {
    try {
      final token =
      await authService.getToken();

      if (token == null || token.isEmpty) {
        debugPrint(
          "MY APPLICATIONS ERROR: No token",
        );

        return [];
      }

      final url =
          "$baseUrl/api/applications/my";

      debugPrint(
        "MY APPLICATIONS URL: $url",
      );

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      debugPrint(
        "My Applications Status: "
            "${response.statusCode}",
      );

      debugPrint(
        "My Applications Response: "
            "${response.body}",
      );

      if (response.statusCode == 200) {
        final data =
        jsonDecode(response.body);

        if (data is List) {
          return data;
        }

        return [];
      }

      return [];
    } catch (e) {
      debugPrint(
        "My Applications Error: $e",
      );

      return [];
    }
  }
}