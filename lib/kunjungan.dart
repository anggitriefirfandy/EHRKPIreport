import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:kpi/api/api.dart';

class KunjunganScreen extends StatefulWidget {
  const KunjunganScreen({required this.prevPage, Key? key}) : super(key: key);
  final String prevPage;

  @override
  _KunjunganScreenState createState() => _KunjunganScreenState();
}

class KunjunganData {
  final String pegawaiId, profil, nama, nip, usia, jabatan, kantorCabang;
  final int funding, lending, collection, totalKunjungan;

  KunjunganData({
    required this.pegawaiId,
    required this.profil,
    required this.nama,
    required this.nip,
    required this.usia,
    required this.jabatan,
    required this.kantorCabang,
    required this.funding,
    required this.lending,
    required this.collection,
    required this.totalKunjungan,
  });

  factory KunjunganData.fromJson(Map<String, dynamic> json) {
    return KunjunganData(
      pegawaiId: json['pegawai_id']?.toString() ?? '',
      nama: json['nama'] ?? '',
      jabatan: json['jabatan'] ?? '',
      profil: json['profil'] ?? '',
      usia: json['usia']?.toString() ?? '0',
      nip: json['nip']?.toString() ?? '',
      kantorCabang: json['kantor_cabang'] ?? '',
      funding: json['type_kunjungan_0'] ?? 0,
      lending: json['type_kunjungan_1'] ?? 0,
      collection: json['type_kunjungan_2'] ?? 0,
      totalKunjungan: json['total_kunjungan'] ?? 0,
    );
  }
}

class _KunjunganScreenState extends State<KunjunganScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<KunjunganData> kunjunganDataList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchKunjunganData();
  }

  Future<void> fetchKunjunganData() async {
    try {
      setState(() => isLoading = true);
      var response = await ApiHandler().getData('/kunjunganreport');
      debugPrint('API Response Status Code: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'] as List;
        setState(() {
          kunjunganDataList = data.map((item) => KunjunganData.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch data.');
      }
    } catch (e) {
      setState(() => isLoading = false);
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kunjungan", style: TextStyle(fontSize: 20, color: Colors.white)),
        backgroundColor: const Color(0xFF007BFF),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Data Pegawai"),
            Tab(text: "Laporan"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          isLoading ? const Center(child: CircularProgressIndicator()) : _buildDataPegawaiTab(),
          const Center(child: Text("Laporan belum tersedia")),
        ],
      ),
    );
  }

  Widget _buildDataPegawaiTab() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        const Text("Data Pegawai", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
               showCheckboxColumn: false,
              columns: const [
                DataColumn(label: Text("Foto")),
                DataColumn(label: Text("Nama")),
                DataColumn(label: Text("Funding (%)")),
                DataColumn(label: Text("Lending (%)")),
                DataColumn(label: Text("Collection (%)")),
                DataColumn(label: Text("Total Kunjungan")),
              ],
              rows: kunjunganDataList.map((data) {
                double fundingPercent = (data.totalKunjungan > 0) ? (data.funding / data.totalKunjungan * 100) : 0;
                double lendingPercent = (data.totalKunjungan > 0) ? (data.lending / data.totalKunjungan * 100) : 0;
                double collectionPercent = (data.totalKunjungan > 0) ? (data.collection / data.totalKunjungan * 100) : 0;

                return DataRow(
                  onSelectChanged: (selected) {
                    if (selected == true) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailKunjunganPage(
                            pegawaiId: data.pegawaiId,
                          ),
                        ),
                      );
                    }
                  },
                  cells: [
                    DataCell(
                      Image.network(
                        data.profil,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.error),
                      ),
                    ),
                    DataCell(Text(data.nama)),
                    DataCell(_buildProgressIndicator(fundingPercent, Colors.green)),
                    DataCell(_buildProgressIndicator(lendingPercent, Colors.blue)),
                    DataCell(_buildProgressIndicator(collectionPercent, Colors.orange)),
                    DataCell(Text(data.totalKunjungan.toString())),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildProgressIndicator(double percent, Color color) {
  return Padding(
    padding: EdgeInsets.only(top: 13),
    child: SizedBox(
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: percent / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 4),
          Text("${percent.toStringAsFixed(1)}%", style: const TextStyle(fontSize: 12)),
        ],
      ),
    ),
  );
}
}

