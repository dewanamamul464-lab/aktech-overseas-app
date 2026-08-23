import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/profile.dart';

class ProfileService {
  // =========================================================
  // GET CURRENT USER PROFILE
  // =========================================================

  Future<Profile?> getProfile() async {
    try {
      final prefs =
      await SharedPreferences.getInstance();

      final token =
      prefs.getString("token");

      print("");
      print("========================================");
      print("PROFILE REQUEST");
      print("========================================");

      // -------------------------------------------------------
      // CHECK TOKEN
      // -------------------------------------------------------

      if (token == null || token.isEmpty) {
        print(
          "Profile Error: JWT token not found",
        );
        print("========================================");

        return null;
      }

      print("Token exists: YES");

      // -------------------------------------------------------
      // BUILD URL
      // -------------------------------------------------------

      final url =
          "${ApiConfig.baseUrl}/api/applicants/me";

      final uri = Uri.parse(url);

      print(
        "PROFILE API URL: $url",
      );

      print(
        "PROFILE HOST: ${uri.host}",
      );

      print(
        "PROFILE PORT: ${uri.port}",
      );

      print(
        "PROFILE PATH: ${uri.path}",
      );

      // -------------------------------------------------------
      // SEND REQUEST
      // -------------------------------------------------------

      print(
        "Sending GET request...",
      );

      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      // -------------------------------------------------------
      // RESPONSE
      // -------------------------------------------------------

      print(
        "Profile Status: ${response.statusCode}",
      );

      print(
        "Profile Response: ${response.body}",
      );

      print("========================================");

      // -------------------------------------------------------
      // SUCCESS
      // -------------------------------------------------------

      if (response.statusCode == 200) {
        try {
          final data =
          jsonDecode(response.body);

          return Profile.fromJson(data);
        } catch (e) {
          print(
            "Profile JSON Error: $e",
          );

          return null;
        }
      }

      // -------------------------------------------------------
      // UNAUTHORIZED
      // -------------------------------------------------------

      if (response.statusCode == 401) {
        print(
          "Profile Error: Authentication failed.",
        );

        print(
          "The JWT token may have expired.",
        );

        return null;
      }

      // -------------------------------------------------------
      // FORBIDDEN
      // -------------------------------------------------------

      if (response.statusCode == 403) {
        print(
          "Profile Error: Access denied.",
        );

        return null;
      }

      // -------------------------------------------------------
      // OTHER HTTP ERROR
      // -------------------------------------------------------

      print(
        "Profile Error: HTTP ${response.statusCode}",
      );

      return null;
    } on SocketException catch (e) {
      print("");
      print("========================================");
      print("PROFILE NETWORK ERROR");
      print("========================================");

      print(
        "SocketException: $e",
      );

      print(
        "Flutter could not reach:",
      );

      print(
        "${ApiConfig.baseUrl}/api/applicants/me",
      );

      print("========================================");

      return null;
    } on http.ClientException catch (e) {
      print("");
      print("========================================");
      print("PROFILE CLIENT ERROR");
      print("========================================");

      print(
        "ClientException: $e",
      );

      print("========================================");

      return null;
    } catch (e) {
      print("");
      print("========================================");
      print("PROFILE UNKNOWN ERROR");
      print("========================================");

      print(
        "Profile Error: $e",
      );

      print("========================================");

      return null;
    }
  }

  // =========================================================
  // UPLOAD PROFILE IMAGE
  // =========================================================

  Future<String?> uploadProfileImage(
      File image,
      ) async {
    try {
      final prefs =
      await SharedPreferences.getInstance();

      final token =
      prefs.getString("token");

      print("");
      print("========================================");
      print("PROFILE IMAGE UPLOAD");
      print("========================================");

      // -------------------------------------------------------
      // CHECK TOKEN
      // -------------------------------------------------------

      if (token == null || token.isEmpty) {
        print(
          "Image Upload Error: JWT token not found",
        );

        print("========================================");

        return null;
      }

      // -------------------------------------------------------
      // BUILD URL
      // -------------------------------------------------------

      final url =
          "${ApiConfig.baseUrl}/api/applicants/me/profile-image";

      final uri = Uri.parse(url);

      print(
        "PROFILE IMAGE UPLOAD URL: $url",
      );

      print(
        "IMAGE UPLOAD HOST: ${uri.host}",
      );

      print(
        "IMAGE UPLOAD PORT: ${uri.port}",
      );

      // -------------------------------------------------------
      // CREATE MULTIPART REQUEST
      // -------------------------------------------------------

      final request =
      http.MultipartRequest(
        "POST",
        uri,
      );

      request.headers["Authorization"] =
      "Bearer $token";

      request.headers["Accept"] =
      "application/json";

      // -------------------------------------------------------
      // ADD IMAGE
      // -------------------------------------------------------

      request.files.add(
        await http.MultipartFile.fromPath(
          "file",
          image.path,
        ),
      );

      print(
        "Sending image upload request...",
      );

      // -------------------------------------------------------
      // SEND REQUEST
      // -------------------------------------------------------

      final response =
      await request.send();

      print(
        "Image Upload Status: "
            "${response.statusCode}",
      );

      final responseBody =
      await response.stream.bytesToString();

      print(
        "Image Upload Response: "
            "$responseBody",
      );

      print("========================================");

      // -------------------------------------------------------
      // SUCCESS
      // -------------------------------------------------------

      if (response.statusCode == 200) {
        try {
          final data =
          jsonDecode(responseBody);

          /*
           * Backend response:
           *
           * {
           *   "profileImage": "..."
           * }
           */

          final profileImage =
          data["profileImage"];

          if (profileImage != null) {
            return profileImage.toString();
          }

          print(
            "Image Upload Error: "
                "profileImage missing from response",
          );

          return null;
        } catch (e) {
          print(
            "Image Upload JSON Error: $e",
          );

          return null;
        }
      }

      // -------------------------------------------------------
      // UNAUTHORIZED
      // -------------------------------------------------------

      if (response.statusCode == 401) {
        print(
          "Image Upload Error: "
              "Authentication failed.",
        );

        return null;
      }

      // -------------------------------------------------------
      // FORBIDDEN
      // -------------------------------------------------------

      if (response.statusCode == 403) {
        print(
          "Image Upload Error: "
              "Access denied.",
        );

        return null;
      }

      // -------------------------------------------------------
      // OTHER HTTP ERROR
      // -------------------------------------------------------

      print(
        "Image Upload Error: "
            "HTTP ${response.statusCode}",
      );

      return null;
    } on SocketException catch (e) {
      print("");
      print("========================================");
      print("IMAGE UPLOAD NETWORK ERROR");
      print("========================================");

      print(
        "SocketException: $e",
      );

      print("========================================");

      return null;
    } on http.ClientException catch (e) {
      print("");
      print("========================================");
      print("IMAGE UPLOAD CLIENT ERROR");
      print("========================================");

      print(
        "ClientException: $e",
      );

      print("========================================");

      return null;
    } catch (e) {
      print("");
      print("========================================");
      print("IMAGE UPLOAD UNKNOWN ERROR");
      print("========================================");

      print(
        "Image Upload Error: $e",
      );

      print("========================================");

      return null;
    }
  }
}