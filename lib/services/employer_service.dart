import 'dart:convert';
import '../config/api_config.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EmployerService {
  // =========================================================
  // BASE URL
  // =========================================================

  final String baseUrl = ApiConfig.baseUrl;

  // =========================================================
  // GET JWT TOKEN
  // =========================================================

  Future<String?> _getToken() async {
    final prefs =
    await SharedPreferences.getInstance();

    final token =
    prefs.getString("token");

    if (token == null || token.isEmpty) {
      print(
        "EMPLOYER SERVICE: JWT TOKEN NOT FOUND",
      );

      return null;
    }

    return token;
  }

  // =========================================================
  // AUTH HEADERS
  // =========================================================

  Future<Map<String, String>?> _headers() async {
    final token =
    await _getToken();

    if (token == null) {
      return null;
    }

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // =========================================================
  // GET CURRENT EMPLOYER PROFILE
  // GET /api/employer/me
  // =========================================================

  Future<Map<String, dynamic>?> getMyProfile() async {
    try {
      final headers =
      await _headers();

      if (headers == null) {
        return null;
      }

      final url = Uri.parse(
        "$baseUrl/api/employer/me",
      );

      final response =
      await http.get(
        url,
        headers: headers,
      );

      print(
        "EMPLOYER PROFILE STATUS: "
            "${response.statusCode}",
      );

      print(
        "EMPLOYER PROFILE RESPONSE: "
            "${response.body}",
      );

      if (response.statusCode == 200) {
        final data =
        jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          return data;
        }
      }

      return null;
    } catch (e) {
      print(
        "GET EMPLOYER PROFILE ERROR: $e",
      );

      return null;
    }
  }

  // =========================================================
  // GET EMPLOYER ID
  // =========================================================

  Future<int?> getEmployerId() async {
    try {
      final profile =
      await getMyProfile();

      if (profile == null) {
        return null;
      }

      final id =
      profile["id"];

      if (id == null) {
        return null;
      }

      return int.tryParse(
        id.toString(),
      );
    } catch (e) {
      print(
        "GET EMPLOYER ID ERROR: $e",
      );

      return null;
    }
  }

  // =========================================================
  // GET MY JOBS
  // GET /api/employer/{employerId}/jobs
  // =========================================================

  Future<List<dynamic>?> getMyJobs(
      int employerId,
      ) async {
    try {
      final headers =
      await _headers();

      if (headers == null) {
        return null;
      }

      final url = Uri.parse(
        "$baseUrl/api/employer/"
            "$employerId/jobs",
      );

      final response =
      await http.get(
        url,
        headers: headers,
      );

      print(
        "MY JOBS STATUS: "
            "${response.statusCode}",
      );

      if (response.statusCode == 200) {
        final data =
        jsonDecode(response.body);

        if (data is List) {
          return data;
        }
      }

      return null;
    } catch (e) {
      print(
        "GET MY JOBS ERROR: $e",
      );

      return null;
    }
  }

  // =========================================================
  // POST JOB
  // =========================================================

  Future<Map<String, dynamic>?> postJob({
    required int employerId,
    required Map<String, dynamic> jobData,
  }) async {
    try {
      final headers =
      await _headers();

      if (headers == null) {
        return null;
      }

      final url = Uri.parse(
        "$baseUrl/api/employer/"
            "$employerId/jobs",
      );

      final response =
      await http.post(
        url,
        headers: headers,
        body: jsonEncode(jobData),
      );

      print(
        "POST JOB STATUS: "
            "${response.statusCode}",
      );

      print(
        "POST JOB RESPONSE: "
            "${response.body}",
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {

        final data =
        jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          return data;
        }
      }

      return null;
    } catch (e) {
      print(
        "POST JOB ERROR: $e",
      );

      return null;
    }
  }

  // =========================================================
  // GET APPLICATIONS
  // =========================================================

  Future<List<dynamic>?> getApplications(
      int employerId,
      ) async {
    try {
      final headers =
      await _headers();

      if (headers == null) {
        return null;
      }

      final url = Uri.parse(
        "$baseUrl/api/employer/"
            "$employerId/applications",
      );

      final response =
      await http.get(
        url,
        headers: headers,
      );

      print(
        "APPLICATIONS STATUS: "
            "${response.statusCode}",
      );

      print(
        "APPLICATIONS RESPONSE: "
            "${response.body}",
      );

      if (response.statusCode == 200) {
        final data =
        jsonDecode(response.body);

        if (data is List) {
          return data;
        }
      }

      return null;
    } catch (e) {
      print(
        "GET APPLICATIONS ERROR: $e",
      );

      return null;
    }
  }

  // =========================================================
  // GET FULL APPLICANT DETAILS
  //
  // GET
  // /api/employer/{employerId}/applications/{applicationId}/applicant
  // =========================================================

  Future<Map<String, dynamic>?> getApplicantDetails({
    required int employerId,
    required int applicationId,
  }) async {
    try {
      final headers =
      await _headers();

      if (headers == null) {
        return null;
      }

      final url = Uri.parse(
        "$baseUrl/api/employer/"
            "$employerId/applications/"
            "$applicationId/applicant",
      );

      print(
        "=================================",
      );

      print(
        "GET APPLICANT DETAILS",
      );

      print(
        "EMPLOYER ID: $employerId",
      );

      print(
        "APPLICATION ID: $applicationId",
      );

      print(
        "URL: $url",
      );

      print(
        "=================================",
      );

      final response =
      await http.get(
        url,
        headers: headers,
      );

      print(
        "APPLICANT DETAILS STATUS: "
            "${response.statusCode}",
      );

      print(
        "APPLICANT DETAILS RESPONSE: "
            "${response.body}",
      );

      if (response.statusCode == 200) {
        final data =
        jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          return data;
        }
      }

      return null;
    } catch (e) {
      print(
        "GET APPLICANT DETAILS ERROR: $e",
      );

      return null;
    }
  }

  // =========================================================
  // APPROVE APPLICATION
  //
  // PUT
  // /api/employer/{employerId}/applications/{applicationId}/approve
  // =========================================================

  Future<bool> approveApplication({
    required int employerId,
    required int applicationId,
  }) async {
    try {
      final headers =
      await _headers();

      if (headers == null) {
        return false;
      }

      final url = Uri.parse(
        "$baseUrl/api/employer/"
            "$employerId/applications/"
            "$applicationId/approve",
      );

      print(
        "APPROVE APPLICATION URL: $url",
      );

      final response =
      await http.put(
        url,
        headers: headers,
      );

      print(
        "APPROVE STATUS: "
            "${response.statusCode}",
      );

      print(
        "APPROVE RESPONSE: "
            "${response.body}",
      );

      return response.statusCode == 200;
    } catch (e) {
      print(
        "APPROVE APPLICATION ERROR: $e",
      );

      return false;
    }
  }

  // =========================================================
  // REJECT APPLICATION
  //
  // PUT
  // /api/employer/{employerId}/applications/{applicationId}/reject
  // =========================================================

  Future<bool> rejectApplication({
    required int employerId,
    required int applicationId,
  }) async {
    try {
      final headers =
      await _headers();

      if (headers == null) {
        return false;
      }

      final url = Uri.parse(
        "$baseUrl/api/employer/"
            "$employerId/applications/"
            "$applicationId/reject",
      );

      print(
        "REJECT APPLICATION URL: $url",
      );

      final response =
      await http.put(
        url,
        headers: headers,
      );

      print(
        "REJECT STATUS: "
            "${response.statusCode}",
      );

      print(
        "REJECT RESPONSE: "
            "${response.body}",
      );

      return response.statusCode == 200;
    } catch (e) {
      print(
        "REJECT APPLICATION ERROR: $e",
      );

      return false;
    }
  }

  // =========================================================
  // GET DASHBOARD DATA
  // =========================================================

  Future<Map<String, dynamic>?> getDashboardData() async {
    try {
      final profile =
      await getMyProfile();

      if (profile == null) {
        return null;
      }

      final employerIdValue =
      profile["id"];

      if (employerIdValue == null) {
        return null;
      }

      final employerId =
      int.tryParse(
        employerIdValue.toString(),
      );

      if (employerId == null) {
        return null;
      }

      final jobs =
      await getMyJobs(
        employerId,
      );

      final applications =
      await getApplications(
        employerId,
      );

      return {
        "profile": profile,
        "employerId": employerId,
        "jobs": jobs ?? [],
        "applications":
        applications ?? [],
      };
    } catch (e) {
      print(
        "GET DASHBOARD DATA ERROR: $e",
      );

      return null;
    }
  }
}