class DetailKunjunganData {
  final String nama;
  final String jabatan_pegawai;
  final String nip;
  final int usia;
  final String kantor_cabang_pegawai;
  final String avatar;

  DetailKunjunganData({
    required this.nama,
    required this.jabatan_pegawai,
    required this.nip,
    required this.usia,
    required this.kantor_cabang_pegawai,
    required this.avatar,
  });

  factory DetailKunjunganData.fromJson(Map<String, dynamic> json) {
    return DetailKunjunganData(
      nama: json['nama'],
      jabatan_pegawai: json['jabatan'],
      nip: json['nip'],
      usia: json['usia'],
      kantor_cabang_pegawai: json['cabang'],
      avatar: json['avatar'],
    );
  }
}
class Nasabah {
  final String nama;
  final String kolektibilitas;
  final int pokok;
  final int bunga;
  final int denda;
  final int totalTagihan;

  Nasabah({
    required this.nama,
    required this.kolektibilitas,
    required this.pokok,
    required this.bunga,
    required this.denda,
    required this.totalTagihan,
  });

  factory Nasabah.fromJson(Map<String, dynamic> json) {
  return Nasabah(
    nama: json['nama'] ?? '',
    kolektibilitas: json['kolektibilitas'] ?? '',
    pokok: json['pokok'] is int ? json['pokok'] : int.tryParse(json['pokok'].toString()) ?? 0,
    bunga: json['bunga'] is int ? json['bunga'] : int.tryParse(json['bunga'].toString()) ?? 0,
    denda: json['denda'] is int ? json['denda'] : int.tryParse(json['denda'].toString()) ?? 0,
    totalTagihan: json['total_tagihan'] is int ? json['total_tagihan'] : int.tryParse(json['total_tagihan'].toString()) ?? 0,
  );
}
String formatRupiah(int number) {
    return NumberFormat("#,###", "id_ID").format(number);
  }
}


class DetailKunjunganPage extends StatefulWidget {
  final String pegawaiId;
  const DetailKunjunganPage({Key? key, required this.pegawaiId}) : super(key: key);

  @override
  State<DetailKunjunganPage> createState() => _DetailKunjunganPageState();
}

class _DetailKunjunganPageState extends State<DetailKunjunganPage> {
  DetailKunjunganData? detailKunjunganData;
  List<Nasabah> nasabahList = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchDetailKunjungan();
  }
  Future<void> fetchDetailKunjungan() async {
    String apiUrl = '/detailkunjunganreport/${widget.pegawaiId}';

    try {
      var response = await ApiHandler().getData(apiUrl);
      debugPrint('API Response Status Code: ${response.statusCode}');
      debugPrint('API Response kunjungan Body: ${response.body}',);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        
        setState(() {
          nasabahList = (jsonResponse['data'][0]['nasabah'] as List)
              .map((nasabah) => Nasabah.fromJson(nasabah))
              .toList();
          isLoading = false;
        });
      } else {
        debugPrint('Gagal mengambil data Kunjungan detail');
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
  title: const Text(
    'Detail Kunjungan',
    style: TextStyle(
      fontSize: 20, // Set font size to 20
    ),
  ),
  backgroundColor: Color(0xFF007BFF),
  foregroundColor: Colors.white, // Mengubah warna teks menjadi putih
  centerTitle: true, // Mengatur teks agar berada di tengah
),
body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: DataTableTheme(
                  data: DataTableThemeData(
                    headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue), // Warna header
                    headingTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Warna teks header
                  ),
                  
                  child: DataTable(
                    border: TableBorder.all(
                      color: Colors.black,
                      width: 1,
                    ),
                    columns: const [
                      DataColumn(label: Text('No')),
                      DataColumn(label: Text('Nama')),
                      DataColumn(label: Text('Kolektibilitas')),
                      DataColumn(label: Text('Pokok')),
                      DataColumn(label: Text('Bunga')),
                      DataColumn(label: Text('Denda')),
                      DataColumn(label: Text('Total Tagihan')),
                    ],
                   rows: nasabahList.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final nasabah = entry.value;
                      return DataRow(cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(Text(nasabah.nama)),
                        DataCell(Text(nasabah.kolektibilitas)),
                        DataCell(Text(nasabah.formatRupiah(nasabah.pokok).toString())),
                        DataCell(Text(nasabah.formatRupiah(nasabah.bunga).toString())),
                        DataCell(Text(nasabah.formatRupiah(nasabah.denda).toString())),
                        DataCell(Text(nasabah.formatRupiah(nasabah.totalTagihan).toString())),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
    );
  }
}

