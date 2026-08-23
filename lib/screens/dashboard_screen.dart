import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/employer_service.dart';

class EmployerApplicationsScreen
    extends StatefulWidget {
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
    setState(() {
      loading = true;
      errorMessage = null;
    });

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
  // VIEW APPLICANT DETAILS
  // =========================================================

  Future<void> viewApplicantDetails(
      dynamic application) async {
    if (application is! Map) {
      return;
    }

    final data =
    Map<String, dynamic>.from(application);

    final applicationId =
    int.tryParse(
      data['id']?.toString() ?? '',
    );

    if (applicationId == null) {
      showMessage(
        'Application ID not found.',
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final applicant =
      await employerService.getApplicantDetails(
        employerId: widget.employerId,
        applicationId: applicationId,
      );

      if (!mounted) return;

      Navigator.pop(context);

      if (applicant == null) {
        showMessage(
          'Could not load applicant details.',
        );
        return;
      }

      await showDialog(
        context: context,
        builder: (context) {
          return _buildApplicantDetailsDialog(
            applicant,
            data,
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context);

      showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  // =========================================================
  // APPLICANT DETAILS DIALOG
  // =========================================================

  Widget _buildApplicantDetailsDialog(
      Map<String, dynamic> applicant,
      Map<String, dynamic> application,
      ) {
    final fullName =
        applicant['fullName']?.toString() ??
            'Applicant';

    final email =
        applicant['email']?.toString() ??
            '';

    final phone =
        applicant['phone']?.toString() ??
            '';

    final country =
        applicant['country']?.toString() ??
            '';

    final experience =
        applicant['experience']?.toString() ??
            '';

    final skills =
        applicant['skills']?.toString() ??
            '';

    final passportNumber =
        applicant['passportNumber']
            ?.toString() ??
            '';

    final cvFileName =
        applicant['cvFileName']?.toString() ??
            '';

    final cvUrl =
        applicant['cvUrl']?.toString() ??
            '';

    final profileImage =
        applicant['profileImage']?.toString() ??
            '';

    final position =
        application['position']?.toString() ??
            'Job';

    final status =
        application['status']?.toString() ??
            'PENDING';

    return AlertDialog(
      titlePadding:
      const EdgeInsets.fromLTRB(
        24,
        20,
        24,
        10,
      ),
      contentPadding:
      const EdgeInsets.fromLTRB(
        24,
        10,
        24,
        20,
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage:
            profileImage.isNotEmpty
                ? NetworkImage(
              profileImage,
            )
                : null,
            child: profileImage.isEmpty
                ? const Icon(
              Icons.person,
              size: 30,
            )
                : null,
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  position,
                  style: TextStyle(
                    fontSize: 13,
                    color:
                    Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Divider(),

            const SizedBox(
              height: 10,
            ),

            _buildApplicantInfo(
              Icons.email,
              'Email',
              email,
            ),

            _buildApplicantInfo(
              Icons.phone,
              'Phone',
              phone,
            ),

            _buildApplicantInfo(
              Icons.public,
              'Country',
              country,
            ),

            _buildApplicantInfo(
              Icons.work_history,
              'Experience',
              experience,
            ),

            _buildApplicantInfo(
              Icons.code,
              'Skills',
              skills,
            ),

            _buildApplicantInfo(
              Icons.badge,
              'Passport Number',
              passportNumber,
            ),

            const SizedBox(
              height: 10,
            ),

            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 20,
                ),

                const SizedBox(
                  width: 10,
                ),

                const Text(
                  'Application Status',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const Spacer(),

                _buildStatusBadge(
                  status,
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            if (cvUrl.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final uri =
                    Uri.tryParse(
                      cvUrl,
                    );

                    if (uri == null) {
                      showMessage(
                        'Invalid CV URL.',
                      );
                      return;
                    }

                    final opened =
                    await launchUrl(
                      uri,
                      mode: LaunchMode
                          .externalApplication,
                    );

                    if (!opened &&
                        mounted) {
                      showMessage(
                        'Could not open CV.',
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.picture_as_pdf,
                  ),
                  label: Text(
                    cvFileName.isNotEmpty
                        ? 'View $cvFileName'
                        : 'View CV',
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(
                  14,
                ),
                decoration:
                BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(
                    10,
                  ),
                  color:
                  Colors.grey.shade100,
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons
                          .description_outlined,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        'No CV uploaded by this applicant.',
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Close',
          ),
        ),
      ],
    );
  }

  // =========================================================
  // APPLICANT INFO ROW
  // =========================================================

  Widget _buildApplicantInfo(
      IconData icon,
      String title,
      String value,
      ) {
    if (value.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 14,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
          ),

          const SizedBox(
            width: 10,
          ),

          SizedBox(
            width: 115,
            child: Text(
              title,
              style: const TextStyle(
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
            data['fullName']
                ?.toString() ??
            'Applicant';

    final position =
        data['position']
            ?.toString() ??
            data['jobPosition']
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

    final email =
        data['email']
            ?.toString() ??
            '';

    final phone =
        data['phone']
            ?.toString() ??
            '';

    Color statusColor;

    switch (status.toUpperCase()) {
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
        const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
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
                    CrossAxisAlignment.start,
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

                      Text(position),

                      if (company
                          .isNotEmpty)
                        Text(
                          company,
                          style:
                          TextStyle(
                            color:
                            Colors.grey[
                            600],
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
                    color:
                    statusColor
                        .withOpacity(
                      0.12,
                    ),
                    borderRadius:
                    BorderRadius.circular(
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

            if (email.isNotEmpty ||
                phone.isNotEmpty) ...[
              const Divider(
                height: 25,
              ),

              if (email.isNotEmpty)
                Row(
                  children: [
                    const Icon(
                      Icons.email,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child:
                      Text(email),
                    ),
                  ],
                ),

              if (phone.isNotEmpty) ...[
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child:
                      Text(phone),
                    ),
                  ],
                ),
              ],
            ],

            const SizedBox(
              height: 14,
            ),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    viewApplicantDetails(
                      application,
                    ),
                icon: const Icon(
                  Icons.visibility,
                ),
                label: const Text(
                  'View Applicant Details',
                ),
              ),
            ),

            // =================================================
            // KEEP YOUR EXISTING APPROVE / REJECT BUTTONS HERE
            // =================================================
          ],
        ),
      ),
    );
  }

  // =========================================================
  // STATUS BADGE
  // =========================================================

  Widget _buildStatusBadge(
      String status,
      ) {
    final normalized =
    status.toUpperCase();

    Color color;

    if (normalized ==
        'APPROVED' ||
        normalized ==
            'ACCEPTED') {
      color =
          Colors.green;
    } else if (normalized ==
        'REJECTED') {
      color =
          Colors.red;
    } else {
      color =
          Colors.orange;
    }

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration:
      BoxDecoration(
        color:
        color.withOpacity(
          0.12,
        ),
        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        normalized,
        style: TextStyle(
          color: color,
          fontWeight:
          FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void showMessage(
      String message,
      ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
          Text(message),
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
        title: const Text(
          'Applications',
        ),
        actions: [
          IconButton(
            onPressed:
            loading
                ? null
                : loadApplications,
            icon: const Icon(
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
                Icons
                    .error_outline,
                size: 60,
              ),

              const SizedBox(
                height: 16,
              ),

              Text(
                errorMessage!,
                textAlign:
                TextAlign
                    .center,
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
        child:
        ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(
              height: 180,
            ),
            Center(
              child:
              Column(
                children: [
                  Icon(
                    Icons
                        .people_outline,
                    size: 60,
                  ),
                  SizedBox(
                    height:
                    15,
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
          const EdgeInsets
              .all(
            16,
          ),
          itemCount:
          applications
              .length,
          itemBuilder:
              (context, index) {
            return buildApplicationCard(
              applications[
              index],
            );
          },
        ),
      ),
    );
  }
}