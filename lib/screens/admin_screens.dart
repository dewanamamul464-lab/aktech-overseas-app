import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/AdminEmployerService.dart';

class AdminScreens extends StatefulWidget {
  const AdminScreens({super.key});

  @override
  State<AdminScreens> createState() => _AdminScreensState();
}

class _AdminScreensState extends State<AdminScreens> {
  final AdminEmployerService adminEmployerService =
  AdminEmployerService();

  final AuthService authService = AuthService();

  List<dynamic> employers = [];

  bool loading = true;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadEmployers();
  }

  // =========================================================
  // LOAD EMPLOYERS
  // =========================================================

  Future<void> loadEmployers() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      errorMessage = null;
    });

    final data = await adminEmployerService.getAllEmployers();

    if (!mounted) return;

    if (data == null) {
      setState(() {
        loading = false;
        errorMessage =
        'Could not load employers.\n\n'
            'Check your ADMIN login and JWT token.';
      });

      return;
    }

    setState(() {
      employers = data;
      loading = false;
    });
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  Future<void> logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Admin Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('LOGOUT'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await authService.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }

  // =========================================================
  // APPROVE
  // =========================================================

  Future<void> approveEmployer(
      Map<String, dynamic> employer,
      ) async {
    final id = int.tryParse(
      employer['id'].toString(),
    );

    if (id == null) {
      showMessage('Invalid employer ID.');
      return;
    }

    final result =
    await adminEmployerService.approveEmployer(id);

    if (!mounted) return;

    if (result != null) {
      showMessage(
        '${employer['companyName'] ?? 'Employer'} '
            'approved successfully.',
      );

      await loadEmployers();
    } else {
      showMessage('Failed to approve employer.');
    }
  }

  // =========================================================
  // REJECT
  // =========================================================

  Future<void> rejectEmployer(
      Map<String, dynamic> employer,
      ) async {
    final id = int.tryParse(
      employer['id'].toString(),
    );

    if (id == null) {
      showMessage('Invalid employer ID.');
      return;
    }

    final result =
    await adminEmployerService.rejectEmployer(id);

    if (!mounted) return;

    if (result != null) {
      showMessage(
        '${employer['companyName'] ?? 'Employer'} rejected.',
      );

      await loadEmployers();
    } else {
      showMessage('Failed to reject employer.');
    }
  }

  // =========================================================
  // DELETE
  // =========================================================

  Future<void> deleteEmployer(
      Map<String, dynamic> employer,
      ) async {
    final id = int.tryParse(
      employer['id'].toString(),
    );

    if (id == null) {
      showMessage('Invalid employer ID.');
      return;
    }

    final companyName =
        employer['companyName']?.toString() ?? 'Employer';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Employer'),
          content: Text(
            'Are you sure you want to delete $companyName?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final success =
    await adminEmployerService.deleteEmployer(id);

    if (!mounted) return;

    if (success) {
      showMessage(
        'Employer deleted successfully.',
      );

      await loadEmployers();
    } else {
      showMessage(
        'Failed to delete employer.',
      );
    }
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
  // STATUS COLOR
  // =========================================================

  Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;

      case 'REJECTED':
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  // =========================================================
  // STATUS ICON
  // =========================================================

  IconData statusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Icons.check_circle;

      case 'REJECTED':
        return Icons.cancel;

      default:
        return Icons.pending;
    }
  }

  // =========================================================
  // EMPLOYER CARD
  // =========================================================

  Widget buildEmployerCard(
      Map<String, dynamic> employer,
      ) {
    final companyName =
        employer['companyName']?.toString() ??
            'Unknown Company';

    final contactPerson =
        employer['contactPerson']?.toString() ?? '';

    final email =
        employer['email']?.toString() ?? '';

    final phone =
        employer['phone']?.toString() ?? '';

    final country =
        employer['country']?.toString() ?? '';

    final address =
        employer['address']?.toString() ?? '';

    final registrationNumber =
        employer['registrationNumber']?.toString() ?? '';

    final status =
        employer['status']?.toString() ?? 'PENDING';

    final user = employer['user'];

    String username = '';

    if (user is Map) {
      username =
          user['username']?.toString() ?? '';
    }

    final color = statusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // =================================================
            // COMPANY HEADER
            // =================================================

            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  child: Text(
                    companyName.isNotEmpty
                        ? companyName[0].toUpperCase()
                        : 'E',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        companyName,
                        maxLines: 2,
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      if (username.isNotEmpty)
                        Text(
                          '@$username',
                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Flexible(
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius:
                      BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon(status),
                          size: 17,
                          color: color,
                        ),

                        const SizedBox(width: 5),

                        Flexible(
                          child: Text(
                            status,
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style: TextStyle(
                              color: color,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 30),

            // =================================================
            // EMPLOYER INFORMATION
            // =================================================

            if (contactPerson.isNotEmpty)
              buildInfoRow(
                Icons.person,
                'Contact',
                contactPerson,
              ),

            if (email.isNotEmpty)
              buildInfoRow(
                Icons.email,
                'Email',
                email,
              ),

            if (phone.isNotEmpty)
              buildInfoRow(
                Icons.phone,
                'Phone',
                phone,
              ),

            if (country.isNotEmpty)
              buildInfoRow(
                Icons.public,
                'Country',
                country,
              ),

            if (address.isNotEmpty)
              buildInfoRow(
                Icons.location_on,
                'Address',
                address,
              ),

            if (registrationNumber.isNotEmpty)
              buildInfoRow(
                Icons.badge,
                'Registration',
                registrationNumber,
              ),

            const SizedBox(height: 12),

            // =================================================
            // APPROVE / REJECT
            // =================================================

            if (status.toUpperCase() == 'PENDING')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        approveEmployer(
                          employer,
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('APPROVE'),
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.green,
                        foregroundColor:
                        Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        rejectEmployer(
                          employer,
                        );
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('REJECT'),
                      style:
                      OutlinedButton.styleFrom(
                        foregroundColor:
                        Colors.red,
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 10),

            // =================================================
            // DELETE
            // =================================================

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  deleteEmployer(
                    employer,
                  );
                },
                icon: const Icon(
                  Icons.delete_outline,
                ),
                label: const Text(
                  'DELETE EMPLOYER',
                ),
                style:
                OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // INFO ROW
  // =========================================================

  Widget buildInfoRow(
      IconData icon,
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
          ),

          const SizedBox(width: 10),

          SizedBox(
            width: 85,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              softWrap: true,
              maxLines: 10,
              overflow:
              TextOverflow.ellipsis,
            ),
          ),
        ],
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
          'Admin - Employers',
        ),

        actions: [
          // REFRESH
          IconButton(
            tooltip: 'Refresh',
            onPressed:
            loading ? null : loadEmployers,
            icon: const Icon(
              Icons.refresh,
            ),
          ),

          // LOGOUT
          IconButton(
            tooltip: 'Logout',
            onPressed: logout,
            icon: const Icon(
              Icons.logout,
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
          const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red,
              ),

              const SizedBox(height: 16),

              Text(
                errorMessage!,
                textAlign:
                TextAlign.center,
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed:
                loadEmployers,
                icon:
                const Icon(
                  Icons.refresh,
                ),
                label:
                const Text(
                  'TRY AGAIN',
                ),
              ),
            ],
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh:
        loadEmployers,
        child: employers.isEmpty
            ? ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(
              height: 250,
            ),
            Center(
              child: Text(
                'No employers found.',
              ),
            ),
          ],
        )
            : ListView(
          padding:
          const EdgeInsets.all(
            16,
          ),
          children: [
            const Text(
              'Employer Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              '${employers.length} employer(s)',
              style: TextStyle(
                color:
                Colors.grey[600],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            ...employers.map(
                  (employer) {
                if (employer is Map) {
                  return buildEmployerCard(
                    Map<String,
                        dynamic>.from(
                      employer,
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}