// class KunjunganScreen extends StatefulWidget {
//   const KunjunganScreen({required this.prevPage,super.key});
//   final String prevPage;
//   @override
//   _KunjunganScreenState createState() => _KunjunganScreenState();
// }
// class KunjunganData {
//   final String pegawai_id;
//   final String profil;
//   final String nama;
//   final String nip;
//   final String usia;
//   final String jabatan;
//   final String kantor_cabang;
//   final String type_kunjungan_0;
//   final String type_kunjungan_1;
//   final String type_kunjungan_2;
// KunjunganData({
//   required this.pegawai_id,
//   required this.profil,
//   required this.nama,
//   required this.nip,
//   required this.usia,
//   required this.jabatan,
//   required this.kantor_cabang,
//   required this.type_kunjungan_0,
//   required this.type_kunjungan_1,
//   required this.type_kunjungan_2,
// });
// factory KunjunganData.fromJson(Map<String, dynamic> json) {
//     return KunjunganData(
//       pegawai_id: json['pegawai_id'] ?? '',
//       nama: json['nama'] ?? '',
//       jabatan: json['jabatan'] ?? '',
//       profil: json['profil'] ?? '',
//       usia: json['usia'] != null ? json['usia'].toString() : '0',
//       nip: json['nip'] != null ? json['nip'].toString() : '',
//       kantor_cabang: json['kantor_cabang'] ?? '',
//       type_kunjungan_0: json['type_kunjungan_0'] ?? '',
//       type_kunjungan_1: json['type_kunjungan_1'] ?? '',
//       type_kunjungan_2: json['type_kunjungan_2'] ?? '',
//     );
//   }
// }

// class _KunjunganScreenState extends State<KunjunganScreen> {
  
//   List<KunjunganData> kunjunganDataList = [];
//   bool isLoading = true;
//   @override
//   void initState() {
//     super.initState();
//     fetchKunjunganData(); // Panggil fungsi untuk mengambil data saat inisialisasi
//   }
//   Future<void> fetchKunjunganData() async {
//     try {
//       setState(() {
//         isLoading = true; // Set loading true saat mulai mengambil data
//       });

//       var url = '/kunjunganreport';
//       var dat = await ApiHandler().getData(url);
//       debugPrint('API Response Status Code: ${dat.statusCode}');
//       debugPrint('API Response Body: ${dat.body}');
//       if (dat.statusCode == 200 && dat.body != null) {
//         final Map<String, dynamic> jsonResponse = jsonDecode(dat.body);
        
//         if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
//           final List<dynamic> data = jsonResponse['data'];
//           List<KunjunganData> tempList = 
//               data.map((item) => KunjunganData.fromJson(item)).toList();

