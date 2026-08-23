import 'package:flutter/material.dart';

import '../models/job_model.dart';
import 'job_card.dart';

class LatestJobs extends StatelessWidget {
  final List<Job> jobs;

  const LatestJobs({
    super.key,
    required this.jobs,
  });

  @override
  Widget build(BuildContext context) {
    final latest = [...jobs];

    latest.sort((a, b) => b.id.compareTo(a.id));

    return Column(
      children: latest
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