import 'package:flutter/material.dart';

import '../models/job_model.dart';
import '../services/saved_job_service.dart';
import '../widgets/job_card.dart';
import 'job_details_screen.dart';

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({super.key});

  @override
  State<SavedJobsScreen> createState() =>
      _SavedJobsScreenState();
}

class _SavedJobsScreenState
    extends State<SavedJobsScreen> {
  final SavedJobService savedJobService =
  SavedJobService();

  List<Job> savedJobs = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSavedJobs();
  }

  // =========================================================
  // LOAD SAVED JOBS
  // =========================================================

  Future<void> loadSavedJobs() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final result =
      await savedJobService.getSavedJobs();

      if (!mounted) return;

      setState(() {
        savedJobs = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load saved jobs: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================================
  // OPEN JOB DETAILS
  // =========================================================

  void openJobDetails(Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobDetailsScreen(
          job: job,
        ),
      ),
    ).then((_) {
      loadSavedJobs();
    });
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text(
          'Saved Jobs',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
            isLoading ? null : loadSavedJobs,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : savedJobs.isEmpty
          ? _emptyState()
          : RefreshIndicator(
        onRefresh: loadSavedJobs,
        child: ListView.builder(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            top: 12,
            bottom: 30,
          ),
          itemCount: savedJobs.length,
          itemBuilder:
              (context, index) {
            final job =
            savedJobs[index];

            return JobCard(
              job: job,
              onTap: () =>
                  openJobDetails(job),
            );
          },
        ),
      ),
    );
  }

  // =========================================================
  // EMPTY STATE
  // =========================================================

  Widget _emptyState() {
    return RefreshIndicator(
      onRefresh: loadSavedJobs,
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height:
            MediaQuery.of(context).size.height *
                0.25,
          ),

          const Icon(
            Icons.bookmark_border,
            size: 85,
            color: Colors.grey,
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              'No Saved Jobs',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 40,
            ),
            child: Text(
              'Jobs you save will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ),

          const SizedBox(height: 25),

          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.work_outline,
              ),
              label: const Text(
                'Find Jobs',
              ),
            ),
          ),
        ],
      ),
    );
  }
}