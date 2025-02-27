import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kpi/api/api.dart';

class Widgetkpi extends StatefulWidget {
  final String pegawaiId;
  const Widgetkpi({Key? key, required this.pegawaiId}) : super(key: key);

  @override
  State<Widgetkpi> createState() => _WidgetkpiState();
}

class _WidgetkpiState extends State<Widgetkpi> {
  List<Map<String, dynamic>> kpiData2 = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchWidgetkpi();
  }
  Future<void> fetchWidgetkpi() async {
  debugPrint('fetchWidgetkpi() dipanggil dengan pegawaiId: ${widget.pegawaiId}');
  String apiUrl = '/widgetkpireport/${widget.pegawaiId}';

  try {
    var response = await ApiHandler().getData(apiUrl);
    debugPrint('Response widgetkpi dari API: ${response.body}');

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      debugPrint('API Response widget kpi Status Code: ${response.statusCode}');

      if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('data')) {
        var data = jsonResponse['data'];
        debugPrint('Data yang diterima: $data');

        if (data.containsKey('kpiringkas') && data['kpiringkas'] is Map<String, dynamic>) {
          var kpiringkas = data['kpiringkas'] as Map<String, dynamic>;

          if (kpiringkas.containsKey('radd') && kpiringkas['radd'] is Map<String, dynamic>) {
            var radd = kpiringkas['radd'] as Map<String, dynamic>;

            // Ambil bulan & tahun sesuai format API (Kapitalisasi Awal)
            String currentMonthYear = DateFormat('MMM-yy', 'en_US').format(DateTime.now());
            debugPrint('Bulan dan tahun sekarang: $currentMonthYear');
            debugPrint('Keys dalam radd: ${radd.keys.toList()}');

            // Cari key tanpa case-sensitive
            String? matchingKey = radd.keys.cast<String?>().firstWhere(
              (key) => key != null && key.toLowerCase() == currentMonthYear.toLowerCase(),
              orElse: () => null, // Ganti string kosong dengan `null`
            );


            if (matchingKey != null && radd.containsKey(matchingKey)) {
              var selectedData = radd[matchingKey];
              debugPrint('Data radd untuk bulan ini: $selectedData');

              if (mounted) { // Cek apakah widget masih ada sebelum setState()
                setState(() {
                  kpiData2 = [{'bulan': matchingKey, 'data': selectedData}];
                  isLoading = false;
                });
              }
            } else {
              debugPrint('Data untuk bulan ini tidak ditemukan.');
              if (mounted) {
                setState(() {
                  kpiData2 = [];
                  isLoading = false;
                });
              }
            }


          } else {
            debugPrint('Key "radd" tidak ditemukan atau bukan Map.');
          }
        } else {
          debugPrint('Key "kpiringkas" tidak ditemukan atau bukan Map.');
        }
      } else {
        debugPrint('Response tidak memiliki key "data".');
      }
    } else {
      debugPrint('Request gagal dengan status code: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Terjadi error saat fetch data: $e');
  }
}
double _parseDouble(dynamic value) {
  if (value == null) return 0.0; // Jika null, kembalikan 0.0
  if (value is double) return value; // Jika sudah double, langsung kembalikan
  if (value is int) return value.toDouble(); // Jika integer, ubah ke double
  if (value is String) {
    // Hapus karakter yang tidak perlu (misal: koma, spasi)
    String cleanedValue = value.replaceAll(',', '').trim();

    return double.tryParse(cleanedValue) ?? 0.0;
  }
  return 0.0; // Jika tipe data tidak dikenal, kembalikan 0.0
}


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      color: Colors.white,
       child:Padding(
        padding: EdgeInsets.only(top: 10, left: 10),
         child: Column(
               children: [_buildKPIIndicators(),],
             ),
       ),);
  }
Widget _buildKPIIndicators() {
  if (kpiData2.isEmpty) {
    // Jika data kosong, tampilkan 6 indikator statis
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(6, (index) => Padding(
          padding: EdgeInsets.only(right: 16),
          child: _buildCircularIndicator("Data masih kosong", 0),
        )),
      ),
    );
  }

  var kpiValues = kpiData2.first['data']; // Ambil data KPI dari API

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: kpiValues.entries.map<Widget>((entry) { // Tambahkan <Widget> agar hasilnya sesuai tipe
        String label = entry.key; // Ambil nama label dari API
        double value = _parseDouble(entry.value); // Ambil nilai KPI
        return Padding(
          padding: EdgeInsets.only(right: 16),
          child: _buildCircularIndicator(label, value),
        );
      }).toList(), // Pastikan hasilnya dikonversi menjadi List<Widget>
    ),
  );
}


Widget _buildCircularIndicator(String title, double value) {
  double percentage = min(100, value); // Pastikan maksimal 100
  String displayValue = percentage.toStringAsFixed(0); // Hilangkan koma panjang

  return Padding(
    padding: EdgeInsets.only(top: 10, left: 10, bottom: 10, right: 20),
    child: Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: CircularProgressIndicator(
                value: percentage / 100, // Ubah ke skala 0–1
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007BFF)),
                strokeWidth: 5,
              ),
            ),
            Text("$displayValue%", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    ),
  );
}

// @override
// Widget build(BuildContext context) {
//   try {
//     return Column(
//       children: [
//         isLoading
//             ? CircularProgressIndicator()
//             : kpiData2.isEmpty
//                 ? Text("Tidak ada data untuk bulan ini")
//                 : Expanded(
//                     child: ListView.builder(
//                       itemCount: kpiData2.length,
//                       itemBuilder: (context, index) {
//                         var item = kpiData2[index];
//                         return ListTile(
//                           title: Text('Data untuk ${item['bulan']}'),
//                           subtitle: Text(item['data'].toString()),
//                         );
//                       },
//                     ),
//                   ),
//       ],
//     );
//   } catch (e, stackTrace) {
//     debugPrint('Error di build: $e');
//     debugPrint(stackTrace.toString());
//     return Center(child: Text("Terjadi kesalahan"));
//   }
// }


}