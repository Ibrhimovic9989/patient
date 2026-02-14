import 'package:flutter/material.dart';
import 'package:clinic/core/theme/theme.dart';
import 'package:clinic/presentation/auth/login_screen.dart';
import 'package:clinic/presentation/dashboard/dashboard_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToAuthScreen();
  }

  void _navigateToAuthScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Check if user is already signed in
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;
    
    if (mounted) {
      if (session != null) {
        // User is signed in, check if they're a clinic admin
        final email = session.user.email;
        if (email != null) {
          final clinicResponse = await supabase
              .from('clinic')
              .select('id, name')
              .eq('owner_email', email)
              .eq('is_active', true)
              .maybeSingle();
          
          if (clinicResponse != null) {
            // User is clinic admin, go to dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
            return;
          }
        }
      }
      
      // Not signed in or not clinic admin, go to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_hospital,
              size: 80,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Clinic Management',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