//           setState(() {
//             kunjunganDataList = tempList; // Simpan data ke variabel
//             isLoading = false; // Set loading false setelah data didapat
//           });
//         } else {
//           throw Exception('Invalid data format');
//         }
//       } else {
//         throw Exception('Failed to fetch data. Status code: ${dat.statusCode}');
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false; // Set loading false jika ada error
//       });
//       Fluttertoast.showToast(msg: 'Error: $e');
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Kunjungan",
//           style: TextStyle(
//             fontSize: 20,
//             color: Colors.white,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         backgroundColor: const Color(0xFF007BFF),
//         centerTitle: true,
//         leading: IconButton( // Add this line for the back button
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
//             Navigator.pop(context); // Navigate back to the previous screen
//           },
//         ),
//         actions: [
//           // IconButton(
//           //   icon: const Icon(Icons.search, color: Colors.white),
//           //   onPressed: _onSearchPressed,
//           // ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             const SizedBox(height: 20),
//             const Center(
//               child: Text(
//                 "Data Pegawai",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ),
//             const SizedBox(height: 10),
//             Expanded(
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: SizedBox(
//                   width: MediaQuery.of(context).size.width * 1.2,
//                   child: Column(
//                     children: [
//                       Expanded(
//                         child: SingleChildScrollView(
//                           child: Table(
//                             border: TableBorder.all(color: Colors.grey),
//                             columnWidths: const {
//                               0: FixedColumnWidth(40),
//                               1: FixedColumnWidth(60),
//                               2: FlexColumnWidth(3),
//                               3: FlexColumnWidth(1.5),
//                               4: FlexColumnWidth(1.5),
//                               5: FlexColumnWidth(1.5),
//                             },
//                             children: [
//                               _buildTableHeader(),
//                               ..._buildTableRows(),
//                             ],
//                           ),
//                         ),
//                       ),
//                       _buildPaginationControls(),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

  

//   TableRow _buildTableHeader() {
//     return TableRow(
//       decoration: const BoxDecoration(
//         color: Color.fromARGB(255, 165, 165, 165),
//       ),
//       children: [
//         _buildTableHeaderCell('No'),
//         _buildTableHeaderCell('Image'),
//         _buildTableHeaderCell('Nama'),
//         _buildTableHeaderCell('Fanding'),
//         _buildTableHeaderCell('Landing'),
//         _buildTableHeaderCell('Total'),
//       ],
//     );
//   }

//   List<TableRow> _buildTableRows() {
//   final startIndex = currentPage * itemsPerPage;
//   final endIndex = (startIndex + itemsPerPage < kunjunganDataList.length)
//       ? startIndex + itemsPerPage
//       : kunjunganDataList.length;

//   return List.generate(
//     endIndex - startIndex,
//     (index) {
//       final actualIndex = startIndex + index;
//       final employee = kunjunganDataList[actualIndex];
      
//       // Example values for fanding, landing, and total
//       double fanding = 70.0; // Should be of type double
//       double landing = 30.0; // Should be of type double
//       double total = 100.0;  // Should be of type double

//       return _buildTableRow(
//         (actualIndex + 1).toString(),
//         employee,
//         fanding,
//         landing,
//         total,
//       );
//     },
//   );
// }

//   TableRow _buildTableRow(String no, KunjunganData kunjunganDataList, double fanding, double landing, double total) {
//   // bool isSelected = kunjunganDataList.indexOf(kunjunganDataList) == selectedKunjunganIndex;

//   // Check to prevent division by zero
//   double fandingPercentage = total > 0 ? fanding / total : 0.0; 
//   double landingPercentage = total > 0 ? landing / total : 0.0; 

//   return TableRow(
//     decoration: BoxDecoration(
//       // color: isSelected ? Colors.blue[100] : Colors.white,
//     ),
//     children: [
//       _buildTableCell(no, center: true),
//       Container(
//         padding: const EdgeInsets.all(4.0),
//         height: 50,
//         width: 50,
//         child: ClipRRect(
//           borderRadius: BorderRadius.zero,
//           child: Image.asset(
//             kunjunganDataList.imagePath,
//             fit: BoxFit.cover,
//             errorBuilder: (context, error, stackTrace) {
//               return Container(
//                 color: Colors.grey[300],
//               );
//             },
//           ),
//         ),
//       ),
//       InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => KunjunganPage()),
//           );
//         },
//         child: _buildTableCell(kunjunganDataList.nama),
//       ),
//       _buildProgressCell(fandingPercentage, Colors.green),
//       _buildProgressCell(landingPercentage, const Color.fromARGB(255, 255, 0, 0)),
//       _buildProgressCell(1.0, Colors.blue), // Total is always 100%
//     ],
//   );
// }

// TableCell _buildProgressCell(double percentage, Color color) {
//   return TableCell(
//     child: Container(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         children: [
//           LinearProgressIndicator(
//             value: percentage,
//             backgroundColor: Colors.grey[300],
//             valueColor: AlwaysStoppedAnimation<Color>(color),
//           ),
//           SizedBox(height: 5),
//           Text('${(percentage * 100).toStringAsFixed(0)}%'), // Display percentage
//         ],
//       ),
//     ),
//   );
// }

//   TableCell _buildTableCell(String value, {bool center = false}) {
//     return TableCell(
//       child: Container(
//         alignment: center ? Alignment.center : Alignment.centerLeft,
//         padding: const EdgeInsets.all(8.0),
//         child: Text(value),
//       ),
//     );
//   }

//   TableCell _buildTableHeaderCell(String value) {
//     return TableCell(
//       child: Container(
//         padding: const EdgeInsets.all(8.0),
//         child: Text(
//           value,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }
// }


// class KunjunganPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false, // Menghilangkan debug banner
//       home: DefaultTabController(
//         length: 2, // Jumlah tab
//         child: Scaffold(
//           appBar: AppBar(
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back, color: Colors.white),
//               onPressed: () {
//                 Navigator.pop(context); // Go back to the previous screen
//               },
//             ),
//             title: const Text(
//               'Kunjungan',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 20, // Set font size to 20
//               ),
//             ),
//             centerTitle: true,
//             backgroundColor: const Color(0xFF007BFF),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.search, color: Colors.white),
//                 onPressed: () {},
//               ),
//             ],
//             bottom: TabBar(
//               labelColor: Colors.white, // Warna teks tab yang dipilih
//               unselectedLabelColor: Colors.white70, // Warna teks tab yang tidak dipilih
//               indicatorColor: Colors.white, // Warna indikator di bawah tab
//               tabs: [
//                 Tab(text: 'Data Nasabah'),
//                 Tab(text: 'Laporan Korelasi'),
//               ],
//             ),
//           ),
//           body: TabBarView(
//             children: [
//               _buildDataNasabahView(),
//               _buildLaporanKorelasiView(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Halaman untuk "Data Nasabah"
//   Widget _buildDataNasabahView() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildProfileSection(),
//           SizedBox(height: 16),
//           Center(
//             child: Column(
//               children: [
//                 Text(
//                   'Data Nasabah',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Container(
//                   width: 120,
//                   height: 2,
//                   color: Colors.black,
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 8),
//           Expanded(child: _buildScrollableDataTable()), // Scrollable table
//         ],
//       ),
//     );
//   }

