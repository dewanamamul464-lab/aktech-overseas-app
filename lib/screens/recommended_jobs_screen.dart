
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ai_job_match.dart';
import '../providers/ai_job_provider.dart';
import '../services/application_service.dart';
import '../services/job_service.dart';
import 'job_details_screen.dart';

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

class _RecommendedJobsScreenState
extends State<RecommendedJobsScreen> {
final ApplicationService _applicationService =
ApplicationService();

final JobService _jobService =
JobService();

// =========================================================
// TRACK JOBS CURRENTLY BEING APPLIED FOR
// =========================================================

final Set<int> _applyingJobIds = {};

// =========================================================
// LOAD RECOMMENDATIONS
// =========================================================

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
    .loadRecommendations(
widget.applicantId,
);
});
}

// =========================================================
// VIEW JOB
// =========================================================

Future<void> _openJobDetails(
AiJobMatch aiJob,
) async {
try {
print('========================================');
print('OPEN AI RECOMMENDED JOB');
print('JOB ID: ${aiJob.jobId}');
print('TITLE: ${aiJob.title}');
print('COMPANY: ${aiJob.company}');
print('========================================');

// -------------------------------------------------------
// SHOW LOADING DIALOG
// -------------------------------------------------------

showDialog(
context: context,
barrierDismissible: false,
builder: (_) {
return const Center(
child: CircularProgressIndicator(),
);
},
);

// -------------------------------------------------------
// GET COMPLETE JOB
// -------------------------------------------------------

final job =
await _jobService.getJobById(
aiJob.jobId,
);

if (!mounted) return;

// -------------------------------------------------------
// CLOSE LOADING
// -------------------------------------------------------

Navigator.of(context).pop();

// -------------------------------------------------------
// OPEN JOB DETAILS
// -------------------------------------------------------

Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
JobDetailsScreen(
job: job,
),
),
);
} catch (e) {
print('========================================');
print('OPEN JOB DETAILS ERROR');
print('JOB ID: ${aiJob.jobId}');
print('ERROR: $e');
print('========================================');

if (!mounted) return;

// -------------------------------------------------------
// CLOSE LOADING DIALOG IF OPEN
// -------------------------------------------------------

if (Navigator.of(context).canPop()) {
Navigator.of(context).pop();
}

// -------------------------------------------------------
// SHOW ERROR
// -------------------------------------------------------

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
'Could not load job details: $e',
),
),
);
}
}

// =========================================================
// APPLY FOR JOB
// =========================================================

Future<void> _applyForJob(
AiJobMatch job,
) async {
// -------------------------------------------------------
// PREVENT DOUBLE TAP
// -------------------------------------------------------

if (_applyingJobIds.contains(job.jobId)) {
return;
}

setState(() {
_applyingJobIds.add(job.jobId);
});

print('========================================');
print('AI RECOMMENDATION APPLY');
print('JOB ID: ${job.jobId}');
print('TITLE: ${job.title}');
print('COMPANY: ${job.company}');
print('========================================');

try {
final success =
await _applicationService.applyJob(
job.jobId,
);

if (!mounted) return;

if (success) {
print('========================================');
print('APPLICATION SUCCESS');
print('JOB ID: ${job.jobId}');
print('========================================');

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
'Application submitted for ${job.title}',
),
duration: const Duration(
seconds: 3,
),
),
);
} else {
print('========================================');
print('APPLICATION FAILED');
print('JOB ID: ${job.jobId}');
print('========================================');

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Could not submit application. '
'Please try again.',
),
),
);
}
} catch (e) {
print('========================================');
print('APPLICATION ERROR');
print('JOB ID: ${job.jobId}');
print('ERROR: $e');
print('========================================');

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
'Application failed: $e',
),
),
);
} finally {
if (mounted) {
setState(() {
_applyingJobIds.remove(
job.jobId,
);
});
}
}
}

// =========================================================
// REFRESH
// =========================================================

Future<void> _refreshRecommendations() async {
await context
    .read<AiJobProvider>()
    .loadRecommendations(
widget.applicantId,
);
}

// =========================================================
// BUILD
// =========================================================

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text(
'AI Job Matches',
),
centerTitle: true,
),

body: Consumer<AiJobProvider>(
builder: (
context,
provider,
child,
) {
// ===================================================
// LOADING
// ===================================================

if (provider.isLoading) {
return const Center(
child: CircularProgressIndicator(),
);
}

// ===================================================
// ERROR
// ===================================================

if (provider.error != null) {
return Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
Icons.error_outline,
size: 64,
color: Colors.red.shade400,
),

const SizedBox(
height: 16,
),

const Text(
'Could not load recommendations',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),

const SizedBox(
height: 10,
),

Text(
provider.error!,
textAlign: TextAlign.center,
style: TextStyle(
color: Colors.grey.shade700,
),
),

const SizedBox(
height: 20,
),

ElevatedButton.icon(
onPressed:
_refreshRecommendations,
icon: const Icon(
Icons.refresh,
),
label: const Text(
'Try Again',
),
),
],
),
),
);
}

// ===================================================
// EMPTY
// ===================================================

if (provider.jobs.isEmpty) {
return RefreshIndicator(
onRefresh:
_refreshRecommendations,
child: ListView(
physics:
const AlwaysScrollableScrollPhysics(),
children: const [
SizedBox(
height: 170,
),

Icon(
Icons.work_outline,
size: 70,
color: Colors.grey,
),

SizedBox(
height: 18,
),

Center(
child: Text(
'No AI job recommendations found yet.',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.w600,
),
),
),

SizedBox(
height: 8,
),

Padding(
padding:
EdgeInsets.symmetric(
horizontal: 35,
),
child: Text(
'Complete your profile and add relevant skills to get better job matches.',
textAlign: TextAlign.center,
),
),
],
),
);
}

