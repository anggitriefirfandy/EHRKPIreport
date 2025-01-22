import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kpi/api/api.dart';
import 'package:http/http.dart' as http;

class EmployeeLeavePage extends StatefulWidget {
  const EmployeeLeavePage({required this.prevPage, super.key});
  final String prevPage;

  @override
  _EmployeeLeavePageState createState() => _EmployeeLeavePageState();
}

class _EmployeeLeavePageState extends State<EmployeeLeavePage> {
  late Future<List<LeaveData>> futureLeaveData;
  List<LeaveData> allLeaveData = [];
  List<LeaveData> filteredLeaveData = [];
  List<LeaveData> paginatedLeaveData = [];
  int currentPage = 1;
  final int itemsPerPage = 10; // Jumlah data per halaman
  int totalPages = 1;

  String selectedBranch = 'Semua Cabang'; // Default pilihan cabang
  String selectedMonth = 'Semua Bulan'; // Default pilihan bulan
  List<String> branches = ['Semua Cabang']; // Default cabang
  final List<String> months = [
    'Semua Bulan',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  @override
  void initState() {
    super.initState();
    futureLeaveData = getDataCuti();
  } 
  Future<List<LeaveData>> getDataCuti() async {
  try {
    String month = months.indexOf(selectedMonth).toString(); // Mendapatkan bulan sebagai string
    String year = DateTime.now().year.toString(); // Mendapatkan tahun saat ini

    var url = '/cutireport?month=$month&year=$year'; // URL dengan parameter bulan dan tahun
    print('Fetching data with filters - Month: $month, Year: $year'); 
    var dat = await ApiHandler().getData(url);
    // print('Status Code: ${dat.statusCode}');
    // print('Response Body: ${dat.body}');
   
    if (dat.statusCode == 200 && dat.body != null) {
      final Map<String, dynamic> jsonResponse = jsonDecode(dat.body);
      // print('Decoded JSON: $jsonResponse');
      if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
        final List<dynamic> data = jsonResponse['data'];
        // print('Raw Data: $data');
        List<LeaveData> leaveDataList =
            data.map((item) => LeaveData.fromJson(item)).toList();
           
        // print('Leave Data List: $leaveDataList');

        // Ekstrak daftar cabang unik
        final branchSet = <String>{'Semua Cabang'};
        for (var leaveData in leaveDataList) {
          branchSet.add(leaveData.kantorCabang);
        }

        setState(() {
          branches = branchSet.toList();
          allLeaveData = leaveDataList;
          filteredLeaveData = leaveDataList;
          totalPages = (filteredLeaveData.length / itemsPerPage).ceil();
          updatePaginatedData();
        });

        return leaveDataList;
      } else {
        throw Exception('Invalid data format');
      }
    } else {
      throw Exception('Failed to fetch leave data. Status code: ${dat.statusCode}');
    }
  } catch (e) {
    Fluttertoast.showToast(msg: 'Error: $e');
    return [];
  }
}



  void applyFilter() {
    setState(() {
      filteredLeaveData = allLeaveData.where((leave) {
        bool matchesBranch = selectedBranch == 'Semua Cabang' || leave.kantorCabang == selectedBranch;
        bool matchesMonth = selectedMonth == 'Semua Bulan' || 
            DateTime.parse(leave.tglMulai).month == months.indexOf(selectedMonth);
        return matchesBranch && matchesMonth;
      }).toList();
      currentPage = 1; // Reset ke halaman pertama setelah filter diubah
      totalPages = (filteredLeaveData.length / itemsPerPage).ceil();
      updatePaginatedData();
    });
    print('Applied Filters: Branch - $selectedBranch, Month - $selectedMonth');
  print('Filtered Data Count: ${filteredLeaveData.length}');
  }

  void updatePaginatedData() {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;

    setState(() {
      paginatedLeaveData =
          filteredLeaveData.sublist(startIndex, endIndex.clamp(0, filteredLeaveData.length));
    });
  }

