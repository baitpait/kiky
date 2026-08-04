import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/admin/screens/admin_shell.dart';
import '../../features/teacher/screens/teacher_shell.dart';
import '../../features/parent/screens/parent_shell.dart';

class AppRouter {
  AppRouter(this.auth);

  final AuthProvider auth;

  late final GoRouter router = GoRouter(
    refreshListenable: auth,
    initialLocation: '/login',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (loc == '/') return '/login';

      if (!auth.isInitialized) {
        return loc == '/login' ? null : '/login';
      }

      final loggingIn = state.matchedLocation == '/login';
      final loggedIn = auth.isAuthenticated;

      if (!loggedIn) return loggingIn ? null : '/login';

      if (loggingIn) {
        return _homeForRole(auth.user!.role);
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/login',
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (_, __) => const AdminShell(),
      ),
      GoRoute(
        path: '/teacher',
        builder: (_, __) => const TeacherShell(),
      ),
      GoRoute(
        path: '/parent',
        builder: (_, __) => const ParentShell(),
      ),
    ],
    errorBuilder: (context, state) => Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Center(
          child: Text('خطأ: ${state.error}'),
        ),
      ),
    ),
  );

  String _homeForRole(String role) {
    switch (role) {
      case 'admin':
        return '/admin';
      case 'teacher':
        return '/teacher';
      case 'parent':
        return '/parent';
      default:
        return '/login';
    }
  }
}
