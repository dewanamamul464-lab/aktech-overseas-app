
import 'package:flutter/material.dart';

import '../models/ai_job_match.dart';
import '../services/ai_job_service.dart';

class AiJobProvider extends ChangeNotifier {
final AiJobService _service = AiJobService();

// ============================================================
// STATE
// ============================================================

List<AiJobMatch> jobs = [];

bool isLoading = false;

String? error;

// ============================================================
// LOAD AI JOB RECOMMENDATIONS
// ============================================================

Future<void> loadRecommendations(int applicantId) async {
print('========================================');
print('AI PROVIDER: loadRecommendations()');
print('Applicant ID: $applicantId');
print('========================================');

// Start loading
isLoading = true;
error = null;

notifyListeners();

try {
print('AI PROVIDER: Calling AiJobService...');

// ============================================================
// CALL API SERVICE
// ============================================================

final recommendations =
await _service.getRecommendedJobs(applicantId);

// ============================================================
// STORE RESULTS
// ============================================================

jobs = recommendations;

print('========================================');
print('AI PROVIDER: SERVICE SUCCESS');
print('Recommendations received: ${jobs.length}');
print('========================================');

// Print basic information about the results
for (int i = 0; i < jobs.length; i++) {
final job = jobs[i];

print(
'AI JOB ${i + 1}: '
'${job.title} | '
'${job.company} | '
'${job.matchPercentage}% match',
);
}
} catch (e) {
// ============================================================
// ERROR
// ============================================================

print('========================================');
print('AI PROVIDER ERROR');
print('Error: $e');
print('Error type: ${e.runtimeType}');
print('========================================');

error = e.toString();

// Clear old results if the new request failed
jobs = [];
} finally {
// ============================================================
// FINISH LOADING
// ============================================================

isLoading = false;

notifyListeners();

print('========================================');
print('AI PROVIDER: LOADING FINISHED');
print('isLoading: $isLoading');
print('Jobs: ${jobs.length}');
print('Error: $error');
print('========================================');
}
}

// ============================================================
// CLEAR RECOMMENDATIONS
// ============================================================

void clearRecommendations() {
jobs = [];
error = null;
isLoading = false;

notifyListeners();

print('AI PROVIDER: Recommendations cleared');
}
}

