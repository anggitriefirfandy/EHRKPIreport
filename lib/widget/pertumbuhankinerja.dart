import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ehr_report/api/api.dart';

class Pertumbuhankinerja extends StatefulWidget {
  final String pegawaiId;

  const Pertumbuhankinerja({Key? key, required this.pegawaiId}) : super(key: key);

  @override
  State<Pertumbuhankinerja> createState() => _PertumbuhankinerjaState();
}

class _PertumbuhankinerjaState extends State<Pertumbuhankinerja> {
  List<Map<String, dynamic>> kpiData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPertumbuhanKinerja();
  }

  Future<void> fetchPertumbuhanKinerja() async {
    String apiUrl = '/pertumbuhankinerjabar/${widget.pegawaiId}';

    try {
      var response = await ApiHandler().getData(apiUrl);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('data')) {
          var dataList = jsonResponse['data'];

          setState(() {
            kpiData = (dataList as List)
                .map((item) => {
                      'kpi_date': item['kpi_date'],
                      'nilai_akhir': double.parse(item['nilai_akhir'].toString()).round()
                    })
                .toList()
                .reversed
                .toList();
          });
        }
      }
    } catch (e) {
      // Jika terjadi error, tidak perlu melakukan sesuatu, cukup lanjut ke langkah berikutnya.
    }

    if (kpiData.isEmpty) {
      // Tambahkan data dummy jika tidak ada data
      DateTime now = DateTime.now();
      kpiData = [
        {
          'kpi_date': now.toIso8601String(),
          'nilai_akhir': 0,
        }
      ];
    }

    setState(() {
      isLoading = false;
    });
  }

  String _getMonthAbbreviation(int month) {
    const List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: AspectRatio(
              aspectRatio: 1.5,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 100,
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false, reservedSize: 50)),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 25,
                        interval: 50,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value == 50 || value == 100) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 12),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < kpiData.length) {
                            String kpiDate = kpiData[value.toInt()]['kpi_date'];
                            DateTime date = DateTime.parse(kpiDate);
                            String month = _getMonthAbbreviation(date.month);
                            String year = date.year.toString().substring(2);

                            return Text(
                              "$month/$year",
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                        interval: 1,
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      right: BorderSide(color: Colors.black, width: 1),
                      left: BorderSide(color: Colors.black, width: 1),
                      bottom: BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: true,
                    horizontalInterval: 50,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: kpiData.asMap().entries.map((entry) {
                        final index = entry.key.toDouble();
                        final data = entry.value['nilai_akhir'].toDouble();
                        return FlSpot(index, data);
                      }).toList(),
                      isCurved: true,
                      color: Colors.deepOrange,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: Colors.orange,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
