import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

class ExamApp extends StatefulWidget {
  const ExamApp({Key? key}) : super(key: key);

  @override
  _ExamAppState createState() => _ExamAppState();
}

class _ExamAppState extends State<ExamApp> {
  final List<String> branches = [
    'All',
    'Kantor Pusat',
    'Kantor Cabang 1',
    'Kantor Cabang 2'
  ];
  final List<String> months = [
    'All',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  String selectedBranch = 'All';
  String selectedMonth = 'All';

  List<Map<String, dynamic>> employees = []; // Awalnya kosong untuk data dari API

  @override
  void initState() {
    super.initState();
    fetchExamReport(); // Memuat data saat widget diinisialisasi
  }

  Future<void> fetchExamReport() async {
    const String url = 'https://your.domainnamegoeshere.xyz/api/ehrreport/examreport';
    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer 87718|Nya4lvosf7a5yt1VtZqZNey7PHOI9eoI2CU3LQUk5aade454', // Ganti dengan token yang valid
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print("Response body: ${response.body}");

        if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
          final List<dynamic> data = jsonResponse['data'];
          print("Data berhasil diambil: $data");

          // Mengelompokkan data berdasarkan nama
          Map<String, List<Map<String, dynamic>>> groupedData = {};
          for (var item in data) {
            String name = item["nama"] ?? 'N/A';
            if (groupedData.containsKey(name)) {
              groupedData[name]!.add(item);
            } else {
              groupedData[name] = [item];
            }
          }

          // Mengubah data untuk menampilkan materi ter-increment dan rata-rata skor
          setState(() {
            employees = groupedData.entries.map<Map<String, dynamic>>((entry) {
              String name = entry.key;
              List<Map<String, dynamic>> groupItems = entry.value;

              // Menghitung rata-rata skor dan materi unik
              double totalScore = groupItems.fold(0.0, (sum, item) {
                var nilai = item["nilai"];
                if (nilai is String) {
                  return sum + (double.tryParse(nilai) ?? 0);
                } else if (nilai is num) {
                  return sum + nilai.toDouble();
                }
                return sum;
              });
              
              double averageScore = totalScore / groupItems.length;
              
              Set<String> materiSet = {};
              for (var item in groupItems) {
                String materi = item["kategori"] ?? 'N/A';
                materiSet.add(materi);
              }
              
              String materiCount = ' ${materiSet.length}';

              return {
              "nama": name,
              "jabatan": groupItems[0]["jabatan"] ?? 'N/A',
              "kategori": materiCount,
              "nilai": averageScore.toStringAsFixed(2),
              "materi": groupItems,
              "usia": groupItems[0]["usia"],  // Usia
              "nip": groupItems[0]["nip"],    // NIP
              "tanggal_pengisian": groupItems[0]["tanggal_pengisian"],  // Tanggal Pengisian
              "kantor_cabang": groupItems[0]["kantor_cabang"],  // Kantor Cabang
              };
            }).toList();
          });




        } else {
          print("Format data tidak valid: ${jsonResponse['data']}");
          showErrorDialog('Format data tidak valid');
        }
      } else {
        print("Gagal memuat data: ${response.statusCode}");
        showErrorDialog('Gagal memuat data: ${response.statusCode}');
      }
    } catch (e) {
      print("Terjadi kesalahan: $e");
      showErrorDialog('Terjadi kesalahan: $e');
    }
  }





  void showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      title: 'Error',
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Exam',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF007BFF),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cabang:', style: TextStyle(fontSize: 14)),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: selectedBranch,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedBranch = newValue ?? 'All';
                          });
                        },
                        items: branches
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bulan:', style: TextStyle(fontSize: 14)),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: selectedMonth,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedMonth = newValue ?? 'All';
                          });
                        },
                        items: months
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'List Akses Exam',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
  child: employees.isEmpty
      ? const Center(child: CircularProgressIndicator()) // Indikator loading
      : SingleChildScrollView( // Membungkus dengan SingleChildScrollView untuk scroll vertikal
          scrollDirection: Axis.vertical, // Tentukan arah scroll vertikal
          child: SingleChildScrollView( // Scroll horizontal untuk mendukung tabel lebih lebar
            scrollDirection: Axis.horizontal,
            child: Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: const {
                0: FixedColumnWidth(40),
                1: FixedColumnWidth(100),
                2: FixedColumnWidth(100),
                3: FixedColumnWidth(100),
               
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey),
                  children: [
                    tableCell('No', isHeader: true),
                    tableCell('Nama', isHeader: true),
                    tableCell('Jabatan', isHeader: true),
                   
                    tableCell('Skor', isHeader: true),
                  ],
                ),
                ...employees.asMap().entries.map((entry) {
                  int index = entry.key + 1;
                  Map<String, dynamic> employee = entry.value;
                  return TableRow(
  children: [
    tableCell(index.toString()),
    // Pastikan data yang dikirim ke DetailPage berisi materi yang valid
// Bagian onTap di ExamApp (ketika nama diklik)
GestureDetector(
  onTap: () {
    // Menavigasi ke halaman DetailPage dan mengirimkan nama pegawai
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(
          employeeName: employee['nama'] ?? 'N/A', // Mengirim nama pegawai
        ),
      ),
    );
  },
  child: tableCell(employee['nama'] ?? 'N/A'),
),





    tableCell(employee['jabatan'] ?? 'N/A'),
    tableCell(employee['nilai'] ?? 'N/A'),
  ],
);

                }).toList(),
              ],
            ),
          ),
        ),
),


        ],
      ),
    );
  }

  Widget tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}


