import 'package:flutter/material.dart';

import '../models/job_model.dart';
import 'job_card.dart';

class FeaturedJobs extends StatelessWidget {
  final List<Job> jobs;

  const FeaturedJobs({
    super.key,
    required this.jobs,
  });

  @override
  Widget build(BuildContext context) {
    final featured = jobs.take(5).toList();

    if (featured.isEmpty) {
      return const SizedBox();
    }

    return Column(
      children: featured
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