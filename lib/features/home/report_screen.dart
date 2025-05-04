import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/bottom_nav.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Laporan Absensi')),
      bottomNavigationBar: const BottomNav(currentIndex: 3),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Nama Pegawai'),
              subtitle: const Text('NIK12345678'),
              trailing: const Icon(Icons.info_outline),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text('Total Hari Hadir'),
                trailing: Text(
                  '20 Hari',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Total Hari Izin'),
                trailing: Text(
                  '2 Hari',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Total Hari Alpha'),
                trailing: Text(
                  '1 Hari',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download),
              label: const Text('Download Laporan'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
