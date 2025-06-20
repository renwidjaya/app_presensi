import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_presensi/services/local_storage_service.dart';

class BottomNav extends StatefulWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  bool isAdmin = false;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final user = await LocalStorageService.getUserData();
    if (user != null && user['role'] == 'ADMIN') {
      isAdmin = true;
    }
    setState(() => loaded = true);
  }

  void _onItemTapped(BuildContext context, int idx) {
    final routes = [
      '/dashboard',
      '/riwayat',
      '/statistik',
      if (isAdmin) '/report',
    ];
    if (idx < routes.length) {
      context.go(routes[idx]);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      // sembari loading, kita tampilkan placeholder
      return const SizedBox(height: 56);
    }

    // bangun daftar item
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(
        icon: Icon(Icons.access_time),
        label: 'Riwayat',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.bar_chart),
        label: 'Statistik',
      ),
      if (isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.pie_chart),
          label: 'Report',
        ),
    ];

    // jika currentIndex melebihi panjang items (misal non-admin di halaman report), reset ke 0
    final idx = widget.currentIndex < items.length ? widget.currentIndex : 0;

    return BottomNavigationBar(
      currentIndex: idx,
      onTap: (i) => _onItemTapped(context, i),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: items,
    );
  }
}
