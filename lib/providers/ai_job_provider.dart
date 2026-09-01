import 'package:flutter/material.dart';
import '../models/ai_job_match.dart';
import '../services/ai_job_service.dart';

class AiJobProvider extends ChangeNotifier {
  final AiJobService _service = AiJobService();

  List<AiJobMatch> jobs = [];
  bool isLoading = false;
  String? error;

  Future<void> loadRecommendations(int applicantId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      jobs = await _service.getRecommendedJobs(applicantId);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}