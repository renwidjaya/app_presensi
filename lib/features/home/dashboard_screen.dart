import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_presensi/widgets/bottom_nav.dart';
import 'package:app_presensi/services/local_storage_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? userName;
  String? token;
  bool isAdmin = false;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await LocalStorageService.getUserData();
    final storedToken = await LocalStorageService.getToken();

    if (userData != null) {
      setState(() {
        userName = userData['nama'];
        token = storedToken;
        isAdmin = userData['role'] == 'admin';
        loaded = true;
      });

      print('✅ User: $userData');
      print('✅ Token: $storedToken');
    } else {
      setState(() => loaded = true);
    }
  }

  void _logout(BuildContext context) async {
    await LocalStorageService.clear();
    if (!context.mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    // sementara loading userData, tampilkan placeholder
    if (!loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // build list kartu dashboard
    final cards = <Widget>[
      _DashboardCard(
        title: 'Absensi',
        icon: Icons.check_circle,
        color: Colors.blue,
        onTap: () => context.go('/absensi'),
      ),
      _DashboardCard(
        title: 'Riwayat',
        icon: Icons.history,
        color: Colors.orange,
        onTap: () => context.go('/riwayat'),
      ),
      _DashboardCard(
        title: 'Statistik',
        icon: Icons.bar_chart,
        color: Colors.green,
        onTap: () => context.go('/statistik'),
      ),
    ];

    if (isAdmin) {
      cards.add(
        _DashboardCard(
          title: 'Report',
          icon: Icons.pie_chart,
          color: Colors.purple,
          onTap: () => context.go('/report'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Hello ${userName ?? ''}')),
      bottomNavigationBar: BottomNav(currentIndex: 0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: cards,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
