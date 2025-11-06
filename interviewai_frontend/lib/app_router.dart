// lib/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:interviewai_frontend/providers/auth_provider.dart';
import 'package:interviewai_frontend/screens/auth/sign_in_screen.dart';
import 'package:interviewai_frontend/screens/dashboard/dashboard_screen.dart';
import 'package:interviewai_frontend/screens/interview/interview_screen.dart';
import 'package:interviewai_frontend/screens/feedback/feedback_screen.dart';
import 'package:interviewai_frontend/screens/resume/upload_resume_screen.dart';
import 'package:interviewai_frontend/screens/resume/analysis_result_screen.dart';
import 'package:interviewai_frontend/screens/resume_builder/resume_form_screen.dart';
import 'package:interviewai_frontend/screens/resume_builder/resume_display_screen_enhanced.dart';
import 'package:interviewai_frontend/screens/resume_builder/resume_list_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  // Watch the auth state to trigger router rebuilds when auth changes
  ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      // --- Interview route ---
      GoRoute(
        path: '/interview',
        builder: (context, state) {
          // Get the parameters from the 'extra' object
          final params = state.extra as Map<String, String>;
          final interviewId = params['interviewId']!;
          final questionsJson = params['questionsJson']!;

          return InterviewScreen(
            interviewId: interviewId,
            questionsJson: questionsJson,
          );
        },
      ),
      // --- Feedback route with smooth fade transition ---
      GoRoute(
        path: '/feedback/:id',
        pageBuilder: (context, state) {
          final feedbackId = state.pathParameters['id']!;
          final Map<String, dynamic>? initialData =
              state.extra as Map<String, dynamic>?;

          return CustomTransitionPage(
            key: state.pageKey,
            child: FeedbackScreen(
              feedbackId: feedbackId,
              initialData: initialData,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: CurveTween(
                      curve: Curves.easeIn,
                    ).animate(animation),
                    child: child,
                  );
                },
            transitionDuration: const Duration(milliseconds: 300),
          );
        },
      ),
      // --- Resume upload route ---
      GoRoute(
        path: '/upload-resume',
        builder: (context, state) => const UploadResumeScreen(),
      ),
      // --- Resume analysis result route ---
      GoRoute(
        path: '/resume-analysis/:id',
        builder: (context, state) {
          final resumeId = state.pathParameters['id']!;
          return AnalysisResultScreen(resumeId: resumeId);
        },
      ),
      // --- Resume Builder routes ---
      GoRoute(
        path: '/resume-builder',
        builder: (context, state) => const ResumeFormScreen(),
      ),
      GoRoute(
        path: '/resume-builder/view/:id',
        builder: (context, state) {
          final resumeId = state.pathParameters['id']!;
          return ResumeDisplayScreenEnhanced(resumeId: resumeId);
        },
      ),
      GoRoute(
        path: '/resume-builder/list',
        builder: (context, state) => const ResumeListScreen(),
      ),
    ],
    redirect: (context, state) {
      // Get the current logged-in user directly from Supabase
      final currentUser = Supabase.instance.client.auth.currentUser;

      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToDashboard = state.matchedLocation == '/dashboard';

      debugPrint(
        '?? GoRouter Redirect - User: ${currentUser?.email}, To: ${state.matchedLocation}',
      );

      if (currentUser == null) {
        // User is not logged in
        if (isGoingToLogin) {
          // User is trying to access login, allow it
          return null;
        } else {
          // User is trying to access protected route, redirect to login
          return '/login';
        }
      } else {
        // User is logged in
        if (isGoingToLogin) {
          // User is logged in and trying to access login, redirect to dashboard
          debugPrint('? User is logged in, redirecting to dashboard');
          return '/dashboard';
        } else if (isGoingToDashboard) {
          // User is logged in and accessing dashboard, allow it
          return null;
        } else {
          // User is logged in and accessing other routes, allow them
          return null;
        }
      }
    },
  );
}
