import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/bottom_nav.dart';

class StatistikScreen extends StatelessWidget {
  const StatistikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Statistik Absensi')),
      bottomNavigationBar: const BottomNav(currentIndex: 2),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Grafik Statistik Belum Tersedia',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Icon(Icons.bar_chart, size: 100, color: Colors.grey.shade400),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () {}, child: const Text('Muat Data')),
            ],
          ),
        ),
      ),
    );
  }
}
