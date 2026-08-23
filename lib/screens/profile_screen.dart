import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/applicant_service.dart';
import '../services/auth_service.dart';
import '../services/cv_service.dart';
import '../services/profile_image_service.dart';
import '../widgets/profile_image_widget.dart';
import 'saved_jobs_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApplicantService _applicantService = ApplicantService();
  final CvService _cvService = CvService();
  final ProfileImageService _profileImageService =
  ProfileImageService();
  final AuthService _authService = AuthService();

  bool isLoading = true;
  bool isUploadingCv = false;
  bool isUploadingImage = false;

  String userRole = 'APPLICANT';

  Map<String, dynamic>? profile;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primary = Color(0xFF5B4FCF);
  static const Color primaryDark = Color(0xFF4035A8);

  static const Color teal = Color(0xFF008F95);
  static const Color green = Color(0xFF2E8B57);
  static const Color orange = Color(0xFFE88918);
  static const Color pink = Color(0xFFD64B87);
  static const Color red = Color(0xFFD64545);

  static const Color background = Color(0xFFF6F7FB);
  static const Color textPrimary = Color(0xFF202124);
  static const Color textSecondary = Color(0xFF73757A);

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  // ============================================================
  // INITIALIZE PROFILE
  // ============================================================

  Future<void> _initializeProfile() async {
    await _loadUserRole();
    await _loadProfile();
  }

  // ============================================================
  // LOAD USER ROLE
  // ============================================================

  Future<void> _loadUserRole() async {
    try {
      final role = await _authService.getRole();

      if (!mounted) return;

      setState(() {
        userRole = _normalizeRole(role);
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        userRole = 'APPLICANT';
      });
    }
  }

  // ============================================================
  // NORMALIZE ROLE
  // ============================================================

  String _normalizeRole(String? role) {
    if (role == null || role.trim().isEmpty) {
      return 'APPLICANT';
    }

    return role
        .replaceAll('ROLE_', '')
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('"', '')
        .trim()
        .toUpperCase();
  }

  // ============================================================
  // ROLE DISPLAY
  // ============================================================

  String _displayRole() {
    switch (userRole) {
      case 'ADMIN':
        return 'Administrator';

      case 'EMPLOYER':
        return 'Employer';

      case 'APPLICANT':
      default:
        return 'Applicant';
    }
  }

  // ============================================================
  // ROLE COLOR
  // ============================================================

  Color _roleColor() {
    switch (userRole) {
      case 'ADMIN':
        return red;

      case 'EMPLOYER':
        return green;

      case 'APPLICANT':
      default:
        return primary;
    }
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> _loadProfile() async {
    try {
      final result = await _applicantService.getMyProfile();

      if (!mounted) return;

      setState(() {
        profile = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage(
        'Failed to load profile: $e',
        red,
      );
    }
  }

  // ============================================================
  // SAFE PROFILE VALUE
  // ============================================================

  String _value(String key) {
    final value = profile?[key];

    if (value == null) {
      return 'Not provided';
    }

    final text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return 'Not provided';
    }

    return text;
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(
      String message,
      Color color,
      ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // ============================================================
  // UPLOAD CV
  // ============================================================

  Future<void> _uploadCv() async {
    if (isUploadingCv) return;

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result == null ||
          result.files.isEmpty ||
          result.files.single.path == null) {
        return;
      }

      final file = File(result.files.single.path!);

      if (!await file.exists()) {
        throw Exception('Selected file does not exist');
      }

      if (!mounted) return;

      setState(() {
        isUploadingCv = true;
      });

      final success = await _cvService.uploadCV(file);

      if (!mounted) return;

      if (success) {
        _showMessage(
          'CV uploaded successfully',
          green,
        );

        await _loadProfile();
      } else {
        _showMessage(
          'CV upload failed',
          red,
        );
      }
    } catch (e) {
      _showMessage(
        'CV upload failed: $e',
        red,
      );
    } finally {
      if (mounted) {
        setState(() {
          isUploadingCv = false;
        });
      }
    }
  }

  // ============================================================
  // VIEW CV
  // ============================================================

  Future<void> _viewCv() async {
    String? cvUrl = profile?['cvUrl']?.toString();

    if (cvUrl == null ||
        cvUrl.trim().isEmpty ||
        cvUrl.toLowerCase() == 'null') {
      try {
        cvUrl = await _cvService.getMyCV();
      } catch (_) {
        cvUrl = null;
      }
    }

    if (!mounted) return;

    if (cvUrl == null ||
        cvUrl.trim().isEmpty ||
        cvUrl.toLowerCase() == 'null') {
      _showMessage(
        'No CV uploaded',
        textSecondary,
      );
      return;
    }

    try {
      final uri = Uri.parse(cvUrl);

      if (!await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not open CV');
      }
    } catch (e) {
      _showMessage(
        'Unable to open CV: $e',
        red,
      );
    }
  }

  // ============================================================
  // UPLOAD PROFILE IMAGE
  // ============================================================

  Future<void> _uploadProfileImage(File imageFile) async {
    if (isUploadingImage) return;

    try {
      if (!mounted) return;

      setState(() {
        isUploadingImage = true;
      });

      final imageUrl =
      await _profileImageService.uploadProfileImage(
        imageFile,
      );

      if (!mounted) return;

      if (imageUrl != null && imageUrl.trim().isNotEmpty) {
        _showMessage(
          'Profile image updated successfully',
          green,
        );

        await _loadProfile();
      } else {
        _showMessage(
          'Profile image upload failed',
          red,
        );
      }
    } catch (e) {
      _showMessage(
        'Profile image upload failed: $e',
        red,
      );
    } finally {
      if (mounted) {
        setState(() {
          isUploadingImage = false;
        });
      }
    }
  }

  // ============================================================
  // SAVED JOBS
  // ============================================================

  void _openSavedJobs() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SavedJobsScreen(),
      ),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('LOGOUT'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await _authService.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Saved Jobs',
            onPressed: _openSavedJobs,
            icon: const Icon(
              Icons.bookmark_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(
              Icons.logout_rounded,
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: primary,
        ),
      )
          : RefreshIndicator(
        color: primary,
        onRefresh: _initializeProfile,
        child: SingleChildScrollView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildProfileHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  18,
                  16,
                  32,
                ),
                child: Column(
                  children: [
                    _buildQuickActions(),
                    const SizedBox(height: 16),
                    _buildPersonalInformation(),
                    const SizedBox(height: 16),
                    _buildProfessionalInformation(),
                    const SizedBox(height: 16),
                    _buildCvSection(),
                    const SizedBox(height: 22),
                    _buildLogoutButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader() {
    final imageUrl =
    profile?['profileImage']?.toString();

    final roleColor = _roleColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        26,
        20,
        30,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryDark,
            primary,
            Color(0xFF8274E5),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: ProfileImageWidget(
                  imageUrl: imageUrl,
                  onImageSelected:
                  _uploadProfileImage,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: isUploadingImage
                    ? const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primary,
                  ),
                )
                    : const Icon(
                  Icons.camera_alt_rounded,
                  size: 17,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Text(
            _value('fullName'),
            textAlign: TextAlign.center,
            softWrap: true,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _value('email'),
            textAlign: TextAlign.center,
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(
                alpha: 0.82,
              ),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: 17,
                  color: roleColor,
                ),
                const SizedBox(width: 7),
                Text(
                  _displayRole(),
                  style: TextStyle(
                    color: roleColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _quickActionCard(
            title: 'Saved Jobs',
            subtitle: 'Your bookmarks',
            icon: Icons.bookmark_rounded,
            color: pink,
            onTap: _openSavedJobs,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickActionCard(
            title: 'My CV',
            subtitle: 'Manage resume',
            icon: Icons.description_rounded,
            color: teal,
            onTap: _viewCv,
          ),
        ),
      ],
    );
  }

  Widget _quickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border(
              top: BorderSide(
                color: color,
                width: 4,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.04,
                ),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 23,
                ),
              ),
              const SizedBox(height: 11),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PERSONAL INFORMATION
  // ============================================================

  Widget _buildPersonalInformation() {
    return _sectionCard(
      title: 'Personal Information',
      icon: Icons.person_outline_rounded,
      color: primary,
      children: [
        _infoRow(
          Icons.person_outline,
          'Full Name',
          _value('fullName'),
          primary,
        ),
        _infoRow(
          Icons.email_outlined,
          'Email',
          _value('email'),
          pink,
        ),
        _infoRow(
          Icons.phone_outlined,
          'Phone',
          _value('phone'),
          teal,
        ),
        _infoRow(
          Icons.public_rounded,
          'Country',
          _value('country'),
          orange,
        ),
        _infoRow(
          Icons.badge_outlined,
          'Passport Number',
          _value('passportNumber'),
          primary,
          isLast: true,
        ),
      ],
    );
  }

  // ============================================================
  // PROFESSIONAL INFORMATION
  // ============================================================

  Widget _buildProfessionalInformation() {
    return _sectionCard(
      title: 'Professional Information',
      icon: Icons.work_outline_rounded,
      color: green,
      children: [
        _infoRow(
          Icons.work_history_outlined,
          'Experience',
          _value('experience'),
          orange,
        ),
        _infoRow(
          Icons.code_rounded,
          'Skills',
          _value('skills'),
          green,
          isLast: true,
        ),
      ],
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withValues(
            alpha: 0.10,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(
              alpha: 0.07,
            ),
            blurRadius: 18,
            offset: const Offset(0, 6),
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
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  // ============================================================
  // INFORMATION ROW
  // ============================================================

  Widget _infoRow(
      IconData icon,
      String label,
      String value,
      Color color, {
        bool isLast = false,
      }) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : 17,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.10,
              ),
              borderRadius:
              BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              size: 19,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  softWrap: true,
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CV SECTION
  // ============================================================

  Widget _buildCvSection() {
    final cvFileName =
    profile?['cvFileName']?.toString();

    final hasCv = cvFileName != null &&
        cvFileName.trim().isNotEmpty &&
        cvFileName.toLowerCase() != 'null';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: teal.withValues(
            alpha: 0.10,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: teal.withValues(
              alpha: 0.07,
            ),
            blurRadius: 18,
            offset: const Offset(0, 6),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: red.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: red,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My CV',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Manage your resume',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (hasCv)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4F5),
                borderRadius:
                BorderRadius.circular(15),
                border: Border.all(
                  color: red.withValues(
                    alpha: 0.12,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.description_rounded,
                    color: red,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      cvFileName!,
                      maxLines: 3,
                      overflow:
                      TextOverflow.ellipsis,
                      softWrap: true,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FAF8),
                borderRadius:
                BorderRadius.circular(15),
                border: Border.all(
                  color: teal.withValues(
                    alpha: 0.12,
                  ),
                ),
              ),
              child: const Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: teal,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You have not uploaded a CV yet.',
                      softWrap: true,
                      style: TextStyle(
                        color: textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          if (hasCv)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _viewCv,
                icon: const Icon(
                  Icons.visibility_outlined,
                ),
                label: const Text('VIEW CV'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: teal,
                  side: const BorderSide(
                    color: teal,
                  ),
                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 13,
                  ),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          if (hasCv)
            const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
              isUploadingCv ? null : _uploadCv,
              icon: isUploadingCv
                  ? const SizedBox(
                width: 18,
                height: 18,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(
                Icons.upload_file_rounded,
              ),
              label: Text(
                hasCv
                    ? 'REPLACE CV'
                    : 'UPLOAD CV',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: red,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                red.withValues(
                  alpha: 0.5,
                ),
                padding:
                const EdgeInsets.symmetric(
                  vertical: 13,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOGOUT BUTTON
  // ============================================================

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _logout,
        icon: const Icon(
          Icons.logout_rounded,
          color: red,
        ),
        label: const Text(
          'LOGOUT',
          style: TextStyle(
            color: red,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding:
          const EdgeInsets.symmetric(
            vertical: 14,
          ),
          side: BorderSide(
            color: red.withValues(
              alpha: 0.55,
            ),
          ),
          backgroundColor:
          red.withValues(alpha: 0.04),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}