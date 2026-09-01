import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

import 'providers/ai_job_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_screens.dart';
import 'screens/employer_dashboard_screen.dart';
import 'screens/post_job_screen.dart';
import 'screens/employer_applications_screen.dart';
import 'screens/recommended_jobs_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AiJobProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AKTech Overseas',
        initialRoute: '/',
        routes: {
          // SPLASH
          '/': (context) => const SplashScreen(),

          // LOGIN
          '/login': (context) => const LoginScreen(),

          // NORMAL USER
          '/home': (context) => const HomeScreen(),

          // ADMIN
          '/admin': (context) => const AdminScreens(),

          // EMPLOYER DASHBOARD
          '/employer': (context) => const EmployerDashboardScreen(),

          // AI JOB MATCHES
          '/ai-job-matches': (context) {
            final arguments = ModalRoute.of(context)?.settings.arguments;

            int? applicantId;

            if (arguments is int) {
              applicantId = arguments;
            } else if (arguments != null) {
              applicantId = int.tryParse(arguments.toString());
            }

            if (applicantId == null) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'Applicant ID not found.',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              );
            }

            return RecommendedJobsScreen(
              applicantId: applicantId,
            );
          },

          // POST JOB
          '/post-job': (context) {
            final arguments = ModalRoute.of(context)?.settings.arguments;

            int? employerId;

            if (arguments is int) {
              employerId = arguments;
            } else if (arguments != null) {
              employerId = int.tryParse(arguments.toString());
            }

            if (employerId == null) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'Employer ID not found.',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              );
            }

            return PostJobScreen(
              employerId: employerId,
            );
          },

          // EMPLOYER APPLICATIONS
          '/employer-applications': (context) {
            final arguments = ModalRoute.of(context)?.settings.arguments;

            int? employerId;

            if (arguments is int) {
              employerId = arguments;
            } else if (arguments != null) {
              employerId = int.tryParse(arguments.toString());
            }

            if (employerId == null) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'Employer ID not found.',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              );
            }

            return EmployerApplicationsScreen(
              employerId: employerId,
            );
          },
        },
      ),
    );
  }
}