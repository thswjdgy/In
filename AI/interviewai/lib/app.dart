import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/interview/screens/onboarding_screen.dart';
import 'features/interview/screens/interview_screen.dart';
import 'features/feedback/screens/feedback_screen.dart';
import 'features/feedback/models/feedback_model.dart';
import 'features/history/screens/history_screen.dart';
import 'features/history/screens/session_detail_screen.dart';
import 'features/result/screens/result_screen.dart';
import 'shared/theme/app_theme.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/interview',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return InterviewScreen(
          job: extra['job'] as String,
          type: extra['type'] as String,
          count: extra['count'] as int,
        );
      },
    ),
    GoRoute(
      path: '/feedback',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return FeedbackScreen(
          feedback: extra['feedback'] as FeedbackModel,
          question: extra['question'] as String,
          answer: extra['answer'] as String,
          isLast: extra['isLast'] as bool,
          onNext: extra['onNext'] as VoidCallback?,
          onFinish: extra['onFinish'] as VoidCallback?,
        );
      },
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/session-detail',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return SessionDetailScreen(
          userId: extra['userId'] as String,
          sessionId: extra['sessionId'] as String,
          job: extra['job'] as String,
          score: extra['score'] as int,
        );
      },
    ),
    GoRoute(
      path: '/result',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return ResultScreen(
          job: extra['job'] as String,
          results: extra['results'] as List<Map<String, dynamic>>,
        );
      },
    ),
  ],
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'InterviewAI',
        theme: AppTheme.light,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      );
}
