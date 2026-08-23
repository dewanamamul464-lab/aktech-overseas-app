import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class RegisterService {
  // =========================================================
  // API BASE URL
  // =========================================================

  final String baseUrl = ApiConfig.baseUrl;

  // =========================================================
  // REGISTER APPLICANT
  // =========================================================

  Future<String?> register({
    required String fullName,
    required String email,
    required String phone,
    required String username,
    required String password,
  }) async {
    try {
      final url = "$baseUrl/auth/register";

      print("");
      print("========================================");
      print("APPLICANT REGISTER");
      print("========================================");
      print("REGISTER URL: $url");
      print("Username: $username");
      print("Email: $email");
      print("========================================");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "fullName": fullName,
          "email": email,
          "phone": phone,
          "username": username,
          "password": password,
        }),
      );

      print(
        "REGISTER STATUS: ${response.statusCode}",
      );

      print(
        "REGISTER RESPONSE: ${response.body}",
      );

      print("========================================");

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        print("APPLICANT REGISTRATION SUCCESSFUL");
        return null;
      }

      print("APPLICANT REGISTRATION FAILED");

      return _extractError(response.body);
    } catch (e) {
      print("");
      print("========================================");
      print("APPLICANT REGISTER NETWORK ERROR");
      print("========================================");
      print(e);
      print("========================================");

      return "Unable to connect to server: $e";
    }
  }

  // =========================================================
  // REGISTER EMPLOYER
  // =========================================================

  Future<String?> registerEmployer({
    required String username,
    required String password,
    required String companyName,
    required String contactPerson,
    required String email,
    required String phone,
    required String country,
    required String address,
    String registrationNumber = "",
    String description = "",
  }) async {
    try {
      final url = "$baseUrl/auth/register-employer";

      print("");
      print("========================================");
      print("EMPLOYER REGISTER");
      print("========================================");
      print("EMPLOYER REGISTER URL: $url");
      print("Username: $username");
      print("Company: $companyName");
      print("Email: $email");
      print("========================================");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "username": username,
          "password": password,
          "companyName": companyName,
          "contactPerson": contactPerson,
          "email": email,
          "phone": phone,
          "country": country,
          "address": address,
          "registrationNumber": registrationNumber,
          "description": description,
        }),
      );

      print(
        "EMPLOYER REGISTER STATUS: "
            "${response.statusCode}",
      );

      print(
        "EMPLOYER REGISTER RESPONSE: "
            "${response.body}",
      );

      print("========================================");

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        print("EMPLOYER REGISTRATION SUCCESSFUL");
        return null;
      }

      print("EMPLOYER REGISTRATION FAILED");

      return _extractError(response.body);
    } catch (e) {
      print("");
      print("========================================");
      print("EMPLOYER REGISTER NETWORK ERROR");
      print("========================================");
      print(e);
      print("========================================");

      return "Unable to connect to server: $e";
    }
  }

  // =========================================================
  // EXTRACT BACKEND ERROR
  // =========================================================

  String _extractError(String responseBody) {
    try {
      final data = jsonDecode(responseBody);

      if (data is Map<String, dynamic>) {
        final message = data["message"];

        if (message != null &&
            message.toString().trim().isNotEmpty) {
          return message.toString();
        }

        final error = data["error"];

        if (error != null &&
            error.toString().trim().isNotEmpty) {
          return error.toString();
        }
      }

      if (responseBody.trim().isNotEmpty) {
        return responseBody;
      }

      return "Registration failed";
    } catch (_) {
      if (responseBody.trim().isNotEmpty) {
        return responseBody;
      }

      return "Registration failed";
    }
  }
}