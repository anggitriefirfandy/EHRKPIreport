import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ElibraryApp extends StatefulWidget {
  const ElibraryApp({Key? key}) : super(key: key);

  @override
  _ElibraryAppState createState() => _ElibraryAppState();
}

class _ElibraryAppState extends State<ElibraryApp> {
  final List<String> branches = ['All', 'EHR System', 'Other Branch'];
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
  List<Employee> employees = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLibraryData();
  }

  Future<void> fetchLibraryData() async {
    const apiUrl = 'https://your.domainnamegoeshere.xyz/api/ehrreport/libraryreport';
    try {
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer 87718|Nya4lvosf7a5yt1VtZqZNey7PHOI9eoI2CU3LQUk5aade454', // Ganti dengan token yang valid
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
          final List<dynamic> data = jsonResponse['data'];
          List<Employee> employeeList = data.map((item) => Employee.fromJson(item)).toList();

          setState(() {
            employees = employeeList;
            isLoading = false;
          });
        } else {
          throw Exception('Invalid data format');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }
  Widget tableCellWithIcon(IconData iconData, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: IconButton(
        icon: Icon(iconData, color: const Color(0xFF007BFF)),
        onPressed: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-library', style: TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: const Color(0xFF007BFF),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchLibraryData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : employees.isEmpty
              ? const Center(child: Text('No data available'))
              : Column(
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
                      'List Akses Perpustakaan',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Table(
                          border: TableBorder.all(color: Colors.grey),
                          columnWidths: const {
                            0: FixedColumnWidth(40), // Kolom 'No', ukuran tetap
                            1: FixedColumnWidth(100), // Kolom 'Nama', ukuran tetap
                            2: FixedColumnWidth(100), // Kolom 'Akses Elibrary', ukuran tetap
                            3: FixedColumnWidth(100), // Kolom 'Detail', ukuran tetap
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(color: Colors.grey),
                              children: [
                                tableCell('No', isHeader: true),
                                tableCell('Nama', isHeader: true),
                                tableCell('Request Download', isHeader: true),
                                tableCell('Detail', isHeader: true),
                              ],
                            ),
                            ..._getUniqueEmployees().asMap().entries.map((entry) {
                              int index = entry.key + 1;
                              Employee employee = entry.value;
                              int accessCount = _getAccessCount(employee.nama);
                              return TableRow(
                                children: [
                                  tableCell(index.toString()),
                                  tableCell(employee.nama),
                                  tableCell(accessCount.toString()),
                                 tableCellWithIcon(
                                    Icons.document_scanner_outlined,
                                    () {
                                      // Mengirim data employee ke halaman DetailPage
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailPage(employee: employee),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  // Mengambil daftar unik berdasarkan nama
  List<Employee> _getUniqueEmployees() {
    final Set<String> seenNames = {};
    final List<Employee> uniqueEmployees = [];

    for (var employee in employees) {
      if (!seenNames.contains(employee.nama)) {
        seenNames.add(employee.nama);
        uniqueEmployees.add(employee);
      }
    }
    return uniqueEmployees;
  }

  // Menghitung berapa kali nama muncul
  int _getAccessCount(String name) {
    return employees.where((employee) => employee.nama == name).length;
  }

  Widget tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
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

class Employee {
  final String nama;
  final String jabatan;
  final String usia;
  final String nip;
  final String namaBuku;
  final String kantorCabang;

  Employee({
    required this.nama,
    required this.jabatan,
    required this.usia,
    required this.nip,
    required this.namaBuku,
    required this.kantorCabang,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
  return Employee(
    nama: json['nama'] ?? '',  // Pastikan ini adalah string
    jabatan: json['jabatan'] ?? '',  // Pastikan ini adalah string
    usia: json['usia'].toString(),  // Ubah usia menjadi string jika di API bertipe int
    nip: json['nip'].toString(),  // Ubah nip menjadi string jika di API bertipe int
    namaBuku: json['nama_buku'] ?? '',  // Pastikan ini adalah string
    kantorCabang: json['kantor_cabang'] ?? '',  // Pastikan ini adalah string
  );
}
}















class DetailPage extends StatelessWidget {
  final Employee employee;

  const DetailPage({Key? key, required this.employee}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile section
            Row(
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
                      employee.nama,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employee.jabatan,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF007BFF),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Cabang: ${employee.kantorCabang}'),
                    const SizedBox(height: 4),
                    Text('Usia: ${employee.usia}'),
                    const SizedBox(height: 4),
                    Text('NIP: ${employee.nip}'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Buku yang dipinjam
            const Text(
              'Buku yang dipinjam',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Menampilkan buku yang dipinjam oleh karyawan
            Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: const {
                0: FractionColumnWidth(0.1),
                1: FractionColumnWidth(0.7),
                2: FractionColumnWidth(0.2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.blue[50]),
                  children: [
                    tableCell('No', isHeader: true),
                    tableCell('Nama Buku', isHeader: true),
                    tableCell('Jumlah', isHeader: true),
                  ],
                ),
                TableRow(
                  children: [
                    tableCell('1'),
                    tableCell(employee.namaBuku), // Nama buku yang dipinjam
                    tableCell('1'), // Anggap hanya 1 buku yang dipinjam
                  ],
                ),
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
          fontSize: 14,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}


