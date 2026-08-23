import 'package:flutter/material.dart';

import '../services/employer_service.dart';

class PostJobScreen extends StatefulWidget {
  final int employerId;

  const PostJobScreen({
    super.key,
    required this.employerId,
  });

  @override
  State<PostJobScreen> createState() =>
      _PostJobScreenState();
}

class _PostJobScreenState
    extends State<PostJobScreen> {
  final EmployerService employerService =
  EmployerService();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController companyController =
  TextEditingController();

  final TextEditingController positionController =
  TextEditingController();

  final TextEditingController countryController =
  TextEditingController();

  final TextEditingController salaryController =
  TextEditingController();

  final TextEditingController descriptionController =
  TextEditingController();

  final TextEditingController requirementsController =
  TextEditingController();

  final TextEditingController experienceController =
  TextEditingController();

  final TextEditingController vacanciesController =
  TextEditingController();

  final TextEditingController expiryDateController =
  TextEditingController();

  String jobType = 'FOREIGN';

  bool posting = false;

  @override
  void dispose() {
    companyController.dispose();
    positionController.dispose();
    countryController.dispose();
    salaryController.dispose();
    descriptionController.dispose();
    requirementsController.dispose();
    experienceController.dispose();
    vacanciesController.dispose();
    expiryDateController.dispose();

    super.dispose();
  }

  // =========================================================
  // POST JOB
  // =========================================================

  Future<void> submitJob() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      posting = true;
    });

    try {
      final jobData = {
        'company': companyController.text.trim(),
        'position': positionController.text.trim(),
        'country': countryController.text.trim(),
        'salary': salaryController.text.trim(),
        'jobType': jobType,
        'description':
        descriptionController.text.trim(),
        'requirements':
        requirementsController.text.trim(),
        'experience':
        experienceController.text.trim(),
        'vacancies': int.tryParse(
          vacanciesController.text.trim(),
        ) ??
            1,
        'expiryDate':
        expiryDateController.text.trim(),
      };

      print('=================================');
      print('POSTING JOB');
      print('EMPLOYER ID: ${widget.employerId}');
      print('JOB DATA: $jobData');
      print('=================================');

      final result =
      await employerService.postJob(
        employerId: widget.employerId,
        jobData: jobData,
      );

      if (!mounted) return;

      if (result != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Job posted successfully.',
            ),
          ),
        );

        Navigator.pop(
          context,
          true,
        );

        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to post job.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Error posting job: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          posting = false;
        });
      }
    }
  }

  // =========================================================
  // DATE PICKER
  // =========================================================

  Future<void> selectExpiryDate() async {
    final now = DateTime.now();

    final selectedDate =
    await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(
        now.year + 5,
      ),
    );

    if (selectedDate == null) {
      return;
    }

    final month =
    selectedDate.month
        .toString()
        .padLeft(2, '0');

    final day =
    selectedDate.day
        .toString()
        .padLeft(2, '0');

    expiryDateController.text =
    '${selectedDate.year}-$month-$day';
  }

  // =========================================================
  // TEXT FIELD
  // =========================================================

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool requiredField = true,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: requiredField
            ? (value) {
          if (value == null ||
              value.trim().isEmpty) {
            return '$label is required';
          }

          return null;
        }
            : null,
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
          'Post a Job',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding:
          const EdgeInsets.all(16),
          children: [
            const Text(
              'Job Information',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // COMPANY

            buildTextField(
              controller:
              companyController,
              label: 'Company',
              icon: Icons.business,
            ),

            // POSITION

            buildTextField(
              controller:
              positionController,
              label: 'Job Position',
              icon: Icons.work,
            ),

            // COUNTRY

            buildTextField(
              controller:
              countryController,
              label: 'Country',
              icon: Icons.public,
            ),

            // SALARY

            buildTextField(
              controller:
              salaryController,
              label: 'Salary',
              icon: Icons.payments,
            ),

            // JOB TYPE

            DropdownButtonFormField<String>(
              value: jobType,
              decoration:
              const InputDecoration(
                labelText: 'Job Type',
                prefixIcon:
                Icon(Icons.category),
                border:
                OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'FOREIGN',
                  child: Text(
                    'Foreign',
                  ),
                ),
                DropdownMenuItem(
                  value: 'DOMESTIC',
                  child: Text(
                    'Domestic',
                  ),
                ),
              ],
              onChanged: posting
                  ? null
                  : (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  jobType = value;
                });
              },
            ),

            const SizedBox(
              height: 16,
            ),

            // EXPERIENCE

            buildTextField(
              controller:
              experienceController,
              label: 'Experience',
              icon: Icons.timeline,
            ),

            // VACANCIES

            buildTextField(
              controller:
              vacanciesController,
              label: 'Vacancies',
              icon: Icons.people,
              keyboardType:
              TextInputType.number,
            ),

            // DESCRIPTION

            buildTextField(
              controller:
              descriptionController,
              label: 'Description',
              icon: Icons.description,
              maxLines: 5,
            ),

            // REQUIREMENTS

            buildTextField(
              controller:
              requirementsController,
              label: 'Requirements',
              icon: Icons.list_alt,
              maxLines: 5,
            ),

            // EXPIRY DATE

            Padding(
              padding:
              const EdgeInsets.only(
                bottom: 16,
              ),
              child: TextFormField(
                controller:
                expiryDateController,
                readOnly: true,
                onTap:
                selectExpiryDate,
                decoration:
                const InputDecoration(
                  labelText:
                  'Expiry Date',
                  prefixIcon:
                  Icon(
                    Icons.calendar_today,
                  ),
                  border:
                  OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Expiry Date is required';
                  }

                  return null;
                },
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            // POST BUTTON

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed:
                posting
                    ? null
                    : submitJob,
                icon: posting
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    color:
                    Colors.white,
                  ),
                )
                    : const Icon(
                  Icons
                      .publish,
                ),
                label: Text(
                  posting
                      ? 'Posting Job...'
                      : 'Post Job',
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}