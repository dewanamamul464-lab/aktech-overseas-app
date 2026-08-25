import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/job_model.dart';
import '../services/application_service.dart';
import '../services/saved_job_service.dart';
import '../widgets/country_flag.dart';

class JobDetailsScreen extends StatefulWidget {
  final Job job;

  const JobDetailsScreen({
    super.key,
    required this.job,
  });

  @override
  State<JobDetailsScreen> createState() =>
      _JobDetailsScreenState();
}

class _JobDetailsScreenState
    extends State<JobDetailsScreen> {

  final SavedJobService savedJobService =
  SavedJobService();

  final ApplicationService applicationService =
  ApplicationService();

  bool isSaved = false;

  bool isSaving = false;

  bool isOpeningApplication = false;

  bool isApplying = false;

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
      final saved =
      await savedJobService.isJobSaved(
        widget.job.id,
      );

      if (!mounted) return;

      setState(() {
        isSaved = saved;
      });
    } catch (_) {
      // Ignore saved-status errors.
    }
  }

  // =========================================================
  // SAVE / REMOVE JOB
  // =========================================================

  Future<void> _toggleSaveJob() async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      final saved =
      await savedJobService.toggleSavedJob(
        widget.job,
      );

      if (!mounted) return;

      setState(() {
        isSaved = saved;
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            saved
                ? 'Job saved successfully ❤️'
                : 'Job removed from saved jobs',
          ),
          duration:
          const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to save job',
          ),
        ),
      );
    }
  }

  // =========================================================
  // APPLY NOW
  // =========================================================
  //
  // EMPLOYER JOB:
  //
  // employerId != null
  //        ↓
  // POST /api/applications
  //
  // EXTERNAL JOB:
  //
  // employerId == null
  //        ↓
  // Open sourceUrl
  //
  // =========================================================

  Future<void> _applyNow() async {

    // =======================================================
    // AKTECH EMPLOYER JOB
    // =======================================================

    if (widget.job.employerId != null) {

      if (isApplying) {
        return;
      }

      setState(() {
        isApplying = true;
      });

      try {
        debugPrint(
          '======================================',
        );

        debugPrint(
          'INTERNAL EMPLOYER JOB APPLICATION',
        );

        debugPrint(
          'JOB ID: ${widget.job.id}',
        );

        debugPrint(
          'EMPLOYER ID: ${widget.job.employerId}',
        );

        debugPrint(
          '======================================',
        );

        final success =
        await applicationService.applyJob(
          widget.job.id,
        );

        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Application submitted successfully.',
              ),
              duration:
              Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Unable to submit application. Please try again.',
              ),
              duration:
              Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;

        debugPrint(
          'INTERNAL APPLICATION ERROR: $e',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to submit application.',
            ),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            isApplying = false;
          });
        }
      }

      return;
    }

    // =======================================================
    // EXTERNAL JOB
    // =======================================================

    final urlString =
    widget.job.sourceUrl.trim();

    if (urlString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Application link is unavailable for this job.',
          ),
        ),
      );

      return;
    }

    Uri? uri;

    try {
      uri = Uri.parse(urlString);
    } catch (_) {
      uri = null;
    }

    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' &&
            uri.scheme != 'https')) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid application link.',
          ),
        ),
      );

      return;
    }

    if (isOpeningApplication) {
      return;
    }

    setState(() {
      isOpeningApplication = true;
    });

    try {
      final launched =
      await launchUrl(
        uri,
        mode:
        LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to open the application link.',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to open the application link.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isOpeningApplication = false;
        });
      }
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    final bool isEmployerJob =
        job.employerId != null;

    final bool isApplyingNow =
    isEmployerJob
        ? isApplying
        : isOpeningApplication;

    return Scaffold(
      backgroundColor:
      Colors.grey.shade50,

      // =====================================================
      // APP BAR
      // =====================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,

        title: const Text(
          'Job Details',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),

        actions: [
          IconButton(
            onPressed:
            isSaving
                ? null
                : _toggleSaveJob,

            tooltip: isSaved
                ? 'Remove saved job'
                : 'Save job',

            icon: isSaving
                ? const SizedBox(
              width: 21,
              height: 21,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : Icon(
              isSaved
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: isSaved
                  ? Colors.red
                  : Colors.grey.shade700,
            ),
          ),
        ],
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.only(
            bottom: 30,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              // =================================================
              // HEADER
              // =================================================

              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  24,
                  20,
                  25,
                ),
                decoration:
                const BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  children: [

                    Container(
                      width: 78,
                      height: 78,
                      decoration:
                      BoxDecoration(
                        gradient:
                        LinearGradient(
                          colors: [
                            Colors.blue.shade700,
                            Colors.blue.shade400,
                          ],
                        ),
                        borderRadius:
                        BorderRadius.circular(
                          22,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                            Colors.blue
                                .withOpacity(
                              0.18,
                            ),
                            blurRadius: 15,
                            offset:
                            const Offset(
                              0,
                              7,
                            ),
                          ),
                        ],
                      ),
                      alignment:
                      Alignment.center,
                      child: Text(
                        job.company.isNotEmpty
                            ? job.company[0]
                            .toUpperCase()
                            : '?',
                        style:
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 17,
                    ),

                    Text(
                      job.position.isEmpty
                          ? 'Job Position'
                          : job.position,
                      textAlign:
                      TextAlign.center,
                      style:
                      const TextStyle(
                        fontSize: 23,
                        fontWeight:
                        FontWeight.w800,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      job.company.isEmpty
                          ? 'Company'
                          : job.company,
                      textAlign:
                      TextAlign.center,
                      style: TextStyle(
                        color:
                        Colors.grey.shade600,
                        fontSize: 16,
                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [

                        CountryFlagWidget(
                          country:
                          job.country,
                          size: 25,
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        Flexible(
                          child: Text(
                            job.country.isEmpty
                                ? 'Location not specified'
                                : job.country,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style: TextStyle(
                              color: Colors
                                  .grey
                                  .shade700,
                              fontWeight:
                              FontWeight
                                  .w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              // =================================================
              // JOB INFORMATION
              // =================================================

              _sectionCard(
                title: 'Job Information',
                icon:
                Icons.work_outline,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [

                    _detailChip(
                      Icons.attach_money,
                      job.salary.isEmpty
                          ? 'Salary not specified'
                          : job.salary,
                    ),

                    _detailChip(
                      Icons
                          .business_center_outlined,
                      job.jobType.isEmpty
                          ? 'General'
                          : job.jobType,
                    ),

                    if (job.experience
                        .isNotEmpty)
                      _detailChip(
                        Icons.timeline,
                        job.experience,
                      ),

                    _detailChip(
                      Icons.people_outline,
                      '${job.vacancies} vacancy${job.vacancies == 1 ? '' : 'ies'}',
                    ),

                    if (job.verified)
                      _detailChip(
                        Icons.verified,
                        'Verified',
                        iconColor:
                        Colors.green,
                      ),

                    if (isEmployerJob)
                      _detailChip(
                        Icons.business,
                        'AKTech Employer',
                        iconColor:
                        Colors.blue.shade700,
                      ),
                  ],
                ),
              ),

              // =================================================
              // DESCRIPTION
              // =================================================

              _sectionCard(
                title: 'Job Description',
                icon:
                Icons.description_outlined,
                child: _buildHtmlContent(
                  job.description,
                ),
              ),

              // =================================================
              // REQUIREMENTS
              // =================================================

              if (job.requirements
                  .isNotEmpty)
                _sectionCard(
                  title: 'Requirements',
                  icon:
                  Icons.checklist_outlined,
                  child:
                  _buildHtmlContent(
                    job.requirements,
                  ),
                ),

              // =================================================
              // SOURCE
              // =================================================

              if (job.source.isNotEmpty)
                _sectionCard(
                  title: 'Job Source',
                  icon: Icons.public,
                  child: Row(
                    children: [

                      Icon(
                        Icons.language,
                        color:
                        Colors.blue.shade700,
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: Text(
                          job.source,
                          style:
                          const TextStyle(
                            fontSize: 15,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // =================================================
              // EXPIRY
              // =================================================

              _sectionCard(
                title:
                'Application Information',
                icon:
                Icons.event_outlined,
                child: Row(
                  children: [

                    Icon(
                      Icons
                          .calendar_today_outlined,
                      size: 20,
                      color:
                      Colors.blue.shade700,
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child: Text(
                        'Application deadline: '
                            '${job.expiryDate}',
                        style:
                        const TextStyle(
                          fontSize: 14.5,
                          fontWeight:
                          FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              // =================================================
              // APPLY NOW
              // =================================================

              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child:
                  ElevatedButton.icon(
                    onPressed:
                    isApplyingNow
                        ? null
                        : _applyNow,

                    icon: isApplyingNow
                        ? const SizedBox(
                      width: 21,
                      height: 21,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color:
                        Colors.white,
                      ),
                    )
                        : Icon(
                      isEmployerJob
                          ? Icons
                          .send_outlined
                          : Icons
                          .open_in_new,
                    ),

                    label: Text(
                      isApplyingNow
                          ? isEmployerJob
                          ? 'Applying...'
                          : 'Opening...'
                          : isEmployerJob
                          ? 'Apply Now'
                          : 'Apply on Original Site',
                      style:
                      const TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    style:
                    ElevatedButton.styleFrom(
                      elevation: 1,
                      backgroundColor:
                      Colors.blue.shade700,
                      foregroundColor:
                      Colors.white,
                      disabledBackgroundColor:
                      Colors.blue.shade300,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              // =================================================
              // APPLICATION INFORMATION
              // =================================================

              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Icon(
                      Icons.info_outline,
                      size: 17,
                      color:
                      Colors.grey.shade600,
                    ),

                    const SizedBox(
                      width: 7,
                    ),

                    Expanded(
                      child: Text(
                        isEmployerJob
                            ? 'Your application will be submitted directly to the employer through AKTech Overseas.'
                            : 'You will be redirected to '
                            '${job.source.isEmpty ? 'the original job source' : job.source} '
                            'to complete your application.',
                        textAlign:
                        TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          color:
                          Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // HTML CONTENT
  // =========================================================

  Widget _buildHtmlContent(
      String html) {

    if (html.trim().isEmpty) {
      return Text(
        'No information available.',
        style: TextStyle(
          color:
          Colors.grey.shade600,
          height: 1.5,
        ),
      );
    }

    return Html(
      data: html,
      style: {

        'body': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontSize: FontSize(15),
          color:
          Colors.grey.shade800,
          lineHeight:
          const LineHeight(1.55),
        ),

        'p': Style(
          margin: Margins.only(
            bottom: 12,
          ),
        ),

        'h1': Style(
          fontSize: FontSize(20),
          fontWeight:
          FontWeight.w700,
          margin: Margins.only(
            top: 8,
            bottom: 10,
          ),
        ),

        'h2': Style(
          fontSize: FontSize(18),
          fontWeight:
          FontWeight.w700,
          margin: Margins.only(
            top: 8,
            bottom: 10,
          ),
        ),

        'h3': Style(
          fontSize: FontSize(16),
          fontWeight:
          FontWeight.w700,
          margin: Margins.only(
            top: 8,
            bottom: 8,
          ),
        ),

        'strong': Style(
          fontWeight:
          FontWeight.w700,
        ),

        'ul': Style(
          margin: Margins.only(
            top: 5,
            bottom: 10,
          ),
          padding:
          HtmlPaddings.only(
            left: 20,
          ),
        ),

        'ol': Style(
          margin: Margins.only(
            top: 5,
            bottom: 10,
          ),
          padding:
          HtmlPaddings.only(
            left: 20,
          ),
        ),

        'li': Style(
          margin: Margins.only(
            bottom: 6,
          ),
        ),

        'a': Style(
          color: Colors.blue,
          textDecoration:
          TextDecoration.underline,
        ),
      },
    );
  }

  // =========================================================
  // SECTION CARD
  // =========================================================

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),
      padding:
      const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.035),
            blurRadius: 8,
            offset:
            const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              Container(
                width: 38,
                height: 38,
                decoration:
                BoxDecoration(
                  color:
                  Colors.blue.shade50,
                  borderRadius:
                  BorderRadius.circular(
                    11,
                  ),
                ),
                child: Icon(
                  icon,
                  color:
                  Colors.blue.shade700,
                  size: 21,
                ),
              ),

              const SizedBox(
                width: 11,
              ),

              Expanded(
                child: Text(
                  title,
                  style:
                  const TextStyle(
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          child,
        ],
      ),
    );
  }

  // =========================================================
  // DETAIL CHIP
  // =========================================================

  Widget _detailChip(
      IconData icon,
      String text, {
        Color? iconColor,
      }) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration:
      BoxDecoration(
        color:
        Colors.grey.shade100,
        borderRadius:
        BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [

          Icon(
            icon,
            size: 17,
            color:
            iconColor ??
                Colors.blue.shade700,
          ),

          const SizedBox(
            width: 7,
          ),

          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight:
              FontWeight.w600,
              color:
              Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}