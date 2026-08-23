import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'register_screen.dart';
import 'admin_screens.dart';
import 'employer_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController usernameController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final AuthService authService = AuthService();

  bool loading = false;
  bool hidePassword = true;

  // ============================================================
  // NORMALIZE ROLE
  // ============================================================

  String _normalizeRole(String? role) {
    if (role == null || role.trim().isEmpty) {
      return '';
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
  // LOGIN
  // ============================================================

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    // ==========================================================
    // VALIDATION
    // ==========================================================

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter username and password',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      loading = true;
    });

    try {
      // ========================================================
      // CALL AUTH SERVICE
      // ========================================================

      final bool success = await authService.login(
        username,
        password,
      );

      if (!mounted) return;

      // ========================================================
      // LOGIN FAILED
      // ========================================================

      if (!success) {
        setState(() {
          loading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Invalid username or password',
            ),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      // ========================================================
      // VERIFY TOKEN
      // ========================================================

      final savedToken = await authService.getToken();

      if (savedToken == null || savedToken.isEmpty) {
        setState(() {
          loading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Login succeeded but JWT token was not saved.',
            ),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      // ========================================================
      // GET ROLE FROM AUTH SERVICE
      // ========================================================

      final storedRole = await authService.getRole();

      final role = _normalizeRole(storedRole);

      // ========================================================
      // DEBUG
      // ========================================================

      final storedUsername =
      await authService.getUsername();

      print('======================================');
      print('LOGIN SCREEN');
      print('USERNAME: ${storedUsername ?? username}');
      print('ROLE: $role');
      print('TOKEN EXISTS: true');
      print('TOKEN LENGTH: ${savedToken.length}');
      print('======================================');

      // ========================================================
      // ROLE NOT FOUND
      // ========================================================

      if (role.isEmpty) {
        setState(() {
          loading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Login successful, but user role was not returned by the server.',
            ),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      // ========================================================
      // ADMIN
      // ========================================================

      if (role == 'ADMIN') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Admin Login Successful',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/admin',
              (route) => false,
        );

        return;
      }

      // ========================================================
      // EMPLOYER
      // ========================================================

      if (role == 'EMPLOYER') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Employer Login Successful',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/employer',
              (route) => false,
        );

        return;
      }

      // ========================================================
      // APPLICANT
      // ========================================================

      if (role == 'APPLICANT') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Applicant Login Successful',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
              (route) => false,
        );

        return;
      }

      // ========================================================
      // UNKNOWN ROLE
      // ========================================================

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unknown account role: $role',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      print('LOGIN SCREEN ERROR: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login error: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                // =================================================
                // LOGO
                // =================================================

                Image.asset(
                  'assets/images/aktech_brand_logo.png',
                  height: 120,
                ),

                const SizedBox(
                  height: 20,
                ),

                // =================================================
                // TITLE
                // =================================================

                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                const Text(
                  'Login to continue your overseas career journey',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(
                  height: 40,
                ),

                // =================================================
                // USERNAME
                // =================================================

                TextField(
                  controller: usernameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter Username',
                    prefixIcon: const Icon(
                      Icons.person,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                // =================================================
                // PASSWORD
                // =================================================

                TextField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (!loading) {
                      login();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter Password',
                    prefixIcon: const Icon(
                      Icons.lock,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          hidePassword =
                          !hidePassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                // =================================================
                // LOGIN BUTTON
                // =================================================

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed:
                    loading ? null : login,
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(15),
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                      width: 25,
                      height: 25,
                      child:
                      CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                        : const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                // =================================================
                // REGISTER
                // =================================================

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                    ),
                    TextButton(
                      onPressed: loading
                          ? null
                          : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                            const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}