import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kpi/api/api.dart';

class EmployeeLeavePage extends StatefulWidget {
  const EmployeeLeavePage({Key? key}) : super(key: key);

  @override
  _EmployeeLeavePageState createState() => _EmployeeLeavePageState();
}

class _EmployeeLeavePageState extends State<EmployeeLeavePage> {
  final List<Employee> employees = const [
    Employee('Mawar Eva de Jongh', 'Front end Development', '09887676565657897', 'Kantor Pusat', 4.0, 'assets/images/mawareva.jpg'),
    Employee('Bryan Domani', 'Back end Development', '09887676565657897', 'Kantor Pusat', 4.0, 'assets/images/bryan.jpg'),
    Employee('Iqbal Ramadhan', 'Back end Development', '09887676565657897', 'Kantor Pusat', 4.0, 'assets/images/iqbal2.jpg'),
    Employee('Syifa Hadju', 'UI & UX', '09887676565657897', 'Kantor Pusat', 4.0, 'assets/images/bella.jpg'),
    Employee('Kylie Jenner', 'UI & UX', '09887676565657897', 'Kantor Pusat', 4.0, 'assets/images/gigi.jpg'),
    Employee('Gigi Hadid', 'Front end Development', '09887676565657897', 'Kantor Pusat', 5.0, 'assets/images/hadid.jpg'),
    Employee('Kendal Jenner', 'Front end Development', '09887676565657897', 'Kantor Pusat', 5.0, 'assets/images/aisyah.jpg'),
    Employee('Zayn Malik', 'Back end Development', '09887676565657897', 'Kantor Pusat', 5.0, 'assets/images/vino.jpg'),
    // More employees with their respective images
  ];

  List<Employee> filteredEmployees = [];
  String searchQuery = '';
  String selectedBranch = 'All'; // Default to 'All'
  String selectedMonth = 'All';  // Default to 'All'

  @override
  void initState() {
    super.initState();
    filteredEmployees = employees;
  }

  _getExamData() async {
  var dat = await ApiHandler().getData('/cutireport');
  if (dat.statusCode == 200 && dat.body != null) {
    try {
      var body = jsonDecode(dat.body);
      // Lakukan pengolahan data di sini
    } catch (e) {
      print('Error decoding API data: $e');
    }
  } else {
    print('Error fetching data from API: ${dat.statusCode}');
  }
}

  void filterEmployees() {
    setState(() {
      filteredEmployees = employees.where((employee) {
        final matchesName = employee.name.toLowerCase().contains(searchQuery.toLowerCase());
        final matchesBranch = selectedBranch == 'All' || employee.office == selectedBranch;
        // For simplicity, you could apply month filtering here based on other data
        return matchesName && matchesBranch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text(
    'Cuti Pegawai',
    style: TextStyle(
      color: Colors.white,
      fontSize: 20, // Set font size to 20
    ),
  ),
  centerTitle: true,
  backgroundColor: const Color(0xFF007BFF), // Add const for consistency
  iconTheme: const IconThemeData(
    color: Colors.white,
  ),
  actions: [
    Theme(
      data: Theme.of(context).copyWith(
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      child: IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          showSearch(
            context: context,
            delegate: EmployeeSearchDelegate(employees),
          );
        },
      ),
    ),
  ],
),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Dropdown untuk Cabang
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cabang:'),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: selectedBranch, // Set default value to 'All'
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedBranch = newValue ?? 'All'; // Ensure it's never null
                            filterEmployees();
                          });
                        },
                        items: ['All', 'Kantor Pusat', 'Kantor Cabang 1', 'Kantor Cabang 2']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Dropdown untuk Bulan
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bulan:'),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: selectedMonth, // Set default value to 'All'
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedMonth = newValue ?? 'All'; // Ensure it's never null
                            filterEmployees();
                          });
                        },
                        items: [
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
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Pegawai',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredEmployees.length,
              itemBuilder: (context, index) {
                return EmployeeCard(employee: filteredEmployees[index]); // Removed index parameter
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EmployeeSearchDelegate extends SearchDelegate<Employee?> {
  final List<Employee> employees;

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
    final results = employees.where((employee) => employee.name.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index].name),
          subtitle: Text(results[index].position),
          onTap: () {
            close(context, results[index]);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = employees.where((employee) => employee.name.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index].name),
          subtitle: Text(suggestions[index].position),
          onTap: () {
            query = suggestions[index].name;
            showResults(context);
          },
        );
      },
    );
  }
}

class Employee {
  final String name;
  final String position;
  final String nip; // NIP will always be a String, no need for null checks
  final String office;
  final double kpi;
  final String imagePath; // Add a field for the image path

  const Employee(this.name, this.position, this.nip, this.office, this.kpi, this.imagePath);
}

class EmployeeCard extends StatelessWidget {
  final Employee employee;

  const EmployeeCard({Key? key, required this.employee}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Check if the clicked employee is 'Mawar Eva de Jongh' and navigate
        if (employee.name == 'Mawar Eva de Jongh') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CutiScreen(), // Navigate to CutiScreen
            ),
          );
        }
      },
      child: Padding(
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
                    // Pure square image container without radius
                    Container(
                      width: 60, // Set width for the square
                      height: 60, // Set height for the square
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(employee.imagePath), // Load employee's image
                          fit: BoxFit.cover, // Ensure the image covers the container
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employee.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14, // Set font size to 14
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            employee.position,
                            style: const TextStyle(
                              fontSize: 14, // Set font size to 14
                              color: Color(0xFF007BFF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'NIP: ${employee.nip}',
                            style: const TextStyle(fontSize: 14), // Set font size to 14
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Kantor: ${employee.office}',
                            style: const TextStyle(fontSize: 14), // Set font size to 14
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                'INDEX RATA-RATA KPI ${employee.kpi}',
                                style: const TextStyle(
                                  color: Color(0xFF007BFF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14, // Set font size to 14
                                ),
                              ),
                              const SizedBox(width: 10),
                              Row(
                                children: List.generate(5, (starIndex) {
                                  return Icon(
                                    starIndex < employee.kpi ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: 14,
                                  );
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
