import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ai_job_match.dart';
import '../providers/ai_job_provider.dart';

class RecommendedJobsScreen extends StatefulWidget {
  final int applicantId;

  const RecommendedJobsScreen({
    super.key,
    required this.applicantId,
  });

  @override
  State<RecommendedJobsScreen> createState() =>
      _RecommendedJobsScreenState();
}

class _RecommendedJobsScreenState extends State<RecommendedJobsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('========================================');
      print('AI RECOMMENDATIONS SCREEN');
      print('APPLICANT ID: ${widget.applicantId}');
      print('========================================');

      context
          .read<AiJobProvider>()
          .loadRecommendations(widget.applicantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Job Matches'),
      ),
      body: Consumer<AiJobProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load recommendations.\n${provider.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (provider.jobs.isEmpty) {
            return const Center(
              child: Text(
                'No AI job recommendations found yet.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                provider.loadRecommendations(widget.applicantId),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.jobs.length,
              itemBuilder: (context, index) {
                final job = provider.jobs[index];

                return _JobMatchCard(job: job);
              },
            ),
          );
        },
      ),
    );
  }
}

class _JobMatchCard extends StatelessWidget {
  final AiJobMatch job;

  const _JobMatchCard({
    required this.job,
  });

  Color _matchColor() {
    if (job.matchPercentage >= 80) return Colors.green;
    if (job.matchPercentage >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final matchColor = _matchColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: matchColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${job.matchPercentage}% Match',
                    style: TextStyle(
                      color: matchColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              job.company,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 15,
              ),
            ),
            const Divider(height: 24),

            const Text(
              'Why AI recommends this job',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(job.reason),

            const SizedBox(height: 16),
            if (job.matchedSkills.isNotEmpty) ...[
              const Text(
                'Matched skills',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: job.matchedSkills
                    .map(
                      (skill) => Chip(
                    label: Text(skill),
                    backgroundColor: Colors.green.shade50,
                  ),
                )
                    .toList(),
              ),
            ],

            if (job.missingSkills.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Skills to improve',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: job.missingSkills
                    .map(
                      (skill) => Chip(
                    label: Text(skill),
                    backgroundColor: Colors.orange.shade50,
                  ),
                )
                    .toList(),
              ),
            ],

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Later: Open your existing job-details screen.
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Open job ID: ${job.jobId}'),
                        ),
                      );
                    },
                    child: const Text('View Job'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Later: Open AI application review / Apply screen.
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Apply for ${job.title}'),
                        ),
                      );
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}