//   // Halaman untuk "Laporan Korelasi"
//   Widget _buildLaporanKorelasiView() {
//     return Center(
//       child: Text(
//         'Laporan Korelasi',
//         style: TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileSection() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const CircleAvatar(
//           radius: 40,
//           backgroundImage: AssetImage('assets/images/mawareva.jpg'),
//         ),
//         const SizedBox(width: 16),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: const [
//             Text(
//               'Mawar Eva de Jongh',
//               style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 4),
//             Text(
//               'Front end Development',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Color(0xFF007BFF),
//               ),
//             ),
//             SizedBox(height: 4),
//             Text('NIP: 0988767656s657897'),
//             Text('Usia : 25 Tahun'),
//             Text('Kantor : Kantor Pusat Operasional'),
//             SizedBox(height: 4),
//             Row(
//               children: [
//                 Text(
//                   'INDEX RATA-RATA KPI 4.0',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF007BFF),
//                     fontSize: 14, // Set font size to 14
//                   ),
//                 ),
//                 SizedBox(width: 8),
//                 Row(
//                   children: [
//                     Icon(Icons.star, color: Colors.amber, size: 15), // Star icon
//                     Icon(Icons.star, color: Colors.amber, size: 15), // Star icon
//                     Icon(Icons.star, color: Colors.amber, size: 15), // Star icon
//                     Icon(Icons.star, color: Colors.amber, size: 15), // Star icon
//                     Icon(Icons.star_border, color: Colors.amber, size: 15), // Star border icon
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildScrollableDataTable() {
//     return SingleChildScrollView(
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: DataTable(
//           columnSpacing: 20,
//           headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey[100]!),
//           border: TableBorder.all(
//             color: Colors.grey,
//             width: 1,
//           ),
//           columns: [
//             DataColumn(label: _buildTableHeader('No')),
//             DataColumn(label: _buildTableHeader('Nama Nasabah')),
//             DataColumn(label: _buildTableHeader('Kol')),
//             DataColumn(label: _buildTableHeader('T.Pokok')),
//             DataColumn(label: _buildTableHeader('T.Bunga')),
//             DataColumn(label: _buildTableHeader('T.Denda')),
//             DataColumn(label: _buildTableHeader('Total')),
//           ],
//           rows: _buildTableRows(),
//         ),
//       ),
//     );
//   }

//   Widget _buildTableHeader(String text) {
//     return Text(
//       text,
//       style: TextStyle(
//         fontWeight: FontWeight.bold,
//         fontSize: 14,
//         color: Colors.black87,
//       ),
//     );
//   }

//   List<DataRow> _buildTableRows() {
//     final data = [
//       ['1', 'Slamet Wiyono', 'L', '000000000', '000000000', '000000000', '000000000'],
//       ['2', 'Iswantoro', 'L', '000000000', '000000000', '000000000', '000000000'],
//       ['3', 'Wirosasminto', 'L', '000000000', '000000000', '000000000', '000000000'],
//       ['4', 'Kurniawanto', 'L', '000000000', '000000000', '000000000', '000000000'],
//       ['5', 'Kinanti Putri', 'L', '000000000', '000000000', '000000000', '000000000'],
//       ['6', 'Karina Aespa', 'L', '000000000', '000000000', '000000000', '000000000'],
//       ['7', 'Ratna Kinasih', 'L', '000000000', '000000000', '000000000', '000000000'],
//       ['8', 'Darwanti', 'L', '000000000', '000000000', '000000000', '000000000'],
//       ['9', 'Eka Yuniaarti', 'L', '000000000', '000000000', '000000000', '000000000'],
//       ['10', 'Larastaviki', 'L', '000000000', '000000000', '000000000', '000000000'],
//       ['11', 'Reisa', 'L', '000000000', '000000000', '000000000', '000000000'],
//       ['12', 'Saraswati', 'L', '000000000', '000000000', '000000000', '000000000'],
//       ['13', 'Iyalas', 'L', '000000000', '000000000', '000000000', '000000000'],
//       ['14', 'Mursyid', 'L', '000000000', '000000000', '000000000', '000000000'],
//       ['15', 'Daryanto', 'L', '000000000', '000000000', '000000000', '000000000'],
//     ];

//     return List.generate(data.length, (index) {
//       final row = data[index];
//       return DataRow(
//         color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
//           return index.isEven ? Colors.white : Colors.blueGrey[50];
//         }),
//         cells: [
//           DataCell(
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//               child: Text(
//                 row[0],
//                 style: TextStyle(fontSize: 14),
//               ),
//             ),
//           ),
//           DataCell(
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//               child: Text(
//                 row[1],
//                 style: TextStyle(fontSize: 14),
//               ),
//             ),
//           ),
//           DataCell(
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//               child: Text(
//                 row[2],
//                 style: TextStyle(fontSize: 14),
//               ),
//             ),
//           ),
//           DataCell(
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//               child: Text(
//                 row[3],
//                 style: TextStyle(fontSize: 14),
//               ),
//             ),
//           ),
//           DataCell(
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//               child: Text(
//                 row[4],
//                 style: TextStyle(fontSize: 14),
//               ),
//             ),
//           ),
//           DataCell(
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//               child: Text(
//                 row[5],
//                 style: TextStyle(fontSize: 14),
//               ),
//             ),
//           ),
//           DataCell(
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//               child: Text(
//                 row[6],
//                 style: TextStyle(fontSize: 14),
//               ),
//             ),
//           ),
//         ],
//       );
//     });
//   }
// }
