import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/employer_service.dart';

class EmployerDashboardScreen extends StatefulWidget {
  const EmployerDashboardScreen({super.key});

  @override
  State<EmployerDashboardScreen> createState() =>
      _EmployerDashboardScreenState();
}

class _EmployerDashboardScreenState
    extends State<EmployerDashboardScreen> {
  final EmployerService employerService = EmployerService();

  Map<String, dynamic>? employer;

  List jobs = [];
  List applications = [];

  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  // =========================================================
  // LOAD DASHBOARD
  // =========================================================

  Future<void> loadDashboard() async {
    try {
      if (mounted) {
        setState(() {
          loading = true;
          errorMessage = null;
        });
      }

      // -----------------------------------------------------
      // GET EMPLOYER PROFILE
      // -----------------------------------------------------

      final profile = await employerService.getMyProfile();

      if (profile == null) {
        throw Exception(
          'Could not load employer profile.\n'
              'Please check your login/token.',
        );
      }

      // -----------------------------------------------------
      // GET EMPLOYER ID
      // -----------------------------------------------------

      final employerId = profile['id'];

      if (employerId == null) {
        throw Exception(
          'Employer ID not found.',
        );
      }

      final id = int.tryParse(
        employerId.toString(),
      );

      if (id == null) {
        throw Exception(
          'Invalid employer ID.',
        );
      }

      // -----------------------------------------------------
      // GET JOBS
      // -----------------------------------------------------

      final employerJobs =
      await employerService.getMyJobs(id);

      // -----------------------------------------------------
      // GET APPLICATIONS
      // -----------------------------------------------------

      final employerApplications =
      await employerService.getApplications(id);

      if (!mounted) return;

      setState(() {
        employer = profile;

        jobs = employerJobs ?? [];

        applications =
            employerApplications ?? [];

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
  // REFRESH
  // =========================================================

  Future<void> refreshDashboard() async {
    await loadDashboard();
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  Future<void> logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    try {
      final prefs =
      await SharedPreferences.getInstance();

      // Remove JWT token
      await prefs.remove('token');

      // Remove role if stored
      await prefs.remove('role');

      // Remove any other login state if used
      await prefs.remove('loggedIn');

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Logout failed. Please try again.',
      );
    }
  }

  // =========================================================
  // POST JOB
  // =========================================================

  void openPostJob() {
    if (employer == null) {
      showMessage(
        'Employer profile is not loaded.',
      );
      return;
    }

    final status =
        employer!['status']
            ?.toString()
            .toUpperCase() ??
            'PENDING';

    if (status != 'APPROVED') {
      showMessage(
        'Your employer account must be approved before posting jobs.',
      );
      return;
    }

    final employerId =
    employer!['id'];

    if (employerId == null) {
      showMessage(
        'Employer ID not found.',
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/post-job',
      arguments: int.tryParse(
        employerId.toString(),
      ),
    ).then((_) {
      if (mounted) {
        refreshDashboard();
      }
    });
  }

  // =========================================================
  // VIEW APPLICATIONS
  // =========================================================

  void openApplications() {
    if (employer == null) {
      showMessage(
        'Employer profile is not loaded.',
      );
      return;
    }

    final employerId =
    employer!['id'];

    if (employerId == null) {
      showMessage(
        'Employer ID not found.',
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/employer-applications',
      arguments: int.tryParse(
        employerId.toString(),
      ),
    );
  }

  // =========================================================
  // MESSAGE
  // =========================================================

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
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
          'Employer Dashboard',
        ),
        actions: [
          // -------------------------------------------------
          // REFRESH
          // -------------------------------------------------

          IconButton(
            onPressed:
            loading
                ? null
                : refreshDashboard,
            icon: const Icon(
              Icons.refresh,
            ),
            tooltip: 'Refresh',
          ),

          // -------------------------------------------------
          // LOGOUT
          // -------------------------------------------------

          IconButton(
            onPressed:
            loading
                ? null
                : logout,
            icon: const Icon(
              Icons.logout,
            ),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: loading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : errorMessage != null
          ? _buildError()
          : RefreshIndicator(
        onRefresh:
        refreshDashboard,
        child: ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding:
          const EdgeInsets.all(16),
          children: [
            // ------------------------------------------------
            // WELCOME
            // ------------------------------------------------

            _buildWelcomeCard(),

            const SizedBox(
              height: 18,
            ),

            // ------------------------------------------------
            // IMPORTANT STATUS CARD
            // ------------------------------------------------

            _buildEmployerStatusCard(),

            const SizedBox(
              height: 24,
            ),

            // ------------------------------------------------
            // STATISTICS
            // ------------------------------------------------

            _buildStatistics(),

            const SizedBox(
              height: 24,
            ),

            // ------------------------------------------------
            // QUICK ACTIONS
            // ------------------------------------------------

            _buildQuickActions(),

            const SizedBox(
              height: 24,
            ),

            // ------------------------------------------------
            // COMPANY PROFILE
            // ------------------------------------------------

            _buildProfileCard(),

            const SizedBox(
              height: 24,
            ),

            // ------------------------------------------------
            // JOBS
            // ------------------------------------------------

            _buildJobsSection(),

            const SizedBox(
              height: 24,
            ),

            // ------------------------------------------------
            // APPLICATIONS
            // ------------------------------------------------

            _buildApplicationsSection(),

            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // QUICK ACTIONS
  // =========================================================

  Widget _buildQuickActions() {
    final status =
        employer?['status']
            ?.toString()
            .toUpperCase() ??
            'PENDING';

    final approved =
        status == 'APPROVED';

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        Row(
          children: [
            // -------------------------------------------------
            // POST JOB
            // -------------------------------------------------

            Expanded(
              child: ElevatedButton.icon(
                onPressed:
                approved
                    ? openPostJob
                    : () {
                  showMessage(
                    'Your employer account must be approved before posting jobs.',
                  );
                },
                icon: const Icon(
                  Icons.add_business,
                ),
                label: const Text(
                  'Post a Job',
                ),
                style:
                ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            // -------------------------------------------------
            // APPLICATIONS
            // -------------------------------------------------

            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                openApplications,
                icon: const Icon(
                  Icons.people,
                ),
                label: const Text(
                  'Applications',
                ),
                style:
                OutlinedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =========================================================
  // ERROR
  // =========================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              errorMessage ??
                  'Something went wrong.',
              textAlign:
              TextAlign.center,
              style:
              const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton.icon(
              onPressed:
              refreshDashboard,
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

  // =========================================================
  // WELCOME CARD
  // =========================================================

  Widget _buildWelcomeCard() {
    if (employer == null) {
      return const SizedBox();
    }

    final companyName =
        employer!['companyName']
            ?.toString() ??
            'Employer';

    final user =
    employer!['user'];

    String username = '';

    if (user is Map) {
      username =
          user['username']
              ?.toString() ??
              '';
    }

    return Card(
      elevation: 3,
      shape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(
          18,
        ),
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              child: Text(
                companyName.isNotEmpty
                    ? companyName[0]
                    .toUpperCase()
                    : 'E',
                style:
                const TextStyle(
                  fontSize: 25,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(
              width: 16,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back,',
                    style:
                    TextStyle(
                      fontSize: 14,
                      color:
                      Colors.grey,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    companyName,
                    style:
                    const TextStyle(
                      fontSize: 22,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  if (username.isNotEmpty)
                    Padding(
                      padding:
                      const EdgeInsets
                          .only(
                        top: 5,
                      ),
                      child: Text(
                        '@$username',
                        style:
                        TextStyle(
                          color:
                          Colors.grey[
                          600],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // EMPLOYER STATUS CARD
  // =========================================================

  Widget _buildEmployerStatusCard() {
    if (employer == null) {
      return const SizedBox();
    }

    final status =
        employer!['status']
            ?.toString()
            .toUpperCase() ??
            'PENDING';

    Color statusColor;
    Color backgroundColor;
    IconData statusIcon;
    String title;
    String message;

    // -------------------------------------------------------
    // PENDING
    // -------------------------------------------------------

    if (status == 'PENDING') {
      statusColor =
          Colors.orange.shade800;

      backgroundColor =
          Colors.orange.shade50;

      statusIcon =
          Icons.hourglass_top;

      title =
      'Account Pending Approval';

      message =
      'Your employer account has been '
          'submitted successfully. '
          'An administrator must approve '
          'your account before you can '
          'fully use employer features.';
    }

    // -------------------------------------------------------
    // APPROVED
    // -------------------------------------------------------

    else if (status == 'APPROVED') {
      statusColor =
          Colors.green.shade700;

      backgroundColor =
          Colors.green.shade50;

      statusIcon =
          Icons.verified;

      title =
      'Employer Account Approved';

      message =
      'Your employer account has been '
          'approved by the administrator. '
          'You can now use employer features '
          'and post jobs.';
    }

    // -------------------------------------------------------
    // REJECTED
    // -------------------------------------------------------

    else if (status == 'REJECTED') {
      statusColor =
          Colors.red.shade700;

      backgroundColor =
          Colors.red.shade50;

      statusIcon =
          Icons.cancel;

      title =
      'Employer Account Rejected';

      message =
      'Your employer account was rejected '
          'by the administrator. Please contact '
          'the administrator for more information.';
    }

    // -------------------------------------------------------
    // UNKNOWN
    // -------------------------------------------------------

    else {
      statusColor =
          Colors.grey.shade700;

      backgroundColor =
          Colors.grey.shade100;

      statusIcon =
          Icons.help_outline;

      title =
      'Account Status';

      message =
      'Your current employer account '
          'status is $status.';
    }

    return Container(
      width: double.infinity,
      decoration:
      BoxDecoration(
        color: backgroundColor,
        borderRadius:
        BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: statusColor
              .withOpacity(0.35),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // -------------------------------------------------
            // TOP ROW
            // -------------------------------------------------

            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration:
                  BoxDecoration(
                    color:
                    statusColor,
                    shape:
                    BoxShape.circle,
                  ),
                  child: Icon(
                    statusIcon,
                    color:
                    Colors.white,
                    size: 30,
                  ),
                ),

                const SizedBox(
                  width: 14,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        'ACCOUNT STATUS',
                        style:
                        TextStyle(
                          fontSize: 12,
                          fontWeight:
                          FontWeight.bold,
                          letterSpacing:
                          1.2,
                          color:
                          statusColor,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        title,
                        style:
                        const TextStyle(
                          fontSize: 19,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 18,
            ),

            // -------------------------------------------------
            // STATUS BADGE
            // -------------------------------------------------

            Container(
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 16,
                vertical: 9,
              ),
              decoration:
              BoxDecoration(
                color:
                statusColor,
                borderRadius:
                BorderRadius.circular(
                  30,
                ),
              ),
              child: Row(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Icon(
                    statusIcon,
                    size: 18,
                    color:
                    Colors.white,
                  ),

                  const SizedBox(
                    width: 7,
                  ),

                  Text(
                    status,
                    style:
                    const TextStyle(
                      color:
                      Colors.white,
                      fontWeight:
                      FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // -------------------------------------------------
            // MESSAGE
            // -------------------------------------------------

            Text(
              message,
              style:
              const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),

            // -------------------------------------------------
            // PENDING MESSAGE
            // -------------------------------------------------

            if (status == 'PENDING') ...[
              const SizedBox(
                height: 16,
              ),

              Container(
                width: double.infinity,
                padding:
                const EdgeInsets
                    .all(12),
                decoration:
                BoxDecoration(
                  color: Colors
                      .orange
                      .withOpacity(
                    0.10,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(
                    10,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                    ),

                    SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child: Text(
                        'Please wait for admin approval.',
                        style:
                        TextStyle(
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // -------------------------------------------------
            // APPROVED MESSAGE
            // -------------------------------------------------

            if (status == 'APPROVED') ...[
              const SizedBox(
                height: 16,
              ),

              Container(
                width: double.infinity,
                padding:
                const EdgeInsets
                    .all(12),
                decoration:
                BoxDecoration(
                  color: Colors
                      .green
                      .withOpacity(
                    0.10,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(
                    10,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 20,
                    ),

                    SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child: Text(
                        'You can now post jobs and manage applications.',
                        style:
                        TextStyle(
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // -------------------------------------------------
            // REJECTED MESSAGE
            // -------------------------------------------------

            if (status == 'REJECTED') ...[
              const SizedBox(
                height: 16,
              ),

              Container(
                width: double.infinity,
                padding:
                const EdgeInsets
                    .all(12),
                decoration:
                BoxDecoration(
                  color: Colors
                      .red
                      .withOpacity(
                    0.10,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(
                    10,
                  ),
                ),
                child: const Row(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Icon(
                      Icons.warning_amber,
                      size: 20,
                    ),

                    SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child: Text(
                        'Please contact the administrator if you believe this was a mistake.',
                        style:
                        TextStyle(
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =========================================================
  // STATISTICS
  // =========================================================

  Widget _buildStatistics() {
    return Row(
      children: [
        Expanded(
          child:
          _buildStatCard(
            icon: Icons.work,
            title: 'Jobs',
            value:
            jobs.length.toString(),
          ),
        ),

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child:
          _buildStatCard(
            icon: Icons.people,
            title: 'Applications',
            value: applications
                .length
                .toString(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding:
        const EdgeInsets.all(
          16,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              value,
              style:
              const TextStyle(
                fontSize: 24,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            Text(title),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // COMPANY PROFILE
  // =========================================================

  Widget _buildProfileCard() {
    if (employer == null) {
      return const SizedBox();
    }

    final companyName =
        employer!['companyName']
            ?.toString() ??
            '';

    final email =
        employer!['email']
            ?.toString() ??
            '';

    final phone =
        employer!['phone']
            ?.toString() ??
            '';

    final contactPerson =
    employer!['contactPerson']
        ?.toString();

    final country =
    employer!['country']
        ?.toString();

    final address =
    employer!['address']
        ?.toString();

    final registrationNumber =
    employer!['registrationNumber']
        ?.toString();

    final description =
    employer!['description']
        ?.toString();

    final status =
        employer!['status']
            ?.toString() ??
            'PENDING';

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Company Profile',
          style:
          TextStyle(
            fontSize: 20,
            fontWeight:
            FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        Card(
          child: Padding(
            padding:
            const EdgeInsets.all(
              16,
            ),
            child: Column(
              children: [
                if (companyName
                    .isNotEmpty)
                  _buildInfoRow(
                    Icons.business,
                    'Company',
                    companyName,
                  ),

                if (email.isNotEmpty)
                  _buildInfoRow(
                    Icons.email,
                    'Email',
                    email,
                  ),

                if (phone.isNotEmpty)
                  _buildInfoRow(
                    Icons.phone,
                    'Phone',
                    phone,
                  ),

                if (contactPerson !=
                    null &&
                    contactPerson
                        .isNotEmpty)
                  _buildInfoRow(
                    Icons.person,
                    'Contact',
                    contactPerson,
                  ),

                if (country !=
                    null &&
                    country.isNotEmpty)
                  _buildInfoRow(
                    Icons.public,
                    'Country',
                    country,
                  ),

                if (address != null &&
                    address.isNotEmpty)
                  _buildInfoRow(
                    Icons.location_on,
                    'Address',
                    address,
                  ),

                if (registrationNumber !=
                    null &&
                    registrationNumber
                        .isNotEmpty)
                  _buildInfoRow(
                    Icons.badge,
                    'Registration',
                    registrationNumber,
                  ),

                if (description !=
                    null &&
                    description.isNotEmpty)
                  _buildInfoRow(
                    Icons.description,
                    'Description',
                    description,
                  ),

                const SizedBox(
                  height: 8,
                ),

                Row(
                  children: [
                    const Icon(
                      Icons.verified,
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    const Text(
                      'Status',
                      style:
                      TextStyle(
                        fontWeight:
                        FontWeight
                            .bold,
                      ),
                    ),

                    const Spacer(),

                    _buildStatusBadge(
                      status,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // INFO ROW
  // =========================================================

  Widget _buildInfoRow(
      IconData icon,
      String title,
      String value,
      ) {
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
            size: 21,
          ),

          const SizedBox(
            width: 12,
          ),

          SizedBox(
            width: 100,
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
            child: Text(value),
          ),
        ],
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
        'APPROVED') {
      color = Colors.green;
    } else if (normalized ==
        'REJECTED') {
      color = Colors.red;
    } else {
      color = Colors.orange;
    }

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration:
      BoxDecoration(
        borderRadius:
        BorderRadius.circular(
          20,
        ),
        color:
        color.withOpacity(
          0.15,
        ),
      ),
      child: Text(
        normalized,
        style:
        TextStyle(
          fontWeight:
          FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  // =========================================================
  // JOBS SECTION
  // =========================================================

  Widget _buildJobsSection() {
    final status =
        employer?['status']
            ?.toString()
            .toUpperCase() ??
            'PENDING';

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'My Jobs',
          style:
          TextStyle(
            fontSize: 20,
            fontWeight:
            FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        // ----------------------------------------------------
        // PENDING / REJECTED
        // ----------------------------------------------------

        if (status != 'APPROVED')
          Card(
            child: Padding(
              padding:
              const EdgeInsets.all(
                20,
              ),
              child: Column(
                children: [
                  Icon(
                    status ==
                        'REJECTED'
                        ? Icons
                        .lock_outline
                        : Icons
                        .hourglass_empty,
                    size: 45,
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    status ==
                        'REJECTED'
                        ? 'Job posting unavailable'
                        : 'Waiting for approval',
                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    status ==
                        'REJECTED'
                        ? 'Your employer account has been rejected.'
                        : 'You can post jobs after your employer account is approved.',
                    textAlign:
                    TextAlign.center,
                  ),
                ],
              ),
            ),
          )

        // ----------------------------------------------------
        // APPROVED
        // ----------------------------------------------------

        else if (jobs.isEmpty)
          Card(
            child: Padding(
              padding:
              const EdgeInsets.all(
                20,
              ),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.work_outline,
                      size: 45,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    const Text(
                      'No jobs posted yet.',
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    ElevatedButton.icon(
                      onPressed:
                      openPostJob,
                      icon:
                      const Icon(
                        Icons.add,
                      ),
                      label:
                      const Text(
                        'Post a Job',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )

        // ----------------------------------------------------
        // EXISTING JOBS
        // ----------------------------------------------------

        else
          ...jobs.map(
                (job) =>
                _buildJobCard(
                  job,
                ),
          ),
      ],
    );
  }

  // =========================================================
  // JOB CARD
  // =========================================================

  Widget _buildJobCard(
      dynamic job,
      ) {
    if (job is! Map) {
      return const SizedBox();
    }

    final data =
    Map<String, dynamic>.from(
      job,
    );

    final company =
        data['company']
            ?.toString() ??
            employer?['companyName']
                ?.toString() ??
            '';

    final position =
        data['position']
            ?.toString() ??
            'Job Position';

    final country =
        data['country']
            ?.toString() ??
            '';

    final salary =
        data['salary']
            ?.toString() ??
            '';

    final jobType =
        data['jobType']
            ?.toString() ??
            '';

    return Card(
      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),
      child: ListTile(
        leading:
        const CircleAvatar(
          child: Icon(
            Icons.work,
          ),
        ),
        title: Text(
          position,
          style:
          const TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding:
          const EdgeInsets.only(
            top: 5,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,
            children: [
              if (company.isNotEmpty)
                Text(company),

              if (country.isNotEmpty)
                Text(country),

              if (jobType.isNotEmpty)
                Text(jobType),

              if (salary.isNotEmpty)
                Text(
                  salary,
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // APPLICATIONS SECTION
  // =========================================================

  Widget _buildApplicationsSection() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Applications',
          style:
          TextStyle(
            fontSize: 20,
            fontWeight:
            FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        if (applications.isEmpty)
          Card(
            child: Padding(
              padding:
              const EdgeInsets.all(
                20,
              ),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons
                          .people_outline,
                      size: 45,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    const Text(
                      'No applications yet.',
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    OutlinedButton.icon(
                      onPressed:
                      openApplications,
                      icon:
                      const Icon(
                        Icons.people,
                      ),
                      label:
                      const Text(
                        'View Applications',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else ...[
          ...applications.map(
                (application) =>
                _buildApplicationCard(
                  application,
                ),
          ),

          const SizedBox(
            height: 8,
          ),

          SizedBox(
            width: double.infinity,
            child:
            OutlinedButton.icon(
              onPressed:
              openApplications,
              icon:
              const Icon(
                Icons.people,
              ),
              label:
              const Text(
                'View All Applications',
              ),
            ),
          ),
        ],
      ],
    );
  }

  // =========================================================
  // APPLICATION CARD
  // =========================================================

  Widget _buildApplicationCard(
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

    return Card(
      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),
      child: ListTile(
        leading:
        const CircleAvatar(
          child: Icon(
            Icons.person,
          ),
        ),
        title: Text(
          applicantName,
          style:
          const TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
        subtitle:
        Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .start,
          children: [
            Text(position),

            if (company.isNotEmpty)
              Text(company),
          ],
        ),
        trailing:
        _buildStatusBadge(
          status,
        ),
      ),
    );
  }
}