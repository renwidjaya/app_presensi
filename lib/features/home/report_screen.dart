import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../../widgets/bottom_nav.dart';
import '../../services/api_service.dart';
import '../../constants/api_base.dart';
import '../../services/local_storage_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool isLoading = false;
  Map<String, dynamic>? statistikData;
  String namaPegawai = '';
  String nikPegawai = '';

  // Bulan & Tahun untuk filter & download
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  final List<String> months = [
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12',
  ];
  late final List<int> years = List.generate(5, (i) => DateTime.now().year - i);

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => isLoading = true);

    final user = await LocalStorageService.getUserData();
    final token = await LocalStorageService.getToken();
    if (user == null || token == null) {
      setState(() => isLoading = false);
      return;
    }

    namaPegawai = user['nama'] ?? '';
    nikPegawai = user['nik'] ?? '';

    final tahunbulan = '$selectedYear-${months[selectedMonth - 1]}';
    // GET atau POST? Statistik pakai POST
    final payload = {
      "id_karyawan": user['id_karyawan'],
      "tahunbulan": tahunbulan,
    };

    try {
      final resp = await ApiService.post(
        ApiBase.statistik,
        body: payload,
        token: token,
      );
      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body);
        statistikData = json['data'];
      } else {
        debugPrint('Gagal load statistik: ${resp.statusCode}');
      }
    } catch (e) {
      debugPrint('Error load statistik: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _downloadReport() async {
    setState(() => isLoading = true);

    final token = await LocalStorageService.getToken();
    final tahunbulan = '$selectedYear-${months[selectedMonth - 1]}';
    final endpoint = '${ApiBase.export}?tahunbulan=$tahunbulan';

    try {
      final resp = await ApiService.get(endpoint, token: token);
      if (resp.statusCode == 200) {
        final bytes = resp.bodyBytes;
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/Laporan-$tahunbulan.xlsx');
        await file.writeAsBytes(bytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Laporan tersimpan di ${file.path}')),
        );
        OpenFile.open(file.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal download: ${resp.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint('Error download: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saat download laporan')),
      );
    } finally {
      setState(() => isLoading = false);
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
        title: const Text('Laporan Absensi'),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 3),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Pemilihan Bulan & Tahun
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int>(
                  value: selectedMonth,
                  items:
                      List.generate(12, (i) => i + 1)
                          .map(
                            (m) => DropdownMenuItem(
                              value: m,
                              child: Text(months[m - 1]),
                            ),
                          )
                          .toList(),
                  onChanged: (m) {
                    if (m == null) return;
                    selectedMonth = m;
                    _loadReport();
                  },
                ),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: selectedYear,
                  items:
                      years
                          .map(
                            (y) =>
                                DropdownMenuItem(value: y, child: Text('$y')),
                          )
                          .toList(),
                  onChanged: (y) {
                    if (y == null) return;
                    selectedYear = y;
                    _loadReport();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (statistikData == null)
              const Center(child: Text('Data belum tersedia'))
            else
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info Pegawai
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(namaPegawai),
                      subtitle: Text(nikPegawai),
                    ),
                    const SizedBox(height: 12),

                    // Ringkasan
                    Card(
                      elevation: 2,
                      child: ListTile(
                        title: const Text('Total Hari Hadir'),
                        trailing: Text(
                          '${statistikData!['total_hadir']} Hari',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                    Card(
                      elevation: 2,
                      child: ListTile(
                        title: const Text('Total Hari Izin'),
                        trailing: Text(
                          '${statistikData!['per_kategori']['IZIN_KERJA']} Hari',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                    Card(
                      elevation: 2,
                      child: ListTile(
                        title: const Text('Total Hari Cuti'),
                        trailing: Text(
                          '${statistikData!['per_kategori']['CUTI_KERJA']} Hari',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                    Card(
                      elevation: 2,
                      child: ListTile(
                        title: const Text('Total Hari Dinas'),
                        trailing: Text(
                          '${statistikData!['per_kategori']['DINAS_KERJA']} Hari',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Tombol Download
                    ElevatedButton.icon(
                      onPressed: _downloadReport,
                      icon: const Icon(Icons.download),
                      label: const Text('Download Laporan'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
