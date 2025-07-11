import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/clinic/clinic_dashboard_screen.dart';
import 'screens/professional/professional_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext ctx) {
    return MaterialApp(
      title: 'PulseGig',
      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        SignUpScreen.routeName: (_) => const SignUpScreen(),
        RegistrationScreen.routeName: (_) => const RegistrationScreen(),
        ClinicDashboardScreen.routeName: (_) => const ClinicDashboardScreen(),
        ProfessionalDashboardScreen.routeName: (_) => const ProfessionalDashboardScreen(),
      },
      home: StreamBuilder<User?>(
        stream: AuthService().userChanges,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final user = snap.data;
          if (user == null) {
            return const LoginScreen();
          }
          return FutureBuilder<String?>(
            future: AuthService().getUserRole(user),
            builder: (ctx, roleSnap) {
              if (roleSnap.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              final role = roleSnap.data;
              if (role == 'office' || role == 'clinic') {
                return const ClinicDashboardScreen();
              } else if (role == 'professional') {
                return const ProfessionalDashboardScreen();
              } else {
                return const LoginScreen();
              }
            },
          );
        },
      ),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue[600],
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue[600]!),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        )
      )
    );
  }
}