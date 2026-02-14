import 'package:country_picker/country_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:clinic/core/theme/theme.dart';
import 'package:clinic/presentation/auth/widgets/google_signin_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClinicOnboardingScreen extends StatefulWidget {
  const ClinicOnboardingScreen({super.key});

  @override
  State<ClinicOnboardingScreen> createState() => _ClinicOnboardingScreenState();
}

class _ClinicOnboardingScreenState extends State<ClinicOnboardingScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final clinicNameController = TextEditingController();
  final clinicEmailController = TextEditingController();
  final clinicPhoneController = TextEditingController();
  final addressController = TextEditingController();
  final ownerNameController = TextEditingController();
  
  Country? selectedCountry;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _userEmail;
  String? _userName;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _initializeAuthListener();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    clinicNameController.dispose();
    clinicEmailController.dispose();
    clinicPhoneController.dispose();
    addressController.dispose();
    ownerNameController.dispose();
    super.dispose();
  }

  void _checkAuthStatus() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        _isAuthenticated = true;
        _userEmail = user.email;
        _userName = user.userMetadata?['full_name'] ?? user.email;
        ownerNameController.text = _userName ?? '';
        clinicEmailController.text = _userEmail ?? '';
      });
    }
  }

  void _initializeAuthListener() {
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null && !_isAuthenticated) {
        setState(() {
          _isAuthenticated = true;
          _userEmail = session.user.email;
          _userName = session.user.userMetadata?['full_name'] ?? session.user.email;
          ownerNameController.text = _userName ?? '';
          clinicEmailController.text = _userEmail ?? '';
        });
      }
    });
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String currentUrl;
      if (kIsWeb) {
        currentUrl = Uri.base.toString().split('?').first;
      } else {
        currentUrl = 'com.neurotrack.clinic://login-callback';
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

  Future<void> _submitOnboarding() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isAuthenticated || _userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in with Google first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if clinic with this email already exists
      final existingClinic = await supabase
          .from('clinic')
          .select('id, is_active')
          .eq('email', clinicEmailController.text.trim())
          .maybeSingle();

      if (existingClinic != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(existingClinic['is_active'] == true
                  ? 'A clinic with this email is already registered and active.'
                  : 'A clinic with this email is already registered and pending approval.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Create clinic record with is_active = false (pending approval)
      final clinicData = {
        'name': clinicNameController.text.trim(),
        'email': clinicEmailController.text.trim(),
        'phone': clinicPhoneController.text.trim(),
        'address': addressController.text.trim().isEmpty 
            ? null 
            : addressController.text.trim(),
        'country': selectedCountry?.name ?? null,
        'owner_name': ownerNameController.text.trim(),
        'owner_email': _userEmail,
        'is_active': false, // Pending admin approval
      };

      final { error } = await supabase
          .from('clinic')
          .insert(clinicData);

      if (error != null) {
        throw Exception(error.message);
      }

      if (mounted) {
        // Show success message
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Onboarding Submitted'),
            content: const Text(
              'Your clinic onboarding request has been submitted successfully. '
              'You will receive access once your request is approved by the administrator. '
              'You will be notified via email when your clinic is activated.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  supabase.auth.signOut();
                  Navigator.of(context).pop(); // Go back to login
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit onboarding: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
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
      appBar: AppBar(
        title: const Text('Clinic Onboarding'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.local_hospital,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Register Your Clinic',
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Fill in your clinic details to request access',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Google Sign In Section (if not authenticated)
                if (!_isAuthenticated) ...[
                  const Text(
                    'Step 1: Sign in with Google',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GoogleSignInButton(
                    onPressed: _handleGoogleSignIn,
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 32),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Signed in as',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                _userEmail ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Onboarding Form
                if (_isAuthenticated) ...[
                  const Text(
                    'Step 2: Clinic Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Clinic Name
                  TextFormField(
                    controller: clinicNameController,
                    decoration: const InputDecoration(
                      labelText: 'Clinic Name *',
                      hintText: 'Enter your clinic name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter clinic name';
                      }
                      if (value.trim().length < 3) {
                        return 'Clinic name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Clinic Email
                  TextFormField(
                    controller: clinicEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Clinic Email *',
                      hintText: 'clinic@example.com',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    enabled: false, // Pre-filled from Google account
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Clinic Phone
                  TextFormField(
                    controller: clinicPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Clinic Phone *',
                      hintText: '+1234567890',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter clinic phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Address
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      hintText: 'Enter clinic address (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Country
                  InkWell(
                    onTap: () {
                      showCountryPicker(
                        context: context,
                        onSelect: (Country country) {
                          setState(() {
                            selectedCountry = country;
                          });
                        },
                      );
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Country',
                        hintText: 'Select country (optional)',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      child: Text(
                        selectedCountry?.displayName ?? 'Select country (optional)',
                        style: TextStyle(
                          color: selectedCountry == null
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Owner Name
                  TextFormField(
                    controller: ownerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Owner/Administrator Name *',
                      hintText: 'Enter owner name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter owner name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitOnboarding,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Submit Onboarding Request',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '* Required fields\n\nYour request will be reviewed by an administrator. '
                    'You will receive an email notification once your clinic is activated.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
