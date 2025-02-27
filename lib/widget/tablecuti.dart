import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kpi/api/api.dart';

class Tablecuti extends StatefulWidget {
  final String pegawaiId;
  const Tablecuti({Key? key, required this.pegawaiId}) : super(key: key);

  @override
  State<Tablecuti> createState() => _TablecutiState();
}

class _TablecutiState extends State<Tablecuti> {
  bool isLoading = true;
  List<Map<String, dynamic>> dataCuti = [];

  @override
  void initState() {
    super.initState();
    fetchtabelcuti();
  }

  Future<void> fetchtabelcuti() async {
  debugPrint('fetchWidgetkpi() dipanggil dengan pegawaiId: ${widget.pegawaiId}');
  String apiUrl = '/detailcutireport/${widget.pegawaiId}';

  try {
    debugPrint('Mengirim request ke API: $apiUrl');

    var response = await ApiHandler().getData(apiUrl).timeout(
      Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException('Request timeout');
      },
    );

    debugPrint('API Response Status Code: ${response.statusCode}');
    debugPrint('API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('data_cuti')) {
        var dataList = jsonResponse['data_cuti'];

        if (dataList is List) {
          setState(() {
            dataCuti = List<Map<String, dynamic>>.from(dataList);
            isLoading = false;
          });

          debugPrint('Data Cuti: $dataCuti');
          return;
        }
      } else {
        debugPrint('Format response tidak sesuai yang diharapkan: $jsonResponse');
      }
    } else {
      debugPrint('Request gagal dengan status code: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Error saat fetch data cuti: $e');
  }

  setState(() {
    isLoading = false;
  });
}


  @override
Widget build(BuildContext context) {
  return Container(
    padding: EdgeInsets.all(8),
    child: isLoading
        ? Center(child: CircularProgressIndicator())
        : dataCuti.isEmpty
            ? Center(child: Text('Tidak ada data cuti'))
            : SizedBox(
                height: MediaQuery.of(context).size.height * 0.5, // Maksimal 50% dari tinggi layar
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical, // Scroll vertikal
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // Scroll horizontal
                    child: DataTable(
                      columnSpacing: 12,
                      headingRowColor:
                          MaterialStateColor.resolveWith((states) => Colors.blueGrey.shade800),
                      columns: const [
                        DataColumn(
                            label: Text('Jenis Cuti', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        DataColumn(
                            label: Text('Tanggal Mulai', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        DataColumn(
                            label: Text('Tanggal Selesai', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        DataColumn(
                            label: Text('Keterangan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                      ],
                      rows: dataCuti
                          .map(
                            (cuti) => DataRow(cells: [
                              DataCell(Text(cuti['nama_cuti'] ?? 'N/A')),
                              DataCell(Text(cuti['tgl_mulai']?.split(' ')[0] ?? 'N/A')),
                              DataCell(Text(cuti['tgl_selesai']?.split(' ')[0] ?? 'N/A')),
                              DataCell(Text(cuti['keterangan'] ?? 'N/A')),
                            ]),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
  );
}


}
