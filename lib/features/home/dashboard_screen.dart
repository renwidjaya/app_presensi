import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/bottom_nav.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
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
            _DashboardCard(
              title: 'Report',
              icon: Icons.pie_chart,
              color: Colors.purple,
              onTap: () => context.go('/report'),
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
  final VoidCallback onTap; // Tambahkan ini

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap, // Tambahkan ini juga
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // Tambahkan aksi di sini
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
