import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kpi/api/api.dart';
import 'package:http/http.dart' as http;
class EmployeeLeavePage extends StatefulWidget {
  const EmployeeLeavePage({Key? key}) : super(key: key);

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
    futureLeaveData = fetchLeaveData();
  }

  Future<List<LeaveData>> fetchLeaveData() async {
    const String url = 'https://your.domainnamegoeshere.xyz/api/ehrreport/cutireport';

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

        if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
          final List<dynamic> data = jsonResponse['data'];
          List<LeaveData> leaveDataList =
              data.map((item) => LeaveData.fromJson(item)).toList();

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
          return [];
        }
      } else {
        throw Exception('Failed to fetch leave data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
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
                        applyFilter();
                      });
                    },
                  ),
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
  final String nip;
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

  LeaveData({
    required this.nip,
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
  });

  factory LeaveData.fromJson(Map<String, dynamic> json) {
    return LeaveData(
      nip: json['nip'],
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(30),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/default.jpg'),
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
            ],
          ),
        ),
      ),
    );
  }
}









// Dummy CutiScreen class, replace this with your actual screen
class CutiScreen extends StatelessWidget {
  final Map<String, dynamic> employee = {
    'name': 'Mawar Eva de Jongh',
    'position': 'Front end Development',
    'nip': '0988767656s657897',
    'age': 25,
    'office': 'Kantor Pusat',
    'leaves': [
      {
        'start_date': '2023-10-01',
        'end_date': '2023-10-05',
        'type': 'Cuti Tahunan',
        'description': 'Liburan keluarga',
      },
      {
        'start_date': '2023-11-10',
        'end_date': '2023-11-12',
        'type': 'Cuti Sakit',
        'description': 'Demam',
      },
    ],
  };

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cuti',
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: const Color(0xFF007BFF),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile section
            _buildProfileSection(),
            const SizedBox(height: 16),

            // Container for tracking items (Cuti, Cuti diambil, Sisa cuti)
            _buildTrackingContainer(),
            const SizedBox(height: 16),

            // Table for leave details
            _buildLeaveTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundImage: AssetImage('assets/images/profile.jpeg'),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              employee['name'] ?? 'N/A',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              employee['position'] ?? 'N/A',
              style: const TextStyle(fontSize: 14, color: Color(0xFF007BFF)),
            ),
            const SizedBox(height: 4),
            Text('NIP: ${employee['nip'] ?? 'N/A'}', style: const TextStyle(fontSize: 14)),
            Text('Usia : ${employee['age'] ?? 'N/A'}', style: const TextStyle(fontSize: 14)),
            Text('Kantor : ${employee['office'] ?? 'N/A'}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            _buildKpiRow(),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiRow() {
    return Row(
      children: [
        const Text(
          'INDEX RATA-RATA KPI 4.0',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF007BFF),
          ),
        ),
        const SizedBox(width: 8),
        const Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 15),
            Icon(Icons.star, color: Colors.amber, size: 15),
            Icon(Icons.star, color: Colors.amber, size: 15),
            Icon(Icons.star, color: Colors.amber, size: 15),
            Icon(Icons.star_border, color: Colors.amber, size: 15),
          ],
        ),
      ],
    );
  }

  Widget _buildTrackingContainer() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF007BFF),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildTrackingItem('25h', 'Cuti'),
          buildTrackingItem('2h', 'Cuti diambil'),
          buildTrackingItem('23h', 'Sisa cuti'),
        ],
      ),
    );
  }

  Widget _buildLeaveTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: const {
        0: FractionColumnWidth(0.3),
        1: FractionColumnWidth(0.3),
        2: FractionColumnWidth(0.2),
        3: FractionColumnWidth(0.2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.blue[50]),
          children: [
            tableCell('Cuti Mulai', isHeader: true),
            tableCell('Cuti Selesai', isHeader: true),
            tableCell('Jenis Cuti', isHeader: true),
            tableCell('Ket Cuti', isHeader: true),
          ],
        ),
        ...employee['leaves'].map<TableRow>((leave) {
          return TableRow(
            children: [
              tableCell(leave['start_date']),
              tableCell(leave['end_date']),
              tableCell(leave['type']),
              tableCell(leave['description']),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget buildTrackingItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ],
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
