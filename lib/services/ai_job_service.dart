import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ai_job_match.dart';

class AiJobService {
  final String baseUrl = 'https://YOUR-JAVA-BACKEND-URL';

  Future<List<AiJobMatch>> getRecommendedJobs(int applicantId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/applicants/$applicantId/recommended-jobs'),
    );

    if (response.statusCode != 200) {
      throw Exception('Could not load AI job recommendations');
    }

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => AiJobMatch.fromJson(item)).toList();
  }
}