import 'package:go_router/go_router.dart';
import '../../features/auth/login_screen.dart';
import '../../features/home/dashboard_screen.dart';
import '../../features/home/absensi_screen.dart';
import '../../features/home/riwayat_screen.dart';
import '../../features/home/statistik_screen.dart';
import '../../features/home/report_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppRouter {
  static final _storage = const FlutterSecureStorage();

  static final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final token = await _storage.read(key: 'token');

      final isLoggingIn = state.matchedLocation == '/';
      if (token != null && isLoggingIn) {
        return '/dashboard'; // Sudah login, redirect ke dashboard
      } else if (token == null && !isLoggingIn) {
        return '/'; // Belum login, redirect ke login
      }
      return null; // Lanjutkan seperti biasa
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/absensi',
        builder: (context, state) => const AbsensiScreen(),
      ),
      GoRoute(
        path: '/riwayat',
        builder: (context, state) => const RiwayatScreen(),
      ),
      GoRoute(
        path: '/statistik',
        builder: (context, state) => const StatistikScreen(),
      ),
      GoRoute(
        path: '/report',
        builder: (context, state) => const ReportScreen(),
      ),
    ],
  );
}
