import 'dart:async';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {
  final AuthService authService =
  AuthService();

  @override
  void initState() {
    super.initState();

    _startApp();
  }

  // =========================================================
  // START APP
  // =========================================================

  Future<void> _startApp() async {
    // Small splash delay
    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    // -------------------------------------------------------
    // CHECK LOGIN
    // -------------------------------------------------------

    final loggedIn =
    await authService.isLoggedIn();

    if (!mounted) return;

    if (!loggedIn) {
      Navigator.pushReplacementNamed(
        context,
        "/login",
      );

      return;
    }

    // -------------------------------------------------------
    // GET ROLE
    // -------------------------------------------------------

    final role =
    await authService.getRole();

    print("================================");
    print("SPLASH SCREEN");
    print("LOGGED IN: $loggedIn");
    print("ROLE: $role");
    print("================================");

    if (!mounted) return;

    // -------------------------------------------------------
    // ROLE BASED NAVIGATION
    // -------------------------------------------------------

    if (role == "ADMIN") {
      Navigator.pushReplacementNamed(
        context,
        "/admin",
      );
    } else if (role == "EMPLOYER") {
      Navigator.pushReplacementNamed(
        context,
        "/employer",
      );
    } else {
      Navigator.pushReplacementNamed(
        context,
        "/home",
      );
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(0xffF5F7FA),

      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [
              // ------------------------------------------------
              // LOGO
              // ------------------------------------------------

              Image.asset(
                "assets/images/aktech_brand_logo.png",
                height: 150,
              ),

              const SizedBox(height: 30),

              const Text(
                "AKTech Overseas",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Your Overseas Career Partner",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 35),

              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}