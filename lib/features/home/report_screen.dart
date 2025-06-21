import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../constants/api_base.dart';
import '../../services/api_service.dart';
import '../../services/local_storage_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool isLoading = false;
  String periodText = '';
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  List<BarChartGroupData> barGroups = [];

  final monthNames = <int, String>{
    1: 'Januari',
    2: 'Februari',
    3: 'Maret',
    4: 'April',
    5: 'Mei',
    6: 'Juni',
    7: 'Juli',
    8: 'Agustus',
    9: 'September',
    10: 'Oktober',
    11: 'November',
    12: 'Desember',
  };

  @override
  void initState() {
    super.initState();
    // Inisialisasi locale 'id_ID' sebelum pakai DateFormat
    initializeDateFormatting('id_ID', null).then((_) {
      _updatePeriodText();
      _loadReport();
    });
  }

  void _updatePeriodText() {
    final first = DateTime(selectedYear, selectedMonth, 1);
    final last = DateTime(selectedYear, selectedMonth + 1, 0);
    final fmt = DateFormat('dd MMMM yyyy', 'id_ID');
    setState(() {
      periodText = '${fmt.format(first)} – ${fmt.format(last)}';
    });
  }

  Future<void> _loadReport() async {
    setState(() => isLoading = true);

    final token = await LocalStorageService.getToken();
    if (token == null) {
      setState(() => isLoading = false);
      return;
    }

    final tahunbulan =
        '$selectedYear-${selectedMonth.toString().padLeft(2, '0')}';
    final url = '${ApiBase.reportAll}?tahunbulan=$tahunbulan';

    try {
      final resp = await ApiService.get(url, token: token);
      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body);
        final chart =
            (json['data']['chart'] as List)
                .map((e) => {'label': e['label'], 'count': e['count']})
                .toList();

        // Build barGroups untuk BarChart
        barGroups = List.generate(chart.length, (i) {
          final cnt = (chart[i]['count'] as num).toDouble();
          return BarChartGroupData(
            x: i,
            barRods: [BarChartRodData(toY: cnt, width: 16)],
          );
        });
      } else {
        debugPrint('Gagal load report: ${resp.statusCode}');
      }
    } catch (e) {
      debugPrint('Error load report: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickMonthYear() async {
    int tempMonth = selectedMonth;
    int tempYear = selectedYear;

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Pilih Bulan & Tahun'),
            content: Row(
              children: [
                Expanded(
                  child: StatefulBuilder(
                    builder:
                        (ctx, setStateDlg) => DropdownButton<int>(
                          isExpanded: true,
                          value: tempMonth,
                          items:
                              monthNames.entries
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e.key,
                                      child: Text(e.value),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (m) {
                            if (m != null) setStateDlg(() => tempMonth = m);
                          },
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatefulBuilder(
                    builder:
                        (ctx, setStateDlg) => DropdownButton<int>(
                          isExpanded: true,
                          value: tempYear,
                          items:
                              List.generate(5, (i) => DateTime.now().year - i)
                                  .map(
                                    (y) => DropdownMenuItem(
                                      value: y,
                                      child: Text('$y'),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (y) {
                            if (y != null) setStateDlg(() => tempYear = y);
                          },
                        ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  selectedMonth = tempMonth;
                  selectedYear = tempYear;
                  _updatePeriodText();
                  _loadReport();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _downloadReport() async {
    setState(() => isLoading = true);

    final token = await LocalStorageService.getToken();
    if (token == null) {
      setState(() => isLoading = false);
      return;
    }

    final tahunbulan =
        '$selectedYear-${selectedMonth.toString().padLeft(2, '0')}';
    final endpoint = '${ApiBase.export}?tahunbulan=$tahunbulan';

    try {
      final resp = await ApiService.get(endpoint, token: token);
      if (resp.statusCode == 200) {
        final bytes = resp.bodyBytes;
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/Laporan-$tahunbulan.xlsx');
        await file.writeAsBytes(bytes);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Tersimpan: ${file.path}')));
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
    final labels = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Periode + Filter
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickMonthYear,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Periode',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(periodText),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _loadReport,
                  child: const Text('Filter'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Chart
            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (barGroups.isEmpty)
              const Expanded(child: Center(child: Text('Data belum tersedia')))
            else
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kehadiran Bulanan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: BarChart(
                            BarChartData(
                              // Paksa skala mulai dari 0
                              minY: 0,
                              // maxY = nilai tertinggi + 1
                              maxY:
                                  barGroups
                                      .map((g) => g.barRods.first.toY)
                                      .fold(0.0, (a, b) => a > b ? a : b) +
                                  1,
                              groupsSpace: 12,
                              barGroups: barGroups,

                              // Grid: hanya garis horizontal dengan interval 1
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 1,
                                getDrawingHorizontalLine:
                                    (value) => FlLine(
                                      color: Colors.grey.shade300,
                                      dashArray: [4, 4],
                                    ),
                              ),

                              // Judul axis
                              titlesData: FlTitlesData(
                                show: true,
                                // Bawah (labels Senin→Minggu)
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 32,
                                    getTitlesWidget: (value, meta) {
                                      final idx = value.toInt();
                                      if (idx < labels.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 6.0,
                                          ),
                                          child: Text(labels[idx]),
                                        );
                                      }
                                      return const SizedBox();
                                    },
                                  ),
                                ),
                                // Kiri (0,1,2,...)
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    reservedSize: 28,
                                  ),
                                ),
                                // Matikan kanan & atas
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),

                              // Hapus border kotak
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Download
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
    );
  }
}