// ===================================================
// RECOMMENDATION LIST
// ===================================================

return RefreshIndicator(
onRefresh:
_refreshRecommendations,
child: ListView.builder(
physics:
const AlwaysScrollableScrollPhysics(),
padding: const EdgeInsets.all(16),
itemCount:
provider.jobs.length,
itemBuilder: (
context,
index,
) {
final job =
provider.jobs[index];

final isApplying =
_applyingJobIds.contains(
job.jobId,
);

return _JobMatchCard(
job: job,
isApplying: isApplying,
onViewJob: () {
_openJobDetails(
job,
);
},
onApply: () {
_applyForJob(
job,
);
},
);
},
),
);
},
),
);
}
}

// =============================================================
// AI JOB MATCH CARD
// =============================================================

class _JobMatchCard
extends StatelessWidget {
final AiJobMatch job;

final bool isApplying;

final VoidCallback onViewJob;

final VoidCallback onApply;

const _JobMatchCard({
required this.job,
required this.isApplying,
required this.onViewJob,
required this.onApply,
});

// ===========================================================
// MATCH COLOR
// ===========================================================

Color _matchColor() {
if (job.matchPercentage >= 80) {
return Colors.green;
}

if (job.matchPercentage >= 60) {
return Colors.orange;
}

return Colors.red;
}

// ===========================================================
// BUILD
// ===========================================================

@override
Widget build(BuildContext context) {
final matchColor =
_matchColor();

return Card(
margin: const EdgeInsets.only(
bottom: 16,
),
elevation: 3,
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(16),
),
child: Padding(
padding:
const EdgeInsets.all(16),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [

// =================================================
// TITLE + MATCH PERCENTAGE
// =================================================

Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Expanded(
child: Text(
job.title,
style:
const TextStyle(
fontSize: 18,
fontWeight:
FontWeight.bold,
),
),
),

const SizedBox(
width: 8,
),

Container(
padding:
const EdgeInsets.symmetric(
horizontal: 10,
vertical: 6,
),
decoration:
BoxDecoration(
color:
matchColor.withValues(
alpha: 0.12,
),
borderRadius:
BorderRadius.circular(
20,
),
),
child: Text(
'${job.matchPercentage}% Match',
style: TextStyle(
color:
matchColor,
fontWeight:
FontWeight.bold,
fontSize: 12,
),
),
),
],
),

const SizedBox(
height: 8,
),

// =================================================
// COMPANY
// =================================================

Row(
children: [
Icon(
Icons.business_outlined,
size: 18,
color:
Colors.grey.shade600,
),

const SizedBox(
width: 6,
),

Expanded(
child: Text(
job.company,
style: TextStyle(
color:
Colors.grey.shade700,
fontSize: 15,
),
),
),
],
),

const Divider(
height: 28,
),

// =================================================
// AI REASON
// =================================================

const Text(
'Why AI recommends this job',
style: TextStyle(
fontWeight:
FontWeight.bold,
fontSize: 15,
),
),

const SizedBox(
height: 8,
),

Text(
job.reason,
style: TextStyle(
color:
Colors.grey.shade800,
height: 1.4,
),
),

// =================================================
// MATCHED SKILLS
// =================================================

if (job.matchedSkills
    .isNotEmpty) ...[
const SizedBox(
height: 16,
),

const Text(
'Matched Skills',
style: TextStyle(
fontWeight:
FontWeight.bold,
),
),

const SizedBox(
height: 8,
),

Wrap(
spacing: 6,
runSpacing: 6,
children: job
    .matchedSkills
    .map(
(skill) => Chip(
avatar:
const Icon(
Icons.check_circle,
size: 16,
color:
Colors.green,
),
label:
Text(skill),
),
)
    .toList(),
),
],

// =================================================
// MISSING SKILLS
// =================================================

if (job.missingSkills
    .isNotEmpty) ...[
const SizedBox(
height: 14,
),

const Text(
'Skills to Improve',
style: TextStyle(
fontWeight:
FontWeight.bold,
),
),

const SizedBox(
height: 8,
),

Wrap(
spacing: 6,
runSpacing: 6,
children: job
    .missingSkills
    .map(
(skill) => Chip(
avatar:
const Icon(
Icons.trending_up,
size: 16,
),
label:
Text(skill),
),
)
    .toList(),
),
],

const SizedBox(
height: 18,
),

// =================================================
// ACTION BUTTONS
// =================================================

Row(
children: [

// ---------------------------------------------
// VIEW JOB
// ---------------------------------------------

Expanded(
child:
OutlinedButton.icon(
onPressed:
isApplying
? null
    : onViewJob,
icon:
const Icon(
Icons
    .visibility_outlined,
),
label:
const Text(
'View Job',
),
),
),

const SizedBox(
width: 10,
),

// ---------------------------------------------
// APPLY
// ---------------------------------------------

Expanded(
child:
ElevatedButton.icon(
onPressed:
isApplying
? null
    : onApply,
icon: isApplying
? const SizedBox(
width: 16,
height: 16,
child:
CircularProgressIndicator(
strokeWidth:
2,
),
)
    : const Icon(
Icons
    .send_outlined,
),
label: Text(
isApplying
? 'Applying...'
    : 'Apply',
),
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

