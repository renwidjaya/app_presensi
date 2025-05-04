import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_face_api/flutter_face_api.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../widgets/bottom_nav.dart';

class AbsensiScreen extends StatefulWidget {
  const AbsensiScreen({super.key});

  @override
  State<AbsensiScreen> createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen> {
  Timer? _timer;
  String _timeString = '';
  bool _isCheckedIn = false;

  @override
  void initState() {
    super.initState();
    initFaceSDK();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  Future<void> initFaceSDK() async {
    try {
      await FaceSDK.instance.initialize();
    } catch (e) {
      print("Error initializing FaceSDK: $e");
    }
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _timeString =
          "${now.hour.toString().padLeft(2, '0')}:"
          "${now.minute.toString().padLeft(2, '0')}:"
          "${now.second.toString().padLeft(2, '0')}";
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleAbsensi() async {
    // Step 1: Minta permission kamera
    final cameraGranted = await Permission.camera.request();
    if (!cameraGranted.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izin kamera diperlukan untuk absensi')),
      );
      return;
    }

    try {
      // Step 2: Jalankan face capture
      final response = await FaceSDK.instance.startFaceCapture(
        config: FaceCaptureConfig(
          cameraPositionAndroid: 0, // 0 = Depan, 1 = Belakang
          cameraPositionIOS: CameraPosition.FRONT,
          cameraSwitchEnabled: true,
        ),
      );

      // Step 3: Debug log
      print("APPPPP response image: ${response.image?.image}");
      print("APPPPP response error: ${response.error?.message}");
      print("APPPPP response full: ${response.toJson()}");

      // Step 4: Cek hasil
      if (response.image?.image != null) {
        setState(() {
          _isCheckedIn = !_isCheckedIn;
        });

        final status = _isCheckedIn ? 'Check-In' : 'Check-Out';

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$status berhasil dengan verifikasi wajah!')),
        );

        // TODO: Simpan data wajah jika diperlukan
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verifikasi wajah dibatalkan atau gagal.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Absensi'),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _timeString,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Waktu Sekarang',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Lokasi dummy
            const Icon(Icons.location_on, color: Colors.red, size: 40),
            const Text(
              'Lokasi: Jl. Al Falah 2 Rt.02/08 No 10 E',
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _handleAbsensi,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isCheckedIn ? Colors.red : Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: Text(
                _isCheckedIn ? 'Check Out' : 'Check In',
                style: const TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 40),
            const Divider(height: 32),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Riwayat Hari Ini',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: Icon(
                  _isCheckedIn ? Icons.login : Icons.logout,
                  color: _isCheckedIn ? Colors.green : Colors.red,
                ),
                title: Text(_isCheckedIn ? 'Check In' : 'Check Out'),
                subtitle: Text('Pukul $_timeString'),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
