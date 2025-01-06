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

  // Updated employees list with numeric material values
  final List<Map<String, dynamic>> employees = [
    {
      "name": "Mawar Eva de Jongh",
      "position": "Front end Developer",
      "score": "85",
      "material": "1",
    },
    {
      "name": "Bryan Domani",
      "position": "Backend Developer",
      "score": "90",
      "material": "2",
    },
    {
      "name": "Iqbal Ramadhan",
      "position": "Data Scientist",
      "score": "78",
      "material": "3",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
        'Exam', 
        style: TextStyle(color: Colors.white, fontSize: 20) // Ubah ukuran font di sini
      ),
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
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Add search functionality here
            },
          ),
        ],
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
                      const Text('Cabang:', style: TextStyle(fontSize: 14)), // Ubah ukuran font
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
                            child: Text(value, style: const TextStyle(fontSize: 14)), // Ubah ukuran font
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
                      const Text('Bulan:', style: TextStyle(fontSize: 14)), // Ubah ukuran font
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
                            child: Text(value, style: const TextStyle(fontSize: 14)), // Ubah ukuran font
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Table(
                      border: TableBorder.all(color: Colors.grey),
                      columnWidths: const {
                        0: FixedColumnWidth(40),
                        1: FixedColumnWidth(100),
                        2: FixedColumnWidth(100),
                        3: FixedColumnWidth(60),
                        4: FixedColumnWidth(60),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey),
                          children: [
                            tableCell('No', isHeader: true),
                            tableCell('Nama', isHeader: true),
                            tableCell('Jabatan', isHeader: true),
                            tableCell('Materi', isHeader: true),
                            tableCell('Skor', isHeader: true),
                          ],
                        ),
                        ...employees.asMap().entries.map((entry) {
                          int index = entry.key + 1;
                          Map<String, dynamic> employee = entry.value;
                          return TableRow(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                            ),
                            children: [
                              tableCell(index.toString()), // Kolom No
                              GestureDetector(
                                onTap: () {
                                  // Navigate to detail page on row tap
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailPage(
                                        employee: employee,
                                      ),
                                    ),
                                  );
                                },
                                child: tableCell(employee['name'] ?? 'N/A'), // Kolom Nama
                              ),
                              tableCell(employee['position'] ?? 'N/A'), // Kolom Jabatan
                              tableCell(employee['material'] ?? 'N/A'), // Kolom Materi
                              tableCell(employee['score'] ?? 'N/A'), // Kolom Skor
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14, // Ubah ukuran font menjadi 14
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.black : Colors.black87,
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> employee;

  const DetailPage({Key? key, required this.employee}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail',
          style: TextStyle(color: Colors.white),
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
                      employee['name'] ?? 'N/A',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), // Ubah ukuran font
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employee['position'] ?? 'N/A',
                      style: const TextStyle(fontSize: 14, color: Color(0xFF007BFF)), // Ubah ukuran font
                    ),
                    const SizedBox(height: 4),
                    const Text('NIP: 0988767656s657897', style: TextStyle(fontSize: 14)), // Ubah ukuran font
                    const Text('Usia: 25 Tahun', style: TextStyle(fontSize: 14)), // Ubah ukuran font
                    const Text('Kantor: Kantor Pusat Operasional', style: TextStyle(fontSize: 14)), // Ubah ukuran font
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          'INDEX RATA-RATA KPI 4.0',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF007BFF),
                            fontSize: 14, // Ubah ukuran font
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
              ],
            ),
            const SizedBox(height: 16),
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
                // Update material numbers with date
                TableRow(
                  children: [
                    tableCell('1'), // Material 1
                    tableCell('2024-10-24'), // Example date for Material 1
                    tableCell('Merancang UI/UX'), // Material name
                    tableCell('85'),
                  ],
                ),
                TableRow(
                  children: [
                    tableCell('2'), // Material 2
                    tableCell('2024-10-25'), // Example date for Material 2
                    tableCell('Frontend Developer'), // Material name
                    tableCell('90'),
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
          fontSize: 14, // Ubah ukuran font menjadi 14
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: ExamApp(),
  ));
}
