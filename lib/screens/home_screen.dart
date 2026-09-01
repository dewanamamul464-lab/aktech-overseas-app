import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';

import 'jobs_screen.dart';
import 'my_applications_screen.dart';
import 'profile_screen.dart';
import 'recommended_jobs_screen.dart';
import 'saved_jobs_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService authService = AuthService();
  final ProfileService profileService = ProfileService();

  String username = 'User';
  bool loading = true;
  int? applicantId;

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  // =========================================================
  // LOAD USER PROFILE
  // =========================================================

  Future<void> loadUserProfile() async {
    try {
      debugPrint('======================================');
      debugPrint('HOME SCREEN: Loading profile...');
      debugPrint('======================================');

      final Profile? profile =
      await profileService.getProfile();

      if (!mounted) return;

      if (profile != null &&
          profile.fullName.trim().isNotEmpty) {
        setState(() {
          username = profile.fullName.trim();
          applicantId = profile.id;
          loading = false;
        });

        debugPrint(
          'HOME SCREEN: FULL NAME = "$username"',
        );
      } else {
        final savedUsername =
        await authService.getUsername();

        if (!mounted) return;

        setState(() {
          username = savedUsername != null &&
              savedUsername.trim().isNotEmpty
              ? savedUsername.trim()
              : 'User';

          loading = false;
        });
      }
    } catch (e) {
      debugPrint(
        'HOME SCREEN PROFILE ERROR: $e',
      );

      try {
        final savedUsername =
        await authService.getUsername();

        if (!mounted) return;

        setState(() {
          username = savedUsername != null &&
              savedUsername.trim().isNotEmpty
              ? savedUsername.trim()
              : 'User';

          loading = false;
        });
      } catch (e) {
        if (!mounted) return;

        setState(() {
          username = 'User';
          loading = false;
        });
      }
    }
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  Future<void> logout() async {
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
              fontWeight: FontWeight.w800,
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
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'LOGOUT',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
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
  // OPEN PROFILE
  // =========================================================

  void openAiJobMatches() {
    if (applicantId == null || applicantId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Applicant profile ID is not available.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecommendedJobsScreen(
          applicantId: applicantId!,
        ),
      ),
    );
  }

  void openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  // =========================================================
  // OPEN JOBS
  // =========================================================

  void openJobs() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const JobsScreen(),
      ),
    );
  }

  // =========================================================
  // OPEN APPLICATIONS
  // =========================================================

  void openApplications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const MyApplicationsScreen(),
      ),
    );
  }

  // =========================================================
  // OPEN SAVED JOBS
  // =========================================================

  void openSavedJobs() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
        const SavedJobsScreen(),
      ),
    );
  }

  // =========================================================
  // NOTIFICATIONS
  // =========================================================

  void openNotifications() {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior:
        SnackBarBehavior.floating,
        margin:
        const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16,
        ),
        duration:
        const Duration(seconds: 2),
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(15),
        ),
        content: const Row(
          children: [
            Icon(
              Icons
                  .notifications_active_rounded,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'No new notifications',
                maxLines: 2,
                overflow:
                TextOverflow.ellipsis,
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF4F7FC),

      // =======================================================
      // APP BAR
      // =======================================================

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor:
        Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,

        title: Row(
          children: [
            // -------------------------------------------------
            // LOGO
            // -------------------------------------------------

            Container(
              width: 43,
              height: 43,
              padding:
              const EdgeInsets.all(5),
              decoration:
              BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.06),
                    blurRadius: 8,
                    offset:
                    const Offset(0, 3),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/aktech_brand_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (
                    context,
                    error,
                    stackTrace,
                    ) {
                  return const Icon(
                    Icons
                        .business_rounded,
                    color:
                    Color(0xFF1565C0),
                  );
                },
              ),
            ),

            const SizedBox(width: 10),

            // -------------------------------------------------
            // BRAND NAME
            // -------------------------------------------------

            const Expanded(
              child: Text(
                'AKTech Overseas',
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style: TextStyle(
                  color:
                  Color(0xFF102A43),
                  fontSize: 19,
                  fontWeight:
                  FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),

        actions: [
          // -------------------------------------------------
          // NOTIFICATIONS
          // -------------------------------------------------

          IconButton(
            tooltip:
            'Notifications',
            onPressed:
            openNotifications,
            icon: Container(
              width: 38,
              height: 38,
              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFFF0F5FF,
                ),
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),
              child: const Icon(
                Icons
                    .notifications_none_rounded,
                color:
                Color(0xFF1565C0),
                size: 22,
              ),
            ),
          ),

          // -------------------------------------------------
          // PROFILE
          // -------------------------------------------------

          Padding(
            padding:
            const EdgeInsets.only(
              right: 8,
            ),
            child: IconButton(
              tooltip: 'Profile',
              onPressed:
              openProfile,
              icon: Container(
                width: 38,
                height: 38,
                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xFFEFF8F5,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
                child: const Icon(
                  Icons
                      .person_outline_rounded,
                  color:
                  Color(0xFF00897B),
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),

      // =======================================================
      // BODY
      // =======================================================

      body: loading
          ? const Center(
        child:
        CircularProgressIndicator(
          color:
          Color(0xFF1565C0),
        ),
      )
          : SafeArea(
        child: LayoutBuilder(
          builder: (
              context,
              constraints,
              ) {
            return RefreshIndicator(
              color:
              const Color(
                0xFF1565C0,
              ),
              backgroundColor:
              Colors.white,
              onRefresh:
              loadUserProfile,

              child:
              SingleChildScrollView(
                physics:
                const AlwaysScrollableScrollPhysics(),

                child:
                ConstrainedBox(
                  constraints:
                  BoxConstraints(
                    minHeight:
                    constraints
                        .maxHeight,
                  ),

                  child: Padding(
                    padding:
                    const EdgeInsets
                        .fromLTRB(
                      18,
                      18,
                      18,
                      24,
                    ),

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [
                        // =====================================
                        // WELCOME
                        // =====================================

                        _buildWelcomeCard(
                          constraints
                              .maxWidth,
                        ),

                        const SizedBox(
                          height: 27,
                        ),

                        // =====================================
                        // QUICK ACTIONS TITLE
                        // =====================================

                        Row(
                          children: [
                            Container(
                              width: 5,
                              height: 24,
                              decoration:
                              BoxDecoration(
                                color:
                                const Color(
                                  0xFF1565C0,
                                ),
                                borderRadius:
                                BorderRadius
                                    .circular(
                                  5,
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            const Expanded(
                              child:
                              Text(
                                'Quick Actions',
                                maxLines: 1,
                                overflow:
                                TextOverflow
                                    .ellipsis,
                                style:
                                TextStyle(
                                  color:
                                  Color(
                                    0xFF102A43,
                                  ),
                                  fontSize:
                                  21,
                                  fontWeight:
                                  FontWeight
                                      .w900,
                                  letterSpacing:
                                  -0.4,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 15,
                        ),

                        // =====================================
                        // QUICK ACTIONS
                        // =====================================

                        _buildQuickActions(
                          constraints
                              .maxWidth,
                        ),

                        const SizedBox(
                          height: 30,
                        ),

                        // =====================================
                        // LOGOUT
                        // =====================================

                        _buildLogoutButton(),

                        const SizedBox(
                          height: 16,
                        ),

                        Center(
                          child: Text(
                            'AKTech Overseas',
                            maxLines: 1,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            TextStyle(
                              color:
                              Colors
                                  .grey
                                  .shade500,
                              fontSize: 12,
                              fontWeight:
                              FontWeight
                                  .w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // =========================================================
  // WELCOME CARD
  // =========================================================

  Widget _buildWelcomeCard(
      double screenWidth,
      ) {
    final bool smallScreen =
        screenWidth < 360;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        smallScreen ? 18 : 22,
      ),

      decoration: BoxDecoration(
        gradient:
        const LinearGradient(
          colors: [
            Color(0xFF092A5E),
            Color(0xFF0D5BD7),
            Color(0xFF26A6FF),
          ],
          begin:
          Alignment.topLeft,
          end:
          Alignment.bottomRight,
        ),

        borderRadius:
        BorderRadius.circular(27),

        boxShadow: [
          BoxShadow(
            color:
            const Color(
              0xFF1565C0,
            ).withOpacity(0.25),
            blurRadius: 22,
            offset:
            const Offset(0, 10),
          ),
        ],
      ),

      child: Stack(
        children: [
          // -------------------------------------------------
          // BACKGROUND DECORATION
          // -------------------------------------------------

          Positioned(
            right: -55,
            top: -65,
            child: Container(
              width: 165,
              height: 165,
              decoration:
              BoxDecoration(
                color: Colors.white
                    .withOpacity(
                  0.07,
                ),
                shape:
                BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            right: 15,
            bottom: -100,
            child: Container(
              width: 170,
              height: 170,
              decoration:
              BoxDecoration(
                color: Colors.white
                    .withOpacity(
                  0.05,
                ),
                shape:
                BoxShape.circle,
              ),
            ),
          ),

          // -------------------------------------------------
          // CONTENT
          // -------------------------------------------------

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.center,
            children: [
              // =================================================
              // TEXT
              // =================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration:
                      BoxDecoration(
                        color: Colors.white
                            .withOpacity(
                          0.15,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          30,
                        ),
                      ),
                      child:
                      const Text(
                        'WELCOME BACK',
                        maxLines: 1,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style:
                        TextStyle(
                          color:
                          Colors.white,
                          fontSize: 10,
                          fontWeight:
                          FontWeight
                              .w900,
                          letterSpacing:
                          0.8,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    const Text(
                      'Hello,',
                      maxLines: 1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      TextStyle(
                        color:
                        Colors.white70,
                        fontSize: 15,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      username,
                      maxLines: 2,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      TextStyle(
                        color:
                        Colors.white,
                        fontSize:
                        smallScreen
                            ? 23
                            : 27,
                        height: 1.12,
                        fontWeight:
                        FontWeight
                            .w900,
                        letterSpacing:
                        -0.7,
                      ),
                    ),

                    const SizedBox(
                      height: 9,
                    ),

                    const Text(
                      'Find your next opportunity around the world.',
                      maxLines: 2,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      TextStyle(
                        color:
                        Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              // =================================================
              // LOGO
              // =================================================

              Container(
                width:
                smallScreen
                    ? 72
                    : 88,
                height:
                smallScreen
                    ? 72
                    : 88,
                padding:
                EdgeInsets.all(
                  smallScreen
                      ? 8
                      : 10,
                ),

                decoration:
                BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius
                      .circular(
                    22,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(
                        0.15,
                      ),
                      blurRadius: 14,
                      offset:
                      const Offset(
                        0,
                        7,
                      ),
                    ),
                  ],
                ),

                child: Image.asset(
                  'assets/images/aktech_brand_logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (
                      context,
                      error,
                      stackTrace,
                      ) {
                    return const Icon(
                      Icons
                          .business_rounded,
                      color:
                      Color(
                        0xFF1565C0,
                      ),
                      size: 38,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // QUICK ACTIONS
  // =========================================================

  Widget _buildQuickActions(
      double screenWidth,
      ) {
    final bool smallScreen =
        screenWidth < 360;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _actionCard(
                icon:
                Icons
                    .work_history_rounded,
                title:
                'Find Jobs',
                iconColor:
                const Color(
                  0xFF1565C0,
                ),
                iconBackground:
                const Color(
                  0xFFE5F0FF,
                ),
                compact:
                smallScreen,
                onTap:
                openJobs,
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: _actionCard(
                icon:
                Icons
                    .task_alt_rounded,
                title:
                'Applications',
                iconColor:
                const Color(
                  0xFF7B1FA2,
                ),
                iconBackground:
                const Color(
                  0xFFF4E6FA,
                ),
                compact:
                smallScreen,
                onTap:
                openApplications,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 12,
        ),

        Row(
          children: [
            Expanded(
              child: _actionCard(
                icon:
                Icons
                    .bookmark_added_rounded,
                title:
                'Saved Jobs',
                iconColor:
                const Color(
                  0xFF00897B,
                ),
                iconBackground:
                const Color(
                  0xFFE0F5F1,
                ),
                compact:
                smallScreen,
                onTap:
                openSavedJobs,
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: _actionCard(
                icon:
                Icons
                    .account_circle_rounded,
                title:
                'My Profile',
                iconColor:
                const Color(
                  0xFFEF6C00,
                ),
                iconBackground:
                const Color(
                  0xFFFFF0DE,
                ),
                compact:
                smallScreen,
                onTap:
                openProfile,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 12,
        ),

        SizedBox(
          width: double.infinity,
          child: _actionCard(
            icon: Icons.auto_awesome_rounded,
            title: 'AI Job Matches',
            iconColor: const Color(0xFF6A1B9A),
            iconBackground: const Color(0xFFF3E5F5),
            compact: smallScreen,
            onTap: openAiJobMatches,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // 3D ACTION CARD
  // =========================================================

  Widget _actionCard({
    required IconData icon,
    required String title,
    required Color iconColor,
    required Color iconBackground,
    required VoidCallback onTap,
    required bool compact,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius:
      BorderRadius.circular(22),

      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(22),

        child: Container(
          width: double.infinity,

          padding:
          EdgeInsets.symmetric(
            horizontal:
            compact ? 8 : 12,
            vertical:
            compact ? 17 : 20,
          ),

          decoration:
          BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(22),

            border: Border.all(
              color:
              Colors.white,
              width: 1.2,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(
                  0.07,
                ),
                blurRadius: 15,
                offset:
                const Offset(
                  0,
                  7,
                ),
              ),
              BoxShadow(
                color: Colors.white
                    .withOpacity(
                  0.9,
                ),
                blurRadius: 5,
                offset:
                const Offset(
                  -3,
                  -3,
                ),
              ),
            ],
          ),

          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              // =================================================
              // 3D ICON CONTAINER
              // =================================================

              Container(
                width:
                compact ? 58 : 64,
                height:
                compact ? 58 : 64,

                decoration:
                BoxDecoration(
                  gradient:
                  LinearGradient(
                    begin:
                    Alignment
                        .topLeft,
                    end:
                    Alignment
                        .bottomRight,
                    colors: [
                      Colors.white,
                      iconBackground,
                    ],
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: iconColor
                          .withOpacity(
                        0.22,
                      ),
                      blurRadius: 10,
                      offset:
                      const Offset(
                        0,
                        6,
                      ),
                    ),
                    BoxShadow(
                      color: Colors.white
                          .withOpacity(
                        0.9,
                      ),
                      blurRadius: 5,
                      offset:
                      const Offset(
                        -3,
                        -3,
                      ),
                    ),
                  ],
                ),

                child: Stack(
                  alignment:
                  Alignment.center,
                  children: [
                    // -----------------------------------------
                    // SOFT GLOW
                    // -----------------------------------------

                    Container(
                      width:
                      compact
                          ? 43
                          : 48,
                      height:
                      compact
                          ? 43
                          : 48,

                      decoration:
                      BoxDecoration(
                        shape:
                        BoxShape
                            .circle,
                        color: iconColor
                            .withOpacity(
                          0.10,
                        ),
                      ),
                    ),

                    // -----------------------------------------
                    // MAIN ICON
                    // -----------------------------------------

                    Icon(
                      icon,
                      color:
                      iconColor,
                      size:
                      compact
                          ? 29
                          : 32,
                    ),

                    // -----------------------------------------
                    // HIGHLIGHT
                    // -----------------------------------------

                    Positioned(
                      top:
                      compact
                          ? 10
                          : 11,
                      left:
                      compact
                          ? 13
                          : 15,

                      child:
                      Container(
                        width: 7,
                        height: 7,
                        decoration:
                        BoxDecoration(
                          color: Colors
                              .white
                              .withOpacity(
                            0.85,
                          ),
                          shape:
                          BoxShape
                              .circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height:
                compact
                    ? 11
                    : 13,
              ),

              // =================================================
              // TITLE
              // =================================================

              Text(
                title,
                maxLines: 1,
                overflow:
                TextOverflow
                    .ellipsis,
                textAlign:
                TextAlign.center,
                style:
                const TextStyle(
                  color:
                  Color(
                    0xFF172033,
                  ),
                  fontSize: 14,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // LOGOUT BUTTON
  // =========================================================

  Widget _buildLogoutButton() {
    return Material(
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(19),

      child: InkWell(
        onTap: logout,
        borderRadius:
        BorderRadius.circular(19),

        child: Container(
          width: double.infinity,

          padding:
          const EdgeInsets
              .symmetric(
            horizontal: 16,
            vertical: 14,
          ),

          decoration:
          BoxDecoration(
            color: Colors.white,

            borderRadius:
            BorderRadius.circular(
              19,
            ),

            border: Border.all(
              color:
              const Color(
                0xFFFFD9DD,
              ),
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(
                  0.04,
                ),
                blurRadius: 12,
                offset:
                const Offset(
                  0,
                  5,
                ),
              ),
            ],
          ),

          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,

                decoration:
                BoxDecoration(
                  gradient:
                  const LinearGradient(
                    colors: [
                      Color(0xFFFFEBEE),
                      Color(0xFFFFF5F6),
                    ],
                  ),

                  borderRadius:
                  BorderRadius
                      .circular(
                    14,
                  ),
                ),

                child: const Icon(
                  Icons
                      .logout_rounded,
                  color:
                  Color(
                    0xFFD32F2F,
                  ),
                  size: 22,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    Text(
                      'Logout',
                      maxLines: 1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      TextStyle(
                        color:
                        Color(
                          0xFFD32F2F,
                        ),
                        fontSize: 15,
                        fontWeight:
                        FontWeight
                            .w900,
                      ),
                    ),

                    SizedBox(
                      height: 2,
                    ),

                    Text(
                      'Sign out of your account',
                      maxLines: 1,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      TextStyle(
                        color:
                        Color(
                          0xFF98A2B3,
                        ),
                        fontSize: 11.5,
                        fontWeight:
                        FontWeight
                            .w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              const Icon(
                Icons
                    .chevron_right_rounded,
                color:
                Color(
                  0xFF98A2B3,
                ),
                size: 23,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
