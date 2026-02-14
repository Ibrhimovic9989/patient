import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:clinic/core/theme/theme.dart';
import 'package:clinic/presentation/dashboard/dashboard_screen.dart';
import 'package:clinic/presentation/auth/widgets/google_signin_button.dart';
import 'package:clinic/presentation/auth/clinic_onboarding_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final supabase = Supabase.instance.client;
  StreamSubscription<AuthState>? _authSubscription;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAuthListener();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _initializeAuthListener() {
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleSuccessfulAuth(session);
        });
      }
    });
  }

  Future<void> _handleSuccessfulAuth(Session session) async {
    final email = session.user.email ?? 'Unknown User';
    final fullName = session.user.userMetadata?['full_name'] ?? email;

    // Check if user is a clinic admin (email matches clinic.owner_email)
    final clinicResponse = await supabase
        .from('clinic')
        .select('id, name')
        .eq('owner_email', email)
        .eq('is_active', true)
        .maybeSingle();

    if (mounted) {
      if (clinicResponse != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome, $fullName'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are not authorized as a clinic admin. Please contact support.'),
            backgroundColor: Colors.red,
          ),
        );
        await supabase.auth.signOut();
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current app URL for redirect
      String currentUrl;
      if (kIsWeb) {
        currentUrl = Uri.base.toString().split('?').first;
      } else {
        currentUrl = 'http://localhost:50003'; // Clinic app port
      }

      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: currentUrl,
        authScreenLaunchMode: LaunchMode.platformDefault,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.local_hospital,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 32),
                Text(
                  'Clinic Login',
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to manage your clinic',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else
                  GoogleSignInButton(
                    onPressed: _handleGoogleSignIn,
                  ),
                const SizedBox(height: 24),
                Text(
                  'Only clinic administrators can sign in. Your email must match the clinic owner email.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ClinicOnboardingScreen(),
                      ),
                    );
                  },
                  child: const Text('New Clinic? Register Here'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
