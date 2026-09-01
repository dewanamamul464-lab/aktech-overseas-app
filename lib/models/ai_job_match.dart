class AiJobMatch {
  final int jobId;
  final String title;
  final String company;
  final int matchPercentage;
  final List<String> matchedSkills;
  final List<String> missingSkills;
  final String reason;

  AiJobMatch({
    required this.jobId,
    required this.title,
    required this.company,
    required this.matchPercentage,
    required this.matchedSkills,
    required this.missingSkills,
    required this.reason,
  });

  factory AiJobMatch.fromJson(Map<String, dynamic> json) {
    return AiJobMatch(
      jobId: json['jobId'],
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      matchPercentage: json['matchPercentage'] ?? 0,
      matchedSkills: List<String>.from(json['matchedSkills'] ?? []),
      missingSkills: List<String>.from(json['missingSkills'] ?? []),
      reason: json['reason'] ?? '',
    );
  }
}