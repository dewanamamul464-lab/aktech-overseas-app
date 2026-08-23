import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/job_model.dart';

class JobService {
  // =========================================================
  // BACKEND URL
  // =========================================================

  static String get baseUrl => ApiConfig.baseUrl;

  // =========================================================
  // PAGE SIZE
  // =========================================================

  static const int defaultPageSize = 20;

  // =========================================================
  // GET TOKEN
  // =========================================================

  Future<String?> _getToken() async {
    final prefs =
    await SharedPreferences.getInstance();

    return prefs.getString('token');
  }

  // =========================================================
  // GET HEADERS
  // =========================================================

  Future<Map<String, String>> _getHeaders() async {
    final token =
    await _getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',

      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  // =========================================================
  // GET JOB PAGE
  // =========================================================
  //
  // IMPORTANT:
  //
  // Search is now performed by Spring Boot.
  //
  // Therefore:
  //
  // search = "engineer"
  //
  // searches ALL jobs in PostgreSQL.
  //
  // Flutter receives only the requested page.
  // =========================================================

  Future<JobPage> getJobsPage({
    int page = 0,
    int size = defaultPageSize,
    String search = '',
    String? jobType,
  }) async {
    try {
      final queryParameters =
      <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };

      // -------------------------------------------------------
      // SEARCH
      // -------------------------------------------------------

      final cleanSearch =
      search.trim();

      if (cleanSearch.isNotEmpty) {
        queryParameters['search'] =
            cleanSearch;
      }

      // -------------------------------------------------------
      // JOB TYPE
      // -------------------------------------------------------

      if (jobType != null &&
          jobType.trim().isNotEmpty &&
          jobType.toUpperCase() != 'ALL') {
        queryParameters['jobType'] =
            jobType.trim().toUpperCase();
      }

      final uri = Uri.parse(
        '$baseUrl/api/jobs',
      ).replace(
        queryParameters:
        queryParameters,
      );

      print('======================================');
      print('GET JOBS PAGE');
      print('PAGE: $page');
      print('SIZE: $size');
      print('SEARCH: $cleanSearch');
      print('JOB TYPE: $jobType');
      print('URL: $uri');
      print('======================================');

      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );

      print('======================================');
      print('JOBS RESPONSE');
      print('STATUS: ${response.statusCode}');
      print('PAGE: $page');
      print('======================================');

      // =====================================================
      // UNAUTHORIZED
      // =====================================================

      if (response.statusCode == 401) {
        throw Exception(
          'Authentication required. Please login again.',
        );
      }

      // =====================================================
      // FORBIDDEN
      // =====================================================

      if (response.statusCode == 403) {
        throw Exception(
          'You do not have permission to view jobs.',
        );
      }

      // =====================================================
      // OTHER ERRORS
      // =====================================================

      if (response.statusCode != 200) {
        throw Exception(
          'Unable to load jobs. '
              'Server returned ${response.statusCode}.',
        );
      }

      // =====================================================
      // DECODE
      // =====================================================

      final dynamic decoded =
      jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception(
          'Invalid response from server.',
        );
      }

      // =====================================================
      // CONTENT
      // =====================================================

      final dynamic content =
      decoded['content'];

      if (content is! List) {
        throw Exception(
          'No jobs found in server response.',
        );
      }

      // =====================================================
      // CONVERT TO JOB
      // =====================================================

      final List<Job> jobs = [];

      for (final item in content) {
        if (item is Map<String, dynamic>) {
          try {
            jobs.add(
              Job.fromJson(item),
            );
          } catch (e) {
            print(
              'JOB PARSE ERROR: $e',
            );
          }
        }
      }

      // =====================================================
      // LAST PAGE
      // =====================================================

      bool isLastPage = false;

      if (decoded['last'] is bool) {
        isLastPage =
        decoded['last'] as bool;
      } else {
        isLastPage =
            jobs.length < size;
      }

      // =====================================================
      // TOTAL ELEMENTS
      // =====================================================

      int totalElements = 0;

      if (decoded['totalElements'] is int) {
        totalElements =
        decoded['totalElements'] as int;
      } else if (decoded['totalElements'] is num) {
        totalElements =
            (decoded['totalElements'] as num)
                .toInt();
      }

      print(
        'JOBS LOADED: ${jobs.length}',
      );

      print(
        'TOTAL MATCHING JOBS: $totalElements',
      );

      print(
        'LAST PAGE: $isLastPage',
      );

      return JobPage(
        jobs: jobs,
        page: page,
        isLastPage: isLastPage,
        totalElements: totalElements,
      );
    } catch (e) {
      print('======================================');
      print('GET JOBS PAGE ERROR');
      print(e);
      print('======================================');

      rethrow;
    }
  }

  // =========================================================
  // GET INITIAL JOBS
  // =========================================================

  Future<List<Job>> getInitialJobs({
    int size = defaultPageSize,
  }) async {
    final result =
    await getJobsPage(
      page: 0,
      size: size,
    );

    return result.jobs;
  }

  // =========================================================
  // GET ALL JOBS
  // =========================================================
  //
  // Compatibility method.
  //
  // This should NOT be used by JobsScreen.
  // =========================================================

  Future<List<Job>> getJobs() async {
    const int pageSize = 100;

    final List<Job> allJobs = [];

    int page = 0;

    while (true) {
      final result =
      await getJobsPage(
        page: page,
        size: pageSize,
      );

      allJobs.addAll(
        result.jobs,
      );

      if (result.isLastPage ||
          result.jobs.isEmpty) {
        break;
      }

      page++;
    }

    return allJobs;
  }

  // =========================================================
  // GET FOREIGN JOBS
  // =========================================================

  Future<List<Job>> getForeignJobs() async {
    final List<Job> jobs = [];

    int page = 0;

    while (true) {
      final result =
      await getJobsPage(
        page: page,
        size: 100,
        jobType: 'FOREIGN',
      );

      jobs.addAll(
        result.jobs,
      );

      if (result.isLastPage ||
          result.jobs.isEmpty) {
        break;
      }

      page++;
    }

    return jobs;
  }

  // =========================================================
  // GET DOMESTIC JOBS
  // =========================================================

  Future<List<Job>> getDomesticJobs() async {
    final List<Job> jobs = [];

    int page = 0;

    while (true) {
      final result =
      await getJobsPage(
        page: page,
        size: 100,
        jobType: 'DOMESTIC',
      );

      jobs.addAll(
        result.jobs,
      );

      if (result.isLastPage ||
          result.jobs.isEmpty) {
        break;
      }

      page++;
    }

    return jobs;
  }
}

// =============================================================
// JOB PAGE
// =============================================================

class JobPage {
  final List<Job> jobs;

  final int page;

  final bool isLastPage;

  final int totalElements;

  const JobPage({
    required this.jobs,
    required this.page,
    required this.isLastPage,
    this.totalElements = 0,
  });
}