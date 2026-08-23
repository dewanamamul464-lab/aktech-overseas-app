import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

class AuthService {
  // ============================================================
  // LOGIN
  // ============================================================

  Future<bool> login(
      String username,
      String password,
      ) async {
    try {
      final url =
      Uri.parse("${ApiConfig.baseUrl}/auth/login");

      print("======================================");
      print("LOGIN REQUEST");
      print("URL: $url");
      print("USERNAME: $username");
      print("======================================");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      print("======================================");
      print("LOGIN RESPONSE");
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
      print("======================================");

      // ========================================================
      // LOGIN FAILED
      // ========================================================

      if (response.statusCode != 200) {
        print("LOGIN FAILED");
        return false;
      }

      // ========================================================
      // DECODE RESPONSE
      // ========================================================

      final dynamic decoded =
      jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        print(
          "ERROR: Invalid login response format",
        );
        return false;
      }

      final Map<String, dynamic> data =
          decoded;

      // ========================================================
      // GET JWT
      // ========================================================

      String? token;

      if (data["token"] != null) {
        token = data["token"].toString();
      } else if (data["accessToken"] != null) {
        token =
            data["accessToken"].toString();
      } else if (data["jwt"] != null) {
        token =
            data["jwt"].toString();
      }

      if (token == null ||
          token.trim().isEmpty) {
        print(
          "ERROR: JWT TOKEN NOT FOUND",
        );
        return false;
      }

      // ========================================================
      // GET USERNAME
      // ========================================================

      String loggedInUsername = username;

      final dynamic userData =
      data["user"];

      if (userData is Map) {
        if (userData["username"] != null) {
          loggedInUsername =
              userData["username"].toString();
        }
      }

      // Some backend responses may return
      // username directly.

      if (data["username"] != null) {
        loggedInUsername =
            data["username"].toString();
      }

      // ========================================================
      // GET ROLE
      // ========================================================

      String role = "";

      // Example:
      //
      // {
      //   "user": {
      //      "username": "admin",
      //      "role": "ADMIN"
      //   }
      // }

      if (userData is Map) {
        if (userData["role"] != null) {
          role =
              userData["role"].toString();
        } else if (userData["roles"] != null) {
          final dynamic roles =
          userData["roles"];

          if (roles is List &&
              roles.isNotEmpty) {
            role =
                roles.first.toString();
          } else if (roles is String) {
            role = roles;
          }
        }
      }

      // Backend may also return role directly.

      if (role.isEmpty &&
          data["role"] != null) {
        role =
            data["role"].toString();
      }

      // Backend may return roles directly.

      if (role.isEmpty &&
          data["roles"] != null) {
        final dynamic roles =
        data["roles"];

        if (roles is List &&
            roles.isNotEmpty) {
          role =
              roles.first.toString();
        } else if (roles is String) {
          role = roles;
        }
      }

      // ========================================================
      // NORMALIZE ROLE
      // ========================================================

      role = role
          .replaceAll("ROLE_", "")
          .replaceAll("[", "")
          .replaceAll("]", "")
          .replaceAll('"', "")
          .trim()
          .toUpperCase();

      // ========================================================
      // SAVE LOGIN DATA
      // ========================================================

      final prefs =
      await SharedPreferences.getInstance();

      await prefs.setString(
        "token",
        token,
      );

      await prefs.setString(
        "username",
        loggedInUsername,
      );

      await prefs.setString(
        "role",
        role,
      );

      await prefs.setBool(
        "isLoggedIn",
        true,
      );

      // ========================================================
      // DEBUG
      // ========================================================

      print("======================================");
      print("LOGIN SUCCESS");
      print(
        "USERNAME: $loggedInUsername",
      );
      print("ROLE: $role");
      print(
        "TOKEN EXISTS: ${token.isNotEmpty}",
      );
      print(
        "TOKEN LENGTH: ${token.length}",
      );
      print("======================================");

      return true;
    } catch (e) {
      print("======================================");
      print("LOGIN ERROR");
      print(e);
      print("======================================");

      return false;
    }
  }

  // ============================================================
  // GET TOKEN
  // ============================================================

  Future<String?> getToken() async {
    final prefs =
    await SharedPreferences.getInstance();

    return prefs.getString("token");
  }

  // ============================================================
  // GET USERNAME
  // ============================================================

  Future<String?> getUsername() async {
    final prefs =
    await SharedPreferences.getInstance();

    return prefs.getString("username");
  }

  // ============================================================
  // GET ROLE
  // ============================================================

  Future<String?> getRole() async {
    final prefs =
    await SharedPreferences.getInstance();

    return prefs.getString("role");
  }

  // ============================================================
  // CHECK ADMIN
  // ============================================================

  Future<bool> isAdmin() async {
    final role =
    await getRole();

    if (role == null) {
      return false;
    }

    final normalizedRole = role
        .replaceAll("ROLE_", "")
        .trim()
        .toUpperCase();

    return normalizedRole == "ADMIN";
  }

  // ============================================================
  // CHECK LOGIN
  // ============================================================

  Future<bool> isLoggedIn() async {
    final prefs =
    await SharedPreferences.getInstance();

    final token =
    prefs.getString("token");

    return token != null &&
        token.isNotEmpty;
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    final prefs =
    await SharedPreferences.getInstance();

    // IMPORTANT:
    // Do NOT use prefs.clear().
    //
    // Your saved jobs use:
    //
    // saved_jobs_<username>
    //
    // Therefore saved jobs remain after logout.

    await prefs.remove("token");
    await prefs.remove("username");
    await prefs.remove("role");
    await prefs.remove("isLoggedIn");

    print("======================================");
    print("LOGOUT SUCCESS");
    print("TOKEN REMOVED");
    print("USERNAME REMOVED");
    print("ROLE REMOVED");
    print("SAVED JOBS KEPT");
    print("======================================");
  }
}