class DetailPage extends StatefulWidget {
  final String employeeName; // Menambahkan parameter untuk menerima nama

  const DetailPage({Key? key, required this.employeeName}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<Map<String, dynamic>> employees = []; // Data pegawai yang akan ditampilkan
  bool isLoading = true; // Indikator loading

  @override
  void initState() {
    super.initState();
    fetchEmployeeData(); // Memuat data pegawai berdasarkan nama yang diterima
  }

  Future<void> fetchEmployeeData() async {
    const String url = 'https://your.domainnamegoeshere.xyz/api/ehrreport/examreport';
    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer 87718|Nya4lvosf7a5yt1VtZqZNey7PHOI9eoI2CU3LQUk5aade454',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
          final List<dynamic> data = jsonResponse['data'];

          // Mengonversi List<dynamic> menjadi List<Map<String, dynamic>>
          List<Map<String, dynamic>> employeeData = data
              .map<Map<String, dynamic>>((item) => item as Map<String, dynamic>)
              .toList();

          // Menyaring data berdasarkan nama yang diterima
          List<Map<String, dynamic>> filteredEmployeeData = employeeData
              .where((item) => item['nama'] == widget.employeeName) // Hanya menampilkan data yang sesuai
              .toList();

          setState(() {
            employees = filteredEmployeeData; // Menyimpan data yang sudah disaring
            isLoading = false; // Menandakan bahwa data sudah dimuat
          });
        } else {
          print("Format data tidak valid");
        }
      } else {
        print("Gagal memuat data: ${response.statusCode}");
      }
    } catch (e) {
      print("Terjadi kesalahan: $e");
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Detail'),
      backgroundColor: const Color(0xFF007BFF),
      centerTitle: true,
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator()) // Loading indicator
        : SingleChildScrollView(
            child: Column(
              children: [
                // Employee profile details
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employees.isNotEmpty
                            ? employees[0]['nama'] ?? 'N/A'
                            : 'N/A',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        employees.isNotEmpty
                            ? employees[0]['jabatan'] ?? 'N/A'
                            : 'N/A',
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF007BFF)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'NIP: ${employees.isNotEmpty ? employees[0]['nip'] ?? 'N/A' : 'N/A'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Usia: ${employees.isNotEmpty ? employees[0]['usia'] ?? 'N/A' : 'N/A'} Tahun',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Kantor: ${employees.isNotEmpty ? employees[0]['kantor_cabang'] ?? 'N/A' : 'N/A'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text(
                            'INDEX RATA-RATA KPI 4.0',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF007BFF),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: const [
                              Icon(Icons.star, color: Colors.amber, size: 15),
                              Icon(Icons.star, color: Colors.amber, size: 15),
                              Icon(Icons.star, color: Colors.amber, size: 15),
                              Icon(Icons.star, color: Colors.amber, size: 15),
                              Icon(Icons.star_border, color: Colors.amber, size: 15),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Table for displaying exam details
                Table(
                  border: TableBorder.all(color: Colors.grey),
                  columnWidths: const {
                    0: FixedColumnWidth(50), // Ubah lebar kolom No
                    1: FixedColumnWidth(110), // Ubah lebar kolom Tanggal
                    2: FixedColumnWidth(145), // Ubah lebar kolom Materi
                    3: FixedColumnWidth(60), // Ubah lebar kolom Skor
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.blue[50]),
                      children: [
                        tableCell('No', isHeader: true),
                        tableCell('Tanggal', isHeader: true),
                        tableCell('Materi', isHeader: true),
                        tableCell('Skor', isHeader: true),
                      ],
                    ),
                    // Displaying filtered data based on the selected employee
                    ...employees.asMap().entries.map((entry) {
                      int index = entry.key + 1;
                      Map<String, dynamic> employee = entry.value;
                      return TableRow(
                        children: [
                          tableCell(index.toString()), // No
                          tableCell(employee['tanggal_pengisian'] ?? 'N/A'), // Tanggal
                          tableCell(employee['kategori'] ?? 'N/A'), // Materi
                          tableCell(employee['nilai'] ?? 'N/A'), // Skor
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
          ),
  );
}

  Widget tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14, // Ubah ukuran font menjadi 14
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
