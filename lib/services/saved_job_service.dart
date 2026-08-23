import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/job_model.dart';

class SavedJobService {
  // =========================================================
  // GET CURRENT USER KEY
  // =========================================================

  Future<String> _getSavedJobsKey() async {
    final prefs = await SharedPreferences.getInstance();

    // Try username first
    final username = prefs.getString("username");

    if (username != null && username.trim().isNotEmpty) {
      return "saved_jobs_${username.trim().toLowerCase()}";
    }

    // If username is not available, use email
    final email = prefs.getString("email");

    if (email != null && email.trim().isNotEmpty) {
      return "saved_jobs_${email.trim().toLowerCase()}";
    }

    // No logged-in user information
    // Use a temporary key rather than sharing saved jobs
    // between different users.
    return "saved_jobs_unknown";
  }

  // =========================================================
  // GET ALL SAVED JOBS
  // =========================================================

  Future<List<Job>> getSavedJobs() async {
    final prefs = await SharedPreferences.getInstance();

    final key = await _getSavedJobsKey();

    final savedData = prefs.getStringList(key) ?? [];

    return savedData
        .map((item) {
      try {
        return Job.fromJson(
          jsonDecode(item) as Map<String, dynamic>,
        );
      } catch (e) {
        return null;
      }
    })
        .whereType<Job>()
        .toList();
  }

  // =========================================================
  // CHECK IF JOB IS SAVED
  // =========================================================

  Future<bool> isJobSaved(int jobId) async {
    final jobs = await getSavedJobs();

    return jobs.any(
          (job) => job.id == jobId,
    );
  }

  // =========================================================
  // SAVE JOB
  // =========================================================

  Future<void> saveJob(Job job) async {
    final prefs = await SharedPreferences.getInstance();

    final key = await _getSavedJobsKey();

    final savedJobs = await getSavedJobs();

    // Prevent duplicate jobs
    if (savedJobs.any(
          (saved) => saved.id == job.id,
    )) {
      return;
    }

    savedJobs.add(job);

    final encodedJobs = savedJobs
        .map(
          (job) => jsonEncode(
        job.toJson(),
      ),
    )
        .toList();

    await prefs.setStringList(
      key,
      encodedJobs,
    );
  }

  // =========================================================
  // REMOVE JOB
  // =========================================================

  Future<void> removeJob(int jobId) async {
    final prefs = await SharedPreferences.getInstance();

    final key = await _getSavedJobsKey();

    final savedJobs = await getSavedJobs();

    savedJobs.removeWhere(
          (job) => job.id == jobId,
    );

    final encodedJobs = savedJobs
        .map(
          (job) => jsonEncode(
        job.toJson(),
      ),
    )
        .toList();

    await prefs.setStringList(
      key,
      encodedJobs,
    );
  }

  // =========================================================
  // TOGGLE SAVE / UNSAVE
  // =========================================================

  Future<bool> toggleSavedJob(Job job) async {
    final saved = await isJobSaved(job.id);

    if (saved) {
      await removeJob(job.id);
      return false;
    } else {
      await saveJob(job);
      return true;
    }
  }

  // =========================================================
  // CLEAR CURRENT USER'S SAVED JOBS
  // =========================================================

  Future<void> clearSavedJobs() async {
    final prefs = await SharedPreferences.getInstance();

    final key = await _getSavedJobsKey();

    await prefs.remove(key);
  }
}