  void goToNextPage() {
    if (currentPage < totalPages) {
      setState(() {
        currentPage++;
        updatePaginatedData();
      });
    }
  }

  void goToPreviousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
        updatePaginatedData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cuti Pegawai',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF007BFF),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedBranch,
                    isExpanded: true,
                    items: branches.map((branch) {
                      return DropdownMenuItem(
                        value: branch,
                        child: Text(branch),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBranch = value!;
                        applyFilter();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedMonth,
                    isExpanded: true,
                    items: months.map((month) {
                      return DropdownMenuItem(
                        value: month,
                        child: Text(month),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedMonth = value!;
                        applyFilter(); // Panggil applyFilter untuk memperbarui data berdasarkan bulan yang dipilih
                      });
                    },
                  )

                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<LeaveData>>(
              future: futureLeaveData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return paginatedLeaveData.isEmpty
                      ? const Center(child: Text('No data found.'))
                      : ListView.builder(
                          itemCount: paginatedLeaveData.length,
                          itemBuilder: (context, index) {
                            final employee = paginatedLeaveData[index];
                            return EmployeeCard(employee: employee);
                          },
                        );
                }
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: goToPreviousPage,
                child: const Text('Back'),
              ),
              Text('Page $currentPage of $totalPages'),
              TextButton(
                onPressed: goToNextPage,
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



class LeaveData {
  final String nama;
  final String profil;
  final String nip;
  // final String tanggal_pengisian;
  final String jenisCuti;
  final int kategoriCuti;
  final String tglMulai;
  final String tglSelesai;
  final int jumlahAmbil;
  final int sisaCuti;
  final int statusCuti;
  final String kantorCabang;
  final String jabatan;
  final String keterangan;
  final int total;
  final int usia;

  LeaveData({
    required this.nama,
    required this.profil,
    required this.nip,
    // required this.tanggal_pengisian,
    required this.jenisCuti,
    required this.kategoriCuti,
    required this.tglMulai,
    required this.tglSelesai,
    required this.jumlahAmbil,
    required this.sisaCuti,
    required this.statusCuti,
    required this.kantorCabang,
    required this.jabatan,
    required this.keterangan,
    required this.total,
    required this.usia
  });

  factory LeaveData.fromJson(Map<String, dynamic> json) {
    return LeaveData(
      nama:json['nama'],
      profil: json['profil'],
      nip: json['nip'],
      // tanggal_pengisian: json['tanggal_pengisian'],
      jenisCuti: json['jenis_cuti'],
      kategoriCuti: json['kategori_cuti'],
      tglMulai: json['tgl_mulai'],
      tglSelesai: json['tgl_selesai'],
      jumlahAmbil: json['jumlah_ambil'],
      sisaCuti: json['sisa_cuti'],
      statusCuti: json['status_cuti'],
      kantorCabang: json['kantor_cabang'],
      jabatan: json['jabatan'],
      keterangan: json['keterangan'],
      total: json['total'],
      usia: json['usia']
    );
  }
}

class EmployeeCard extends StatelessWidget {
  final LeaveData employee;

  const EmployeeCard({Key? key, required this.employee}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  // Navigasi ke halaman detail cuti
                  Get.to(() => CutiDetailPage(leaveData: employee));
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(30),
                        image: DecorationImage(
                          image: employee.profil.isNotEmpty
                              ? (employee.profil.startsWith('http')
                                  ? NetworkImage(employee.profil) // URL gambar
                                  : AssetImage(employee.profil) as ImageProvider) // Path lokal
                              : const AssetImage('assets/images/default.jpg'), // Gambar default
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employee.nama,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black
                            ),
                          ),
                          Text(
                            employee.jabatan,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.blue
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'NIP: ${employee.nip}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Kantor: ${employee.kantorCabang}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}






class CutiDetailPage extends StatelessWidget {
  final LeaveData leaveData;

  const CutiDetailPage({required this.leaveData, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Cuti', style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF007BFF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Profil Gambar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(40),
                    image: DecorationImage(
                      image: leaveData.profil.isNotEmpty
                          ? (leaveData.profil.startsWith('http')
                              ? NetworkImage(leaveData.profil) // URL gambar
                              : AssetImage(leaveData.profil) as ImageProvider) // Path lokal
                          : const AssetImage('assets/images/default.jpg'), // Gambar default
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10), // Memberikan jarak antara gambar dan teks
                // Teks Profil
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${leaveData.nama}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text('${leaveData.jabatan}', style: const TextStyle(fontSize: 16)),
                    Text('NIP: ${leaveData.nip}', style: const TextStyle(fontSize: 16)),
                    Text('Usia: ${leaveData.usia}', style: const TextStyle(fontSize: 16)),
                    Text('Kantor: ${leaveData.kantorCabang}', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),

            
            const SizedBox(height: 10),
            // Text('Jenis Cuti: ${leaveData.jenisCuti}', style: const TextStyle(fontSize: 16)),
            // Text(
            //   'Tanggal Mulai: ${DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.parse(leaveData.tglMulai))}',
            //   style: const TextStyle(fontSize: 16),
            // ),
            // Text(
            //   'Tanggal Selesai: ${DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.parse(leaveData.tglSelesai))}',
            //   style: const TextStyle(fontSize: 16),
            // ),
            // const SizedBox(height: 10),
            // Text('Keterangan: ${leaveData.keterangan}', style: const TextStyle(fontSize: 16)),
            // // Anda bisa menambahkan informasi lebih lanjut di sini
            Padding(padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF007BFF), 
                
                borderRadius: BorderRadius.circular(8.0), 
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                children: [
                  Column(
                    children: [
                      Text(
                        '${leaveData.total.toString()}h',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                    const Text(
                      'Total Cuti',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${leaveData.jumlahAmbil.toString()}h',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Cuti Diambil',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${leaveData.sisaCuti.toString()}h',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Sisa Cuti',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          )
            ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  double screenWidth = constraints.maxWidth;
                  double columnWidth = screenWidth / 4; // Pembagian kolom secara proporsional

                  // Mengatur kolom dengan lebar proporsional dan menghindari overflow
                  return Table(
                    border: TableBorder.all(color: Colors.grey, width: 1),
                    columnWidths: {
                      0: FixedColumnWidth(columnWidth < 80 ? 80 : columnWidth), // Kolom pertama
                      1: FixedColumnWidth(columnWidth < 80 ? 80 : columnWidth), // Kolom kedua
                      2: FixedColumnWidth(columnWidth < 80 ? 80 : columnWidth), // Kolom ketiga
                      3: FixedColumnWidth(columnWidth < 80 ? 80 : columnWidth), // Kolom keempat
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey.shade200),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Jenis Cuti',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Tanggal Mulai',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Tanggal Selesai',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Keterangan',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(leaveData.jenisCuti),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              DateFormat('d MMMM yyyy', 'id_ID')
                                  .format(DateTime.parse(leaveData.tglMulai)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              DateFormat('d MMMM yyyy', 'id_ID')
                                  .format(DateTime.parse(leaveData.tglSelesai)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(leaveData.keterangan),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              )


          ],
        ),
      ),
    );
  }
}



// Dummy CutiScreen class, replace this with your actual screen
// class CutiScreen extends StatelessWidget {
//   final Map<String, dynamic> employee = {
//     'name': 'Mawar Eva de Jongh',
//     'position': 'Front end Development',
//     'nip': '0988767656s657897',
//     'age': 25,
//     'office': 'Kantor Pusat',
//     'leaves': [
//       {
//         'start_date': '2023-10-01',
//         'end_date': '2023-10-05',
//         'type': 'Cuti Tahunan',
//         'description': 'Liburan keluarga',
//       },
//       {
//         'start_date': '2023-11-10',
//         'end_date': '2023-11-12',
//         'type': 'Cuti Sakit',
//         'description': 'Demam',
//       },
//     ],
//   };

//    @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Cuti',
//           style: TextStyle(fontSize: 20),
//         ),
//         backgroundColor: const Color(0xFF007BFF),
//         foregroundColor: Colors.white,
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Profile section
//             _buildProfileSection(),
//             const SizedBox(height: 16),

//             // Container for tracking items (Cuti, Cuti diambil, Sisa cuti)
//             _buildTrackingContainer(),
//             const SizedBox(height: 16),

//             // Table for leave details
//             _buildLeaveTable(),
//           ],
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
//           backgroundImage: AssetImage('assets/images/profile.jpeg'),
//         ),
//         const SizedBox(width: 16),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               employee['name'] ?? 'N/A',
//               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               employee['position'] ?? 'N/A',
//               style: const TextStyle(fontSize: 14, color: Color(0xFF007BFF)),
//             ),
//             const SizedBox(height: 4),
//             Text('NIP: ${employee['nip'] ?? 'N/A'}', style: const TextStyle(fontSize: 14)),
//             Text('Usia : ${employee['age'] ?? 'N/A'}', style: const TextStyle(fontSize: 14)),
//             Text('Kantor : ${employee['office'] ?? 'N/A'}', style: const TextStyle(fontSize: 14)),
//             const SizedBox(height: 4),
//             _buildKpiRow(),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildKpiRow() {
//     return Row(
//       children: [
//         const Text(
//           'INDEX RATA-RATA KPI 4.0',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF007BFF),
//           ),
//         ),
//         const SizedBox(width: 8),
//         const Row(
//           children: [
//             Icon(Icons.star, color: Colors.amber, size: 15),
//             Icon(Icons.star, color: Colors.amber, size: 15),
//             Icon(Icons.star, color: Colors.amber, size: 15),
//             Icon(Icons.star, color: Colors.amber, size: 15),
//             Icon(Icons.star_border, color: Colors.amber, size: 15),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildTrackingContainer() {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey),
//         borderRadius: BorderRadius.circular(8),
//         color: const Color(0xFF007BFF),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           buildTrackingItem('25h', 'Cuti'),
//           buildTrackingItem('2h', 'Cuti diambil'),
//           buildTrackingItem('23h', 'Sisa cuti'),
//         ],
//       ),
//     );
//   }

//   Widget _buildLeaveTable() {
//     return Table(
//       border: TableBorder.all(color: Colors.grey),
//       columnWidths: const {
//         0: FractionColumnWidth(0.3),
//         1: FractionColumnWidth(0.3),
//         2: FractionColumnWidth(0.2),
//         3: FractionColumnWidth(0.2),
//       },
//       children: [
//         TableRow(
//           decoration: BoxDecoration(color: Colors.blue[50]),
//           children: [
//             tableCell('Cuti Mulai', isHeader: true),
//             tableCell('Cuti Selesai', isHeader: true),
//             tableCell('Jenis Cuti', isHeader: true),
//             tableCell('Ket Cuti', isHeader: true),
//           ],
//         ),
//         ...employee['leaves'].map<TableRow>((leave) {
//           return TableRow(
//             children: [
//               tableCell(leave['start_date']),
//               tableCell(leave['end_date']),
//               tableCell(leave['type']),
//               tableCell(leave['description']),
//             ],
//           );
//         }).toList(),
//       ],
//     );
//   }

//   Widget buildTrackingItem(String value, String label) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//         Text(
//           label,
//           style: const TextStyle(
//             color: Colors.white,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget tableCell(String text, {bool isHeader = false}) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Text(
//         text,
//         textAlign: TextAlign.center,
//         style: TextStyle(
//           fontSize: 14,
//           fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
//         ),
//       ),
//     );
//   }
// }
