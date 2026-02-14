import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:therapist/core/repository/auth/auth_repository.dart';
import 'package:therapist/core/repository/therapist/therapist_repository.dart';
import 'package:therapist/presentation/widgets/snackbar_service.dart';
import 'package:therapist/provider/consultation_provider.dart';
import 'package:therapist/provider/session_provider.dart'; // Add this import
import 'package:therapist/repository/supabase_auth_repository.dart';
import 'package:therapist/repository/supabase_consultation_repository.dart';
import 'package:therapist/repository/supabase_therapist_repository.dart';


import 'package:therapist/provider/therapy_provider.dart';
import 'package:therapist/repository/supabase_therapy_repository.dart';


import 'core/utils/dependency_injector.dart';
import 'presentation/splash_screen.dart';
import 'provider/auth_provider.dart';
import 'provider/daily_activities_provider.dart';
import 'provider/home_provider.dart';
import 'provider/therapist_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // For web, .env must be in web/ directory. For other platforms, use ../.env
  await dotenv.load(fileName: kIsWeb ? ".env" : "../.env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  Gemini.init(apiKey: dotenv.env['GEMINI_API_KEY']!);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  setupDependencyInjection();

  runApp(
    MultiProvider(
      providers: [
        Provider<SupabaseClient>(
          create: (context) => Supabase.instance.client,
        ),
        // Auth Repository and Provider
        Provider<AuthRepository>(
          create: (context) => SupabaseAuthRepository(
            supabaseClient: context.read<SupabaseClient>(),
          ),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            authRepository: context.read<AuthRepository>(),
            supabaseClient: context.read<SupabaseClient>(),
          ),
        ),
        // Therapist Repository and Provider
        Provider<TherapistRepository>(
          create: (context) => SupabaseTherapistRepository(
            supabaseClient: context.read<SupabaseClient>(),
          ),
        ),
        ChangeNotifierProvider<TherapistDataProvider>(
          create: (context) => TherapistDataProvider(
            therapistRepository: context.read<TherapistRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeProvider(
            therapistRepository: context.read<TherapistRepository>(),
          ),
        ),

        ChangeNotifierProvider(create: (context) => TherapistDataProvider(therapistRepository: context.read<TherapistRepository>())),
        ChangeNotifierProvider(create: (context) => ConsultationProvider(SupabaseConsultationRepository())),
        ChangeNotifierProvider(create: (context) => SessionProvider(
          therapistRepository: context.read<TherapistRepository>(),
        ),),
        ChangeNotifierProvider(create: (context) => TherapyProvider(therapyRepository: SupabaseTherapyRepository())),
        ChangeNotifierProvider(create: (context) => DailyActivitiesProvider(therapyRepository: SupabaseTherapyRepository())),
      ],
      child: const MyApp(),
    ),
  );

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
       scaffoldMessengerKey: SnackbarService.scaffoldMessengerKey,
      title: 'Therapist App',
      theme: ThemeData.light(),
      home: const SplashScreen(),
    );
  }
}
