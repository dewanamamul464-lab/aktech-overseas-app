
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
print('========================================');
print('AI JOB SERVICE: START');
print('Applicant ID: $applicantId');
print(
'URL: $baseUrl/api/applicants/$applicantId/recommended-jobs',
);
print('========================================');

try {
// ============================================================
// GET SAVED JWT TOKEN
// ============================================================

final prefs = await SharedPreferences.getInstance();
final token = prefs.getString('token');

print('AI JOB SERVICE: Checking authentication token...');

if (token == null || token.isEmpty) {
print('AI JOB SERVICE: TOKEN NOT FOUND');

throw Exception('Please log in again.');
}

print('AI JOB SERVICE: TOKEN EXISTS');
print('AI JOB SERVICE: TOKEN LENGTH: ${token.length}');

// ============================================================
// SEND REQUEST
// ============================================================

final requestUrl =
'$baseUrl/api/applicants/$applicantId/recommended-jobs';

print('========================================');
print('AI JOB REQUEST');
print('Method: GET');
print('Applicant ID: $applicantId');
print('URL: $requestUrl');
print('Authorization: Bearer [HIDDEN]');
print('Sending request...');
print('========================================');

final response = await http.get(
Uri.parse(requestUrl),
headers: {
'Content-Type': 'application/json',
'Authorization': 'Bearer $token',
},
);

// ============================================================
// RESPONSE DEBUGGING
// ============================================================

print('========================================');
print('AI JOB RESPONSE');
print('Status: ${response.statusCode}');
print('Response Length: ${response.body.length}');
print('Response Body: ${response.body}');
print('========================================');

// ============================================================
// ERROR RESPONSE
// ============================================================

if (response.statusCode != 200) {
print('========================================');
print('AI JOB RECOMMENDATION ERROR');
print('Status: ${response.statusCode}');
print('Response: ${response.body}');
print('========================================');

if (response.statusCode == 401) {
throw Exception(
'Authentication failed. Please log in again.',
);
}

if (response.statusCode == 403) {
throw Exception(
'You are not authorized to view these recommendations.',
);
}

if (response.statusCode == 404) {
throw Exception(
'Recommendation endpoint was not found.',
);
}

if (response.statusCode >= 500) {
throw Exception(
'Server error while loading recommendations.',
);
}

throw Exception(
'Could not load recommendations '
'(status ${response.statusCode}).',
);
}

// ============================================================
// EMPTY RESPONSE CHECK
// ============================================================

if (response.body.trim().isEmpty) {
print('AI JOB SERVICE: EMPTY RESPONSE');

return [];
}

// ============================================================
// DECODE JSON
// ============================================================

final dynamic decodedData = jsonDecode(response.body);

print('========================================');
print('AI JOB JSON DECODED');
print('Data type: ${decodedData.runtimeType}');
print('========================================');

if (decodedData is! List) {
print('AI JOB SERVICE: INVALID RESPONSE FORMAT');
print('Expected: List');
print('Received: ${decodedData.runtimeType}');

throw Exception(
'Invalid recommendation response from server.',
);
}

final List<dynamic> data = decodedData;

print('AI JOB SERVICE: RECOMMENDATION COUNT: ${data.length}');

// ============================================================
// CONVERT JSON → AiJobMatch
// ============================================================

final List<AiJobMatch> recommendations = [];

for (int i = 0; i < data.length; i++) {
try {
final item = data[i];

print('----------------------------------------');
print('AI JOB #${i + 1}');
print('Raw data: $item');

if (item is! Map<String, dynamic>) {
print('Invalid item type: ${item.runtimeType}');
continue;
}

final job = AiJobMatch.fromJson(item);

print('Job ID: ${job.jobId}');
print('Title: ${job.title}');
print('Company: ${job.company}');
print('Match: ${job.matchPercentage}%');
print('Matched skills: ${job.matchedSkills}');
print('Missing skills: ${job.missingSkills}');

recommendations.add(job);
} catch (e) {
print('========================================');
print('AI JOB MODEL PARSE ERROR');
print('Job index: $i');
print('Error: $e');
print('Raw item: ${data[i]}');
print('========================================');
}
}

// ============================================================
// FINAL RESULT
// ============================================================

print('========================================');
print('AI JOB SERVICE: COMPLETE');
print(
'Recommendations successfully loaded: '
'${recommendations.length}',
);
print('========================================');

return recommendations;
} catch (e) {
print('========================================');
print('AI JOB SERVICE EXCEPTION');
print('Error: $e');
print('========================================');

rethrow;
}
}
}

