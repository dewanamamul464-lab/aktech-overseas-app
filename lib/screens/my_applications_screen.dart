import 'package:flutter/material.dart';

import '../services/application_service.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() =>
      _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  final ApplicationService service = ApplicationService();

  List<dynamic> applications = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadApplications();
  }

  Future<void> loadApplications() async {
    setState(() {
      loading = true;
    });

    final data = await service.getMyApplications();

    if (!mounted) return;

    setState(() {
      applications = data;
      loading = false;
    });
  }

  // =========================================================
  // STATUS COLOR
  // =========================================================

  Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case "APPROVED":
      case "ACCEPTED":
        return Colors.green;

      case "REJECTED":
        return Colors.red;

      case "PENDING":
        return Colors.orange;

      default:
        return Colors.blue;
    }
  }

  // =========================================================
  // APPLICATION CARD
  // =========================================================

  Widget applicationCard(dynamic application) {
    final position =
        application["position"]?.toString() ?? "Unknown Position";

    final company =
        application["company"]?.toString() ?? "N/A";

    final applicantName =
        application["applicantName"]?.toString() ?? "N/A";

    final status =
        application["status"]?.toString() ?? "N/A";

    return Card(
      margin: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 12,
      ),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // JOB POSITION
            Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.work,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    position,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // COMPANY
            Row(
              children: [
                const Icon(
                  Icons.business,
                  size: 20,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    company,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // APPLICANT
            Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 20,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    applicantName,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            const Divider(),

            const SizedBox(height: 8),

            // STATUS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Application Status",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor(status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor(status),
                      fontWeight: FontWeight.bold,
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

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Applications"),
        centerTitle: true,

        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadApplications,
          ),
        ],
      ),

      body: loading
          ? const Center(
        child: CircularProgressIndicator(),
      )

          : applications.isEmpty
          ? RefreshIndicator(
        onRefresh: loadApplications,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 180),

            Icon(
              Icons.assignment_outlined,
              size: 70,
              color: Colors.grey,
            ),

            SizedBox(height: 20),

            Center(
              child: Text(
                "No applications found",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SizedBox(height: 8),

            Center(
              child: Text(
                "Apply for a job to see your applications here.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      )

          : RefreshIndicator(
        onRefresh: loadApplications,
        child: ListView.builder(
          padding: const EdgeInsets.only(
            top: 16,
            bottom: 20,
          ),
          itemCount: applications.length,
          itemBuilder: (context, index) {
            return applicationCard(
              applications[index],
            );
          },
        ),
      ),
    );
  }
}