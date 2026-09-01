import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ai_job_match.dart';

class AiJobService {
  final String baseUrl =
      'https://aktech-overseas-backend.onrender.com';

  Future<List<AiJobMatch>> getRecommendedJobs(
      int applicantId,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Please log in again.');
    }

    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/applicants/$applicantId/recommended-jobs',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Could not load recommendations '
            '(status ${response.statusCode}).',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map(
          (item) => AiJobMatch.fromJson(item),
    )
        .toList();
  }
}