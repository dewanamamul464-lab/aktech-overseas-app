import 'package:flutter/material.dart';

import '../models/job_model.dart';
import '../services/saved_job_service.dart';
import 'country_flag.dart';

class JobCard extends StatefulWidget {
  final Job job;
  final VoidCallback onTap;

  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  final SavedJobService _savedJobService =
  SavedJobService();

  bool _isSaved = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _checkSavedStatus();
  }

  // =========================================================
  // CHECK SAVED STATUS
  // =========================================================

  Future<void> _checkSavedStatus() async {
    try {
      final saved = await _savedJobService.isJobSaved(
        widget.job.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaved = saved;
      });
    } catch (_) {
      // Do not interrupt scrolling if saved status fails.
    }
  }

  // =========================================================
  // SAVE / REMOVE
  // =========================================================

  Future<void> _toggleSaveJob() async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final saved =
      await _savedJobService.toggleSavedJob(
        widget.job,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaved = saved;
        _isSaving = false;
      });

      _showMessage(
        saved
            ? 'Job saved successfully'
            : 'Job removed from saved jobs',
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        'Unable to save job',
      );
    }
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        duration: const Duration(
          seconds: 2,
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // =========================================================
  // DESCRIPTION PREVIEW
  // =========================================================
  //
  // IMPORTANT:
  //
  // Do NOT use flutter_html inside every JobCard.
  //
  // HTML parsing for dozens/hundreds of cards makes scrolling
  // noticeably heavier.
  //
  // The complete HTML description should be displayed on the
  // JobDetailsScreen instead.
  //
  String _descriptionPreview() {
    final description =
    widget.job.description.trim();

    if (description.isEmpty) {
      return 'No description available.';
    }

    // Remove common HTML tags.
    String text = description
        .replaceAll(
      RegExp(
        r'<br\s*/?>',
        caseSensitive: false,
      ),
      ' ',
    )
        .replaceAll(
      RegExp(
        r'</p>',
        caseSensitive: false,
      ),
      ' ',
    )
        .replaceAll(
      RegExp(
        r'<[^>]*>',
        caseSensitive: false,
      ),
      ' ',
    );

    // Decode a few common HTML entities.
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');

    // Remove excessive whitespace.
    text = text
        .replaceAll(
      RegExp(r'\s+'),
      ' ',
    )
        .trim();

    if (text.isEmpty) {
      return 'No description available.';
    }

    return text;
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    final companyName =
    job.company.trim().isEmpty
        ? 'Company'
        : job.company.trim();

    final position =
    job.position.trim().isEmpty
        ? 'Job Position'
        : job.position.trim();

    final country =
    job.country.trim().isEmpty
        ? 'Location not specified'
        : job.country.trim();

    final salary =
    job.salary.trim().isEmpty
        ? 'Salary N/A'
        : job.salary.trim();

    final jobType =
    job.jobType.trim().isEmpty
        ? 'General'
        : job.jobType.trim();

    final description =
    _descriptionPreview();

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),

          // Much lighter than Card elevation.
          border: Border.all(
            color: const Color(0xFFE8ECF2),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  // =================================================
                  // HEADER
                  // =================================================

                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      // COMPANY AVATAR
                      _buildCompanyAvatar(
                        companyName,
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      // TITLE + COMPANY
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [

                            Text(
                              position,
                              maxLines: 2,
                              overflow:
                              TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.2,
                                fontWeight:
                                FontWeight.w800,
                                color:
                                Color(0xFF172033),
                              ),
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            Text(
                              companyName,
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight:
                                FontWeight.w500,
                                color:
                                Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        width: 4,
                      ),

                      // SAVE BUTTON
                      _buildSaveButton(),
                    ],
                  ),

                  const SizedBox(
                    height: 13,
                  ),

                  // =================================================
                  // LOCATION
                  // =================================================

                  Row(
                    children: [

                      CountryFlagWidget(
                        country: country,
                        size: 22,
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Expanded(
                        child: Text(
                          country,
                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight:
                            FontWeight.w600,
                            color:
                            Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 11,
                  ),

                  // =================================================
                  // INFORMATION
                  // =================================================

                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [

                      _infoChip(
                        icon:
                        Icons.attach_money_rounded,
                        text: salary,
                      ),

                      _infoChip(
                        icon:
                        Icons.work_outline_rounded,
                        text: jobType,
                      ),

                      if (job.verified)
                        _infoChip(
                          icon:
                          Icons.verified_rounded,
                          text: 'Verified',
                          iconColor:
                          Colors.green,
                        ),
                    ],
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  // =================================================
                  // DESCRIPTION
                  // =================================================

                  Text(
                    description,
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color:
                      Color(0xFF64748B),
                    ),
                  ),

                  const SizedBox(
                    height: 13,
                  ),

                  // =================================================
                  // VIEW DETAILS
                  // =================================================

                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton(
                      onPressed: widget.onTap,
                      style:
                      ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor:
                        const Color(
                          0xFF2563EB,
                        ),
                        foregroundColor:
                        Colors.white,
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                            11,
                          ),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [

                          Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),

                          SizedBox(
                            width: 6,
                          ),

                          Icon(
                            Icons
                                .arrow_forward_rounded,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // COMPANY AVATAR
  // =========================================================

  Widget _buildCompanyAvatar(
      String companyName) {
    final firstLetter =
    companyName.isNotEmpty
        ? companyName[0].toUpperCase()
        : '?';

    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        firstLetter,
        style: const TextStyle(
          color: Color(0xFF2563EB),
          fontSize: 21,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // =========================================================
  // SAVE BUTTON
  // =========================================================

  Widget _buildSaveButton() {
    return SizedBox(
      width: 42,
      height: 42,
      child: Material(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius:
          BorderRadius.circular(12),
          onTap:
          _isSaving
              ? null
              : _toggleSaveJob,
          child: Center(
            child: _isSaving
                ? const SizedBox(
              width: 18,
              height: 18,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : Icon(
              _isSaved
                  ? Icons.favorite_rounded
                  : Icons
                  .favorite_border_rounded,
              size: 22,
              color: _isSaved
                  ? Colors.red
                  : const Color(
                0xFF64748B,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // INFO CHIP
  // =========================================================

  Widget _infoChip({
    required IconData icon,
    required String text,
    Color? iconColor,
  }) {
    return Container(
      constraints:
      const BoxConstraints(
        maxWidth: 170,
      ),
      padding:
      const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius:
        BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0xFFE8ECF2),
        ),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [

          Icon(
            icon,
            size: 15,
            color:
            iconColor ??
                const Color(
                  0xFF2563EB,
                ),
          ),

          const SizedBox(
            width: 5,
          ),

          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight:
                FontWeight.w600,
                color:
                Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }
}