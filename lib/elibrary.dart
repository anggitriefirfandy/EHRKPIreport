import 'package:flutter/material.dart';

class ElibraryApp extends StatefulWidget {
  const ElibraryApp({Key? key}) : super(key: key);

  @override
  _ElibraryAppState createState() => _ElibraryAppState();
}

class _ElibraryAppState extends State<ElibraryApp> {
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

  final List<Map<String, dynamic>> employees = [
    {
      "name": "Mawar Eva de Jongh",
      "accessCount": "3 kali",
      "position": "Front end Developer",
      "nip": "0988767656s657897",
      "age": "25 Tahun",
      "office": "Kantor Pusat Operasional",
      "books": [
        {"title": "Managing the digital: paradigms Leadership & organization", "count": "2 kali"},
        {"title": "Literature, science and public policy from Darwin to genomics", "count": "1 kali"},
      ]
    },
    {
      "name": "Bryan Domani",
      "accessCount": "5 kali",
      "position": "Backend Developer",
      "nip": "1234567890",
      "age": "30 Tahun",
      "office": "Kantor Cabang 1",
      "books": [
        {"title": "Understanding AI: Principles and Applications", "count": "3 kali"},
        {"title": "Data Science for Beginners", "count": "2 kali"},
      ]
    },
    {
      "name": "Iqbal Ramadhan",
      "accessCount": "7 kali",
      "position": "Data Scientist",
      "nip": "0987654321",
      "age": "28 Tahun",
      "office": "Kantor Cabang 2",
      "books": [
        {"title": "Machine Learning Basics", "count": "4 kali"},
        {"title": "Deep Learning Explained", "count": "2 kali"},
      ]
    },
  ];

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
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: EmployeeSearchDelegate(employees), // Call the search delegate
              );
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Table(
                      border: TableBorder.all(color: Colors.grey),
                      columnWidths: const {
                        0: FixedColumnWidth(40), // Kolom 'No', ukuran tetap
                        1: FixedColumnWidth(100), // Kolom 'Nama', ukuran tetap
                        2: FixedColumnWidth(100), // Kolom 'Akses Elibrary', ukuran tetap
                        3: FixedColumnWidth(60),  // Kolom 'Detail', ukuran tetap
                      },
                      children: [
                        // Header dengan latar belakang biru muda
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey),
                          children: [
                            tableCell('No', isHeader: true),
                            tableCell('Nama', isHeader: true),
                            tableCell('Akses Elibrary', isHeader: true),
                            tableCell('Detail', isHeader: true),
                          ],
                        ),
                        // Baris data pegawai
                        ...employees.asMap().entries.map((entry) {
                          int index = entry.key + 1;
                          Map<String, dynamic> employee = entry.value;
                          return TableRow(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                            ),
                            children: [
                              tableCell(index.toString()), // Kolom No
                              tableCell(employee['name']), // Kolom Nama
                              tableCell(employee['accessCount']), // Kolom Akses Elibrary
                              tableCellWithIcon(Icons.description, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailPage(employee: employee),
                                  ),
                                );
                              }), // Kolom Detail
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
          fontSize: 14, // Set font size to 14
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.black : Colors.black87,
        ),
      ),
    );
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
}

class EmployeeSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> employees;

  EmployeeSearchDelegate(this.employees);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Map<String, dynamic>> matchQuery = [];
    for (var employee in employees) {
      if (employee['name'].toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(employee);
      }
    }

    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result['name']),
          subtitle: Text(result['position']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPage(employee: result),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Map<String, dynamic>> matchQuery = [];
    for (var employee in employees) {
      if (employee['name'].toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(employee);
      }
    }

    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result['name']),
          subtitle: Text(result['position']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPage(employee: result),
              ),
            );
          },
        );
      },
    );
  }
}

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> employee; // Accepts the employee data

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
                      employee['name'] ?? 'N/A',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employee['position'] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF007BFF),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('NIP: ${employee['nip'] ?? 'N/A'}', style: const TextStyle(fontSize: 14)),
                    Text('Usia : ${employee['age'] ?? 'N/A'}', style: const TextStyle(fontSize: 14)),
                    Text('Kantor : ${employee['office'] ?? 'N/A'}', style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'INDEX RATA-RATA KPI 4.0',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF007BFF),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: const [
                            Icon(Icons.star, color: Colors.amber, size: 14),
                            Icon(Icons.star, color: Colors.amber, size: 14),
                            Icon(Icons.star, color: Colors.amber, size: 14),
                            Icon(Icons.star, color: Colors.amber, size: 14),
                            Icon(Icons.star_border, color: Colors.amber, size: 14),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Book list section
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
                ...employee['books'].asMap().entries.map<TableRow>((entry) {
                  int index = entry.key + 1;
                  Map<String, dynamic> book = entry.value;
                  return TableRow(
                    children: [
                      tableCell('$index'),
                      tableCell(book['title']),
                      tableCell(book['count']),
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
          fontSize: 14, // Set font size to 14
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}


