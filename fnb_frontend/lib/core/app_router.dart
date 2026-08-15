
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

import '../pages/login_page.dart';
import '../pages/admin_dashboard_page.dart';
import '../pages/pos_dashboard_page.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isLoggedIn = authProvider.isLoggedIn;
      final role = authProvider.role;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn) {
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn) {
        if (role == 'admin') return '/admin';
        if (role == 'kasir') return '/pos';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: '/pos',
        builder: (context, state) => const PosDashboardPage(),
      ),
    ],
  );
}
