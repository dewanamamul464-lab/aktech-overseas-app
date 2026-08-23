import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

class CvService {
  // =========================================================
  // BACKEND URL
  // =========================================================
  //
  // Managed centrally through ApiConfig.
  //
  static String get baseUrl => ApiConfig.baseUrl;

  // =========================================================
  // UPLOAD CV
  // =========================================================

  Future<bool> uploadCV(File file) async {
    try {
      final prefs =
      await SharedPreferences.getInstance();

      final String? token =
      prefs.getString("token");

      if (token == null || token.isEmpty) {
        print("UPLOAD CV: JWT token missing");
        return false;
      }

      final request = http.MultipartRequest(
        "POST",
        Uri.parse(
          "$baseUrl/api/applicants/upload-cv",
        ),
      );

      request.headers["Authorization"] =
      "Bearer $token";

      request.files.add(
        await http.MultipartFile.fromPath(
          "file",
          file.path,
        ),
      );

      final response =
      await request.send();

      final body =
      await response.stream.bytesToString();

      print(
        "CV Upload Status: ${response.statusCode}",
      );

      print(
        "CV Upload Response: $body",
      );

      return response.statusCode == 200;
    } catch (e) {
      print(
        "Upload CV Error: $e",
      );

      return false;
    }
  }

  // =========================================================
  // GET MY CV
  // =========================================================

  Future<String?> getMyCV() async {
    try {
      final prefs =
      await SharedPreferences.getInstance();

      final String? token =
      prefs.getString("token");

      if (token == null || token.isEmpty) {
        return null;
      }

      final response =
      await http.get(
        Uri.parse(
          "$baseUrl/api/applicants/me/cv",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data =
        jsonDecode(response.body);

        return data["cvUrl"]?.toString();
      }

      return null;
    } catch (e) {
      print(
        "Get CV Error: $e",
      );

      return null;
    }
  }
}