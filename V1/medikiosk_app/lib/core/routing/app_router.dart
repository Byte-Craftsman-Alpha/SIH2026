import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/splash/presentation/splash_screen.dart';
import '../../features/language/presentation/language_screen.dart';
import '../../features/kiosk/presentation/kiosk_welcome_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/registration/registration_wizard.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/prakriti/presentation/prakriti_intro_screen.dart';
import '../../features/prakriti/presentation/prakriti_question_screen.dart';
import '../../features/prakriti/presentation/prakriti_result_screen.dart';
import '../../features/prakriti/presentation/prakriti_delta_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/emergency/presentation/emergency_screen.dart';
import '../../features/documents/presentation/history_screen.dart';
import '../../features/documents/presentation/document_upload_screen.dart';
import '../../features/documents/presentation/parsing_progress_screen.dart';
import '../../features/documents/presentation/document_review_screen.dart';
import '../../features/documents/presentation/document_detail_screen.dart';
import '../../features/appointments/presentation/hospitals_screen.dart';
import '../../features/appointments/presentation/doctor_slots_screen.dart';
import '../../features/appointments/presentation/booking_wizard.dart';
import '../../features/appointments/presentation/booking_confirmation_screen.dart';
import '../../features/appointments/presentation/appointments_list_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';

CustomTransitionPage<void> _buildSmoothPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _buildSmoothPage(
          context: context,
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/language',
        pageBuilder: (context, state) => _buildSmoothPage(
          context: context,
          state: state,
          child: const LanguageScreen(),
        ),
      ),
      GoRoute(
        path: '/kiosk',
        pageBuilder: (context, state) => _buildSmoothPage(
          context: context,
          state: state,
          child: const KioskWelcomeScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _buildSmoothPage(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/otp',
        pageBuilder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '+91 98765-43210';
          final abhaTxnId = state.uri.queryParameters['abhaTxnId'];
          return _buildSmoothPage(
            context: context,
            state: state,
            child: OtpScreen(phone: phone, abhaTxnId: abhaTxnId),
          );
        },
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => _buildSmoothPage(
          context: context,
          state: state,
          child: const RegistrationWizard(),
        ),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => _buildSmoothPage(
          context: context,
          state: state,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/prakriti',
        pageBuilder: (context, state) => _buildSmoothPage(
          context: context,
          state: state,
          child: const PrakritiIntroScreen(),
        ),
        routes: [
          GoRoute(
            path: 'question',
            pageBuilder: (context, state) => _buildSmoothPage(
              context: context,
              state: state,
              child: const PrakritiQuestionScreen(),
            ),
          ),
          GoRoute(
            path: 'questions',
            pageBuilder: (context, state) => _buildSmoothPage(
              context: context,
              state: state,
              child: const PrakritiQuestionScreen(),
            ),
          ),
          GoRoute(
            path: 'result',
            pageBuilder: (context, state) => _buildSmoothPage(
              context: context,
              state: state,
              child: const PrakritiResultScreen(),
            ),
          ),
          GoRoute(
            path: 'delta',
            pageBuilder: (context, state) => _buildSmoothPage(
              context: context,
              state: state,
              child: const PrakritiDeltaScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/chat',
        pageBuilder: (context, state) {
          final mode = state.uri.queryParameters['mode'] ?? 'ayush';
          return _buildSmoothPage(
            context: context,
            state: state,
            child: ChatScreen(mode: mode),
          );
        },
      ),
      GoRoute(
        path: '/emergency',
        pageBuilder: (context, state) => _buildSmoothPage(
          context: context,
          state: state,
          child: const EmergencyScreen(),
        ),
      ),
      GoRoute(
        path: '/documents',
        pageBuilder: (context, state) => _buildSmoothPage(
          context: context,
          state: state,
          child: const HistoryScreen(),
        ),
        routes: [
          GoRoute(
            path: 'upload',
            pageBuilder: (context, state) => _buildSmoothPage(
              context: context,
              state: state,
              child: const DocumentUploadScreen(),
            ),
          ),
          GoRoute(
            path: 'parsing',
            pageBuilder: (context, state) => _buildSmoothPage(
              context: context,
              state: state,
              child: const ParsingProgressScreen(),
            ),
          ),
          GoRoute(
            path: 'review',
            pageBuilder: (context, state) => _buildSmoothPage(
              context: context,
              state: state,
              child: const DocumentReviewScreen(),
            ),
          ),
          GoRoute(
            path: 'detail',
            pageBuilder: (context, state) => _buildSmoothPage(
              context: context,
              state: state,
              child: const DocumentDetailScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/hospitals',
        pageBuilder: (context, state) => _buildSmoothPage(
          context: context,
          state: state,
          child: const HospitalsScreen(),
        ),
      ),
      GoRoute(
        path: '/doctors/slots',
        pageBuilder: (context, state) => _buildSmoothPage(
          context: context,
          state: state,
          child: const DoctorSlotsScreen(),
        ),
      ),
      GoRoute(
        path: '/doctors',
        pageBuilder: (context, state) => _buildSmoothPage(
          context: context,
          state: state,
          child: const DoctorSlotsScreen(),
        ),
      ),
      GoRoute(
        path: '/booking',
        pageBuilder: (context, state) {
          final hosp = state.uri.queryParameters['hospitalId'];
          final doc = state.uri.queryParameters['doctorId'];
          final slot = state.uri.queryParameters['slot'];
          return _buildSmoothPage(
            context: context,
            state: state,
            child: BookingWizard(
              hospitalId: hosp,
              doctorId: doc,
              slot: slot,
            ),
          );
        },
        routes: [
          GoRoute(
            path: 'confirm',
            pageBuilder: (context, state) {
              final token = state.uri.queryParameters['token'] ?? 'A-007';
              final doctor = state.uri.queryParameters['doctor'] ?? 'Dr. Rajesh Sharma';
              final hospital = state.uri.queryParameters['hospital'] ?? 'All India Institute of Ayurveda (AIIA)';
              final slot = state.uri.queryParameters['slot'] ?? 'Today, 11:00 AM - 11:15 AM';
              return _buildSmoothPage(
                context: context,
                state: state,
                child: BookingConfirmationScreen(
                  tokenNo: token,
                  doctorName: doctor,
                  hospitalName: hospital,
                  slotTime: slot,
                ),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/appointments',
        pageBuilder: (context, state) => _buildSmoothPage(
          context: context,
          state: state,
          child: const AppointmentsListScreen(),
        ),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => _buildSmoothPage(
          context: context,
          state: state,
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => _buildSmoothPage(
          context: context,
          state: state,
          child: const NotificationsScreen(),
        ),
      ),
    ],
  );
});
