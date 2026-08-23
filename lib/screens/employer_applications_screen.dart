import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/employer_service.dart';

class EmployerApplicationsScreen extends StatefulWidget {
  final int employerId;

  const EmployerApplicationsScreen({
    super.key,
    required this.employerId,
  });

  @override
  State<EmployerApplicationsScreen> createState() =>
      _EmployerApplicationsScreenState();
}

class _EmployerApplicationsScreenState
    extends State<EmployerApplicationsScreen> {

  final EmployerService employerService =
  EmployerService();

  List applications = [];

  bool loading = true;

  String? errorMessage;

  @override
  void initState() {
    super.initState();

    loadApplications();
  }

  // =========================================================
  // LOAD APPLICATIONS
  // =========================================================

  Future<void> loadApplications() async {
    if (mounted) {
      setState(() {
        loading = true;
        errorMessage = null;
      });
    }

    try {
      final result =
      await employerService.getApplications(
        widget.employerId,
      );

      if (!mounted) return;

      setState(() {
        applications = result ?? [];
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = e
            .toString()
            .replaceFirst(
          'Exception: ',
          '',
        );
      });
    }
  }

  // =========================================================
  // VIEW FULL APPLICANT PROFILE
  // =========================================================

  Future<void> viewApplicantDetails(
      Map<String, dynamic> application,
      ) async {

    final applicationIdValue =
    application['id'];

    if (applicationIdValue == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Application ID not found.',
          ),
        ),
      );

      return;
    }

    final applicationId =
    int.tryParse(
      applicationIdValue.toString(),
    );

    if (applicationId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid application ID.',
          ),
        ),
      );

      return;
    }

    // -------------------------------------------------------
    // Show loading dialog
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
    // Get full applicant profile
    // -------------------------------------------------------

    final applicant =
    await employerService.getApplicantDetails(
      employerId: widget.employerId,
      applicationId: applicationId,
    );

    // -------------------------------------------------------
    // Close loading
    // -------------------------------------------------------

    if (!mounted) return;

    Navigator.of(context).pop();

    // -------------------------------------------------------
    // Failed
    // -------------------------------------------------------

    if (applicant == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to load applicant details.',
          ),
        ),
      );

      return;
    }

    // -------------------------------------------------------
    // Show full profile
    // -------------------------------------------------------

    _showApplicantProfile(
      application,
      applicant,
    );
  }

  // =========================================================
  // SHOW FULL APPLICANT PROFILE
  // =========================================================

  void _showApplicantProfile(
      Map<String, dynamic> application,
      Map<String, dynamic> applicant,
      ) {

    final applicantName =
    applicant['fullName']
        ?.toString()
        .trim()
        .isNotEmpty ==
        true
        ? applicant['fullName'].toString()
        : 'Applicant';

    final profileImage =
        applicant['profileImage']
            ?.toString() ??
            '';

    final email =
        applicant['email']
            ?.toString() ??
            '';

    final phone =
        applicant['phone']
            ?.toString() ??
            '';

    final country =
        applicant['country']
            ?.toString() ??
            '';

    final experience =
        applicant['experience']
            ?.toString() ??
            '';

    final skills =
        applicant['skills']
            ?.toString() ??
            '';

    final passportNumber =
        applicant['passportNumber']
            ?.toString() ??
            '';

    final cvFileName =
        applicant['cvFileName']
            ?.toString() ??
            '';

    final cvUrl =
        applicant['cvUrl']
            ?.toString() ??
            '';

    final applicantId =
        applicant['applicantId']
            ?.toString() ??
            applicant['id']
                ?.toString() ??
            '';

    final position =
        applicant['position']
            ?.toString() ??
            application['position']
                ?.toString() ??
            '';

    final company =
        applicant['company']
            ?.toString() ??
            application['company']
                ?.toString() ??
            '';

    final status =
        applicant['applicationStatus']
            ?.toString() ??
            application['status']
                ?.toString() ??
            'PENDING';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {

        return Container(
          height:
          MediaQuery.of(sheetContext)
              .size
              .height *
              0.92,

          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),

          child: SafeArea(
            child: Column(
              children: [

                // =================================================
                // TOP HANDLE
                // =================================================

                const SizedBox(
                  height: 10,
                ),

                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                ),

                // =================================================
                // HEADER
                // =================================================

                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(
                    20,
                    15,
                    10,
                    10,
                  ),

                  child: Row(
                    children: [

                      const Expanded(
                        child: Text(
                          'Applicant Profile',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(
                            sheetContext,
                          );
                        },
                        icon: const Icon(
                          Icons.close,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(
                  height: 1,
                ),

                // =================================================
                // CONTENT
                // =================================================

                Expanded(
                  child: SingleChildScrollView(
                    padding:
                    const EdgeInsets.all(20),

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [

                        // =========================================
                        // PROFILE HEADER
                        // =========================================

                        Center(
                          child: Column(
                            children: [

                              _buildProfileImage(
                                profileImage,
                                applicantName,
                              ),

                              const SizedBox(
                                height: 14,
                              ),

                              Text(
                                applicantName,
                                textAlign:
                                TextAlign.center,
                                style:
                                const TextStyle(
                                  fontSize: 24,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),

                              if (applicantId
                                  .isNotEmpty)
                                const SizedBox(
                                  height: 5,
                                ),

                              if (applicantId
                                  .isNotEmpty)
                                Text(
                                  'Applicant ID: $applicantId',
                                  style:
                                  TextStyle(
                                    color:
                                    Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 25,
                        ),

                        // =========================================
                        // APPLICATION
                        // =========================================

                        _sectionTitle(
                          'Application',
                        ),

                        _detailRow(
                          Icons.work,
                          'Position',
                          position,
                        ),

                        if (company.isNotEmpty)
                          _detailRow(
                            Icons.business,
                            'Company',
                            company,
                          ),

                        _statusRow(
                          status,
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        // =========================================
                        // PERSONAL INFORMATION
                        // =========================================

                        _sectionTitle(
                          'Personal Information',
                        ),

                        if (email.isNotEmpty)
                          _detailRow(
                            Icons.email,
                            'Email',
                            email,
                          ),

                        if (phone.isNotEmpty)
                          _detailRow(
                            Icons.phone,
                            'Phone',
                            phone,
                          ),

                        if (country.isNotEmpty)
                          _detailRow(
                            Icons.public,
                            'Country',
                            country,
                          ),

                        if (passportNumber
                            .isNotEmpty)
                          _detailRow(
                            Icons.badge,
                            'Passport Number',
                            passportNumber,
                          ),

                        const SizedBox(
                          height: 15,
                        ),

                        // =========================================
                        // PROFESSIONAL INFORMATION
                        // =========================================

                        _sectionTitle(
                          'Professional Information',
                        ),

                        if (experience.isNotEmpty)
                          _detailRow(
                            Icons.work_history,
                            'Experience',
                            experience,
                          ),

                        if (skills.isNotEmpty)
                          _detailRow(
                            Icons.star,
                            'Skills',
                            skills,
                          ),

                        const SizedBox(
                          height: 15,
                        ),

                        // =========================================
                        // CV
                        // =========================================

                        _sectionTitle(
                          'Curriculum Vitae',
                        ),

                        if (cvFileName.isNotEmpty)
                          Card(
                            child: Padding(
                              padding:
                              const EdgeInsets.all(
                                14,
                              ),

                              child: Row(
                                children: [

                                  const Icon(
                                    Icons.picture_as_pdf,
                                    size: 35,
                                  ),

                                  const SizedBox(
                                    width: 12,
                                  ),

                                  Expanded(
                                    child: Text(
                                      cvFileName,
                                      style:
                                      const TextStyle(
                                        fontWeight:
                                        FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  if (cvUrl.isNotEmpty)
                                    IconButton(
                                      tooltip:
                                      'View CV',
                                      onPressed: () {
                                        _openCv(
                                          cvUrl,
                                        );
                                      },
                                      icon:
                                      const Icon(
                                        Icons
                                            .visibility,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          )
                        else
                          const Text(
                            'No CV uploaded.',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),

                        const SizedBox(
                          height: 25,
                        ),

                        // =========================================
                        // READ ONLY NOTICE
                        // =========================================

                        Container(
                          width:
                          double.infinity,
                          padding:
                          const EdgeInsets.all(
                            14,
                          ),
                          decoration:
                          BoxDecoration(
                            color: Colors.blue
                                .withOpacity(
                              0.08,
                            ),
                            borderRadius:
                            BorderRadius.circular(
                              12,
                            ),
                          ),
                          child: const Row(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [

                              Icon(
                                Icons
                                    .visibility_outlined,
                                size: 22,
                              ),

                              SizedBox(
                                width: 10,
                              ),

                              Expanded(
                                child: Text(
                                  'This applicant profile is read-only. '
                                      'Employers can view the information but '
                                      'cannot modify the applicant profile.',
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 25,
                        ),

                        // =========================================
                        // APPROVE / REJECT
                        // =========================================

                        if (status.toUpperCase() ==
                            'PENDING')
                          Row(
                            children: [

                              Expanded(
                                child:
                                ElevatedButton
                                    .icon(
                                  onPressed: () {

                                    Navigator.pop(
                                      sheetContext,
                                    );

                                    approveApplication(
                                      int.parse(
                                        application[
                                        'id']
                                            .toString(),
                                      ),
                                    );
                                  },

                                  icon:
                                  const Icon(
                                    Icons.check,
                                  ),

                                  label:
                                  const Text(
                                    'Approve',
                                  ),
                                ),
                              ),

                              const SizedBox(
                                width: 12,
                              ),

                              Expanded(
                                child:
                                OutlinedButton
                                    .icon(
                                  onPressed: () {

                                    Navigator.pop(
                                      sheetContext,
                                    );

                                    rejectApplication(
                                      int.parse(
                                        application[
                                        'id']
                                            .toString(),
                                      ),
                                    );
                                  },

                                  icon:
                                  const Icon(
                                    Icons.close,
                                  ),

                                  label:
                                  const Text(
                                    'Reject',
                                  ),
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // PROFILE IMAGE
  // =========================================================

  Widget _buildProfileImage(
      String imageUrl,
      String name,
      ) {

    if (imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 55,
        backgroundImage:
        NetworkImage(imageUrl),
        onBackgroundImageError:
            (_, __) {},
      );
    }

    return CircleAvatar(
      radius: 55,
      child: Text(
        name.isNotEmpty
            ? name[0].toUpperCase()
            : 'A',
        style: const TextStyle(
          fontSize: 38,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // =========================================================
  // SECTION TITLE
  // =========================================================

  Widget _sectionTitle(
      String title,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),

      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight:
          FontWeight.bold,
        ),
      ),
    );
  }

  // =========================================================
  // STATUS
  // =========================================================

  Widget _statusRow(
      String status,
      ) {

    Color color;

    switch (
    status.toUpperCase()) {

      case 'APPROVED':
      case 'ACCEPTED':
        color = Colors.green;
        break;

      case 'REJECTED':
        color = Colors.red;
        break;

      default:
        color = Colors.orange;
    }

    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),

      child: Row(
        children: [

          Icon(
            Icons.info_outline,
            size: 21,
            color: color,
          ),

          const SizedBox(
            width: 12,
          ),

          const SizedBox(
            width: 125,
            child: Text(
              'Status',
              style: TextStyle(
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),

            decoration:
            BoxDecoration(
              color: color.withOpacity(
                0.12,
              ),
              borderRadius:
              BorderRadius.circular(
                20,
              ),
            ),

            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                color: color,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DETAIL ROW
  // =========================================================

  Widget _detailRow(
      IconData icon,
      String title,
      String value,
      ) {

    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Icon(
            icon,
            size: 21,
          ),

          const SizedBox(
            width: 12,
          ),

          SizedBox(
            width: 125,

            child: Text(
              title,
              style:
              const TextStyle(
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // OPEN CV
  // =========================================================

  Future<void> _openCv(
      String url,
      ) async {

    final uri =
    Uri.tryParse(url);

    if (uri == null) {
      return;
    }

    try {
      final launched =
      await launchUrl(
        uri,
        mode:
        LaunchMode
            .externalApplication,
      );

      if (!launched &&
          mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to open CV.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open CV.',
          ),
        ),
      );
    }
  }

  // =========================================================
  // APPROVE
  // =========================================================

  Future<void> approveApplication(
      int applicationId,
      ) async {

    final confirmed =
    await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Approve Application',
          ),

          content: const Text(
            'Are you sure you want to approve this application?',
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },

              child:
              const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },

              child:
              const Text(
                'Approve',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final success =
    await employerService
        .approveApplication(
      employerId:
      widget.employerId,
      applicationId:
      applicationId,
    );

    if (!mounted) return;

    if (success) {

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Application approved successfully.',
          ),
        ),
      );

      await loadApplications();

    } else {

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to approve application.',
          ),
        ),
      );
    }
  }

  // =========================================================
  // REJECT
  // =========================================================

  Future<void> rejectApplication(
      int applicationId,
      ) async {

    final confirmed =
    await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Reject Application',
          ),

          content: const Text(
            'Are you sure you want to reject this application?',
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },

              child:
              const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },

              child:
              const Text(
                'Reject',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final success =
    await employerService
        .rejectApplication(
      employerId:
      widget.employerId,
      applicationId:
      applicationId,
    );

    if (!mounted) return;

    if (success) {

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Application rejected successfully.',
          ),
        ),
      );

      await loadApplications();

    } else {

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to reject application.',
          ),
        ),
      );
    }
  }

  // =========================================================
  // APPLICATION CARD
  // =========================================================

  Widget buildApplicationCard(
      dynamic application,
      ) {

    if (application is! Map) {
      return const SizedBox();
    }

    final data =
    Map<String, dynamic>.from(
      application,
    );

    final applicantName =
        data['applicantName']
            ?.toString() ??
            'Applicant';

    final position =
        data['position']
            ?.toString() ??
            'Job';

    final company =
        data['company']
            ?.toString() ??
            '';

    final status =
        data['status']
            ?.toString() ??
            'PENDING';

    Color statusColor;

    switch (
    status.toUpperCase()) {

      case 'APPROVED':
      case 'ACCEPTED':
        statusColor =
            Colors.green;
        break;

      case 'REJECTED':
        statusColor =
            Colors.red;
        break;

      default:
        statusColor =
            Colors.orange;
    }

    return Card(
      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),

      child: Padding(
        padding:
        const EdgeInsets.all(
          16,
        ),

        child: Column(
          children: [

            Row(
              children: [

                const CircleAvatar(
                  radius: 25,
                  child: Icon(
                    Icons.person,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [

                      Text(
                        applicantName,
                        style:
                        const TextStyle(
                          fontSize: 17,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        position,
                      ),

                      if (company
                          .isNotEmpty)
                        Text(
                          company,
                          style:
                          TextStyle(
                            color:
                            Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),

                Container(
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),

                  decoration:
                  BoxDecoration(
                    color: statusColor
                        .withOpacity(
                      0.12,
                    ),

                    borderRadius:
                    BorderRadius
                        .circular(
                      20,
                    ),
                  ),

                  child: Text(
                    status.toUpperCase(),

                    style:
                    TextStyle(
                      color:
                      statusColor,
                      fontWeight:
                      FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 12,
            ),

            SizedBox(
              width:
              double.infinity,

              child:
              OutlinedButton.icon(
                onPressed: () {
                  viewApplicantDetails(
                    data,
                  );
                },

                icon:
                const Icon(
                  Icons.visibility,
                ),

                label:
                const Text(
                  'View Applicant Details',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
      BuildContext context,
      ) {

    return Scaffold(

      appBar: AppBar(
        title:
        const Text(
          'Applications',
        ),

        actions: [

          IconButton(
            onPressed:
            loading
                ? null
                : loadApplications,

            icon:
            const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: loading

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : errorMessage != null

          ? Center(
        child: Padding(
          padding:
          const EdgeInsets.all(
            24,
          ),

          child: Column(
            mainAxisAlignment:
            MainAxisAlignment
                .center,

            children: [

              const Icon(
                Icons.error_outline,
                size: 60,
              ),

              const SizedBox(
                height: 16,
              ),

              Text(
                errorMessage!,
                textAlign:
                TextAlign.center,
              ),

              const SizedBox(
                height: 20,
              ),

              ElevatedButton.icon(
                onPressed:
                loadApplications,

                icon:
                const Icon(
                  Icons.refresh,
                ),

                label:
                const Text(
                  'Try Again',
                ),
              ),
            ],
          ),
        ),
      )

          : applications.isEmpty

          ? RefreshIndicator(
        onRefresh:
        loadApplications,

        child: ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),

          children: const [

            SizedBox(
              height: 180,
            ),

            Center(
              child: Column(
                children: [

                  Icon(
                    Icons
                        .people_outline,
                    size: 60,
                  ),

                  SizedBox(
                    height: 15,
                  ),

                  Text(
                    'No applications yet.',
                    style:
                    TextStyle(
                      fontSize:
                      17,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )

          : RefreshIndicator(
        onRefresh:
        loadApplications,

        child:
        ListView.builder(
          physics:
          const AlwaysScrollableScrollPhysics(),

          padding:
          const EdgeInsets.all(
            16,
          ),

          itemCount:
          applications.length,

          itemBuilder:
              (context, index) {

            return buildApplicationCard(
              applications[index],
            );
          },
        ),
      ),
    );
  }
}