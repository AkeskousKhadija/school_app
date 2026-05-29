import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_app/features/auth/presentation/viewmodels/auth_notifier.dart';
import 'package:school_app/features/shared/domain/entities/user_role.dart';

// Placeholder pages - will be replaced with real dashboards
import 'package:school_app/features/auth/presentation/pages/login_page.dart';
import 'package:school_app/features/auth/presentation/pages/register_page.dart';
import 'package:school_app/features/admin/presentation/pages/admin_dashboard.dart';
import 'package:school_app/features/professor/presentation/pages/emploi_du_temps_page.dart';
import 'package:school_app/features/professor/presentation/pages/professor_dashboard.dart';
import 'package:school_app/features/student/presentation/pages/student_dashboard.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final userAsync = authState;
      final isLoggedIn = userAsync.valueOrNull != null;
      final currentRole = userAsync.valueOrNull?.role;

      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToRegister = state.matchedLocation == '/register';
      final isGoingToAdmin = state.matchedLocation.startsWith('/admin');
      final isGoingToProf = state.matchedLocation.startsWith('/prof');
      final isGoingToStudent = state.matchedLocation.startsWith('/student');

      if (!isLoggedIn) {
        return isGoingToLogin || isGoingToRegister ? null : '/login';
      }

      if (isGoingToLogin) {
        return _getDashboardForRole(currentRole);
      }

      // Role-based access control
      if (isGoingToAdmin && currentRole != UserRole.admin) {
        return _getDashboardForRole(currentRole);
      }
      if (isGoingToProf && currentRole != UserRole.professor) {
        return _getDashboardForRole(currentRole);
      }
      if (isGoingToStudent && currentRole != UserRole.student) {
        return _getDashboardForRole(currentRole);
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/prof/dashboard',
        builder: (context, state) => const ProfessorDashboard(),
      ),
      GoRoute(
        path: '/prof/emploi/create',
        builder: (context, state) => const EmploiDuTempsPage(),
      ),
      GoRoute(
        path: '/student/dashboard',
        builder: (context, state) => const StudentDashboard(),
      ),
    ],
  );
});

String _getDashboardForRole(UserRole? role) {
  switch (role) {
    case UserRole.admin:
      return '/admin/dashboard';
    case UserRole.professor:
      return '/prof/dashboard';
    case UserRole.student:
      return '/student/dashboard';
    default:
      return '/login';
  }
}
