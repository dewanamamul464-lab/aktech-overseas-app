import 'package:flutter/material.dart';

import '../models/job_model.dart';
import 'job_card.dart';

class VerifiedJobs extends StatelessWidget {
  final List<Job> jobs;

  const VerifiedJobs({
    super.key,
    required this.jobs,
  });

  @override
  Widget build(BuildContext context) {
    final verifiedJobs =
    jobs.where((job) => job.verified).toList();

    if (verifiedJobs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text("No verified jobs available."),
        ),
      );
    }

    return Column(
      children: verifiedJobs
          .map(
            (job) => JobCard(
          job: job,
          onTap: () {},
        ),
      )
          .toList(),
    );
  }
}