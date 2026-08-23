import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

class ProfileImageService {
  // =========================================================
  // BACKEND URL
  // =========================================================
  //
  // Managed centrally through ApiConfig.
  //
  static String get baseUrl => ApiConfig.baseUrl;

  // =========================================================
  // UPLOAD PROFILE IMAGE
  // =========================================================

  Future<String?> uploadProfileImage(
      File image,
      ) async {
    try {
      final prefs =
      await SharedPreferences.getInstance();

      final String? token =
      prefs.getString("token");

      if (token == null || token.isEmpty) {
        print(
          "PROFILE IMAGE: JWT token missing",
        );
        return null;
      }

      final request =
      http.MultipartRequest(
        "POST",
        Uri.parse(
          "$baseUrl/api/applicants/me/profile-image",
        ),
      );

      request.headers["Authorization"] =
      "Bearer $token";

      request.files.add(
        await http.MultipartFile.fromPath(
          "file",
          image.path,
        ),
      );

      final response =
      await request.send();

      final body =
      await response.stream.bytesToString();

      print(
        "Image Upload Status: "
            "${response.statusCode}",
      );

      print(
        "Image Upload Response: $body",
      );

      if (response.statusCode == 200) {
        final data =
        jsonDecode(body);

        if (data["profileImage"] != null) {
          return data["profileImage"].toString();
        }

        if (data["imageUrl"] != null) {
          return data["imageUrl"].toString();
        }
      }

      return null;
    } catch (e) {
      print(
        "Upload Profile Image Error: $e",
      );

      return null;
    }
  }
}