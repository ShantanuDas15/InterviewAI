// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:interviewai_frontend/app_router.dart';
import 'package:interviewai_frontend/constants/api_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get Supabase credentials from ApiConstants
  const supabaseUrl = ApiConstants.supabaseUrl;
  const supabaseAnonKey = ApiConstants.supabaseAnonKey;

  // Validate credentials
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception('Missing Supabase credentials. Please check ApiConstants.');
  }

  // Initialize Supabase with proper auth settings for web
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      autoRefreshToken: true,
    ),
  );

  // Run the app inside a Riverpod scope
  runApp(const ProviderScope(child: MyApp()));
}

// Get a global Supabase client instance
final supabase = Supabase.instance.client;

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 4. Use the GoRouter config
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'InterviewAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      routerConfig: router,
    );
  }
}
