import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';


class Absen extends StatefulWidget {
  @override
  _AbsenState createState() => _AbsenState();
}

class _AbsenState extends State<Absen> {
  String selectedBranch = 'Cabang'; // Filter default untuk kantor cabang
  final List<String> branches = [
    'Cabang',
    'Kantor Pusat',
    'Cabang Jakarta',
    'Cabang Bandung',
    'Cabang Surabaya',
    'Cabang Yogyakarta',
    'Cabang Bali'
  ];

  String selectedJobType = 'Posisi'; // Filter default
  final List<String> jobTypes = [
    'Posisi',
    'Front end Development',
    'Back end Development',
    'Full Stack',
    'UI/UX Designer'
  ];

  bool showAllEmployees = false; // Variable to control "Lihat Selengkapnya"

  // Daftar karyawan
  final List<Employee> employees = [
    Employee('Mawar Eva de jongh', 'Front end Development', 'Cabang Jakarta'),
    Employee('Budi Santoso', 'Back end Development', 'Cabang Bandung'),
    Employee('Siti Aminah', 'UI/UX Designer', 'Cabang Surabaya'),
    Employee('John Doe', 'Full Stack', 'Kantor Pusat'),
    Employee('Jane Smith', 'Front end Development', 'Cabang Yogyakarta'),
    Employee('Dewi Rahayu', 'UI/UX Designer', 'Cabang Bali'),
  ];

  List<Employee> get filteredEmployees {
    // Filter berdasarkan job type dan kantor cabang
    return employees.where((employee) {
      final branchMatches =
          selectedBranch == 'Cabang' || employee.branch == selectedBranch;
      final jobTypeMatches =
          selectedJobType == 'Posisi' || employee.jobType == selectedJobType;
      return jobTypeMatches && branchMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Absen',
          style: TextStyle(
            color: Colors.white, // Set text color to white
            fontSize: 20, // Set font size to 20
          ),
        ),
        backgroundColor: Color(0xFF007BFF),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white, // Set icon color to white
            ),
            onPressed: () {
              showSearch(
                context: context,
                delegate: AttendanceSearchDelegate(employees),
              );
            },
          ),
        ],
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white, // Set back icon color to white
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown filter untuk tipe pekerjaan dan kantor cabang dalam satu baris
              Row(
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
                              selectedBranch = newValue!;
                            });
                          },
                          items: branches
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child:
                                  Text(value, style: const TextStyle(fontSize: 14)),
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
                        const Text('Posisi:', style: TextStyle(fontSize: 14)),
                        DropdownButton<String>(
                          isExpanded: true,
                          value: selectedJobType,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedJobType = newValue!;
                            });
                          },
                          items: jobTypes
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child:
                                  Text(value, style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Daftar profil karyawan berdasarkan filter (tampilkan 3 atau semua)
              Column(
                children: (filteredEmployees.isNotEmpty)
                    ? List.generate(
                        showAllEmployees
                            ? filteredEmployees.length
                            : filteredEmployees.length.clamp(0, 3), // Prevent RangeError
                        (index) =>
                            EmployeeCard(employee: filteredEmployees[index]),
                      )
                    : [
                        Text('Tidak ada karyawan yang sesuai.')
                      ], // Tampilkan pesan jika tidak ada karyawan
              ),

              // Tombol "Lihat Selengkapnya"
              if (filteredEmployees.length > 3 && !showAllEmployees)
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        showAllEmployees = true;
                      });
                    },
                    child: Text('Lihat Selengkapnya',
                        style: TextStyle(color: Color(0xFF007BFF))),
                  ),
                ),

              // Attendance Section (Scrollable Area)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10), // Space at the top
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0), // Add padding for better alignment
                    child: Text(
                      'Presentase Absensi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Ensure contrast with background
                      ),
                    ),
                  ),
                  SizedBox(
                      height:
                          50), // Increased space between the text and the chart
                  SizedBox(
                    height: 200,
                    child: AttendanceChart(),
                  ),
                  SizedBox(
                      height:
                          16), // Increased space between the chart and the legend
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LegendIndicator(color: Colors.green, text: 'Hadir'),
                        SizedBox(width: 16),
                        LegendIndicator(
                            color: Colors.yellow, text: 'Terlambat'),
                        SizedBox(width: 16),
                        LegendIndicator(color: Colors.red, text: 'Tidak Hadir'),
                      ],
                    ),
                  ),
                ],
              ),

              Group56(),
            ],
          ),
        ),
      ),
    );
  }
}

class Employee {
  final String name;
  final String jobType;
  final String branch;

  Employee(this.name, this.jobType, this.branch);
}

class EmployeeCard extends StatelessWidget {
  final Employee employee;

  const EmployeeCard({required this.employee});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the EmployeeDetailPage with the selected employee
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmployeeDetailPage(employee: employee),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/profile.jpeg'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(5), // Membuat kotak
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    employee.jobType,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF007BFF),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "NIP: 0988767656s657897",
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    "Kantor: Kantor Pusat Operasional",
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 4), // Add spacing between lines
                  Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Allocate space between the row elements
                      children: [
                        Row(
                          children: [
                            RatingBarIndicator(
                              rating: 4.0,
                              itemBuilder: (context, index) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 18.0,
                            ),
                            SizedBox(
                                width:
                                    12), // Increased spacing between stars and rating text
                          ],
                        ),
                        Text("Rating: 4.0"),
                      ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendanceSearchDelegate extends SearchDelegate<String> {
  final List<Employee> employees;

  AttendanceSearchDelegate(this.employees);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = employees
        .where((employee) =>
            employee.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index].name),
          onTap: () {
            close(context, results[index].name);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = employees
        .where((employee) =>
            employee.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index].name),
          onTap: () {
            query = suggestions[index].name;
            showResults(context);
          },
        );
      },
    );
  }
}

// Attendance Chart class
class AttendanceChart extends StatelessWidget {
  final List<AttendanceData> attendanceData = [
    AttendanceData('Jan', 22, 5, 3),
    AttendanceData('Feb', 23, 1, 2),
    AttendanceData('Mar', 24, 1, 1),
    AttendanceData('Apr', 21, 3, 4),
    AttendanceData('Mei', 23, 4, 2),
    AttendanceData('Juni', 21, 3, 4),
    AttendanceData('Juli', 22, 1, 3),
    AttendanceData('Agst', 25, 3, 0),
    AttendanceData('Sept', 21, 3, 4),
    AttendanceData('Okt', 24, 5, 1),
    AttendanceData('Nov', 20, 3, 5),
    AttendanceData('Des', 24, 1, 1),
  ];

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 25,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: SideTitles(
            showTitles: true,
            getTextStyles: (value) => const TextStyle(
              color: Colors.black,
              fontSize: 12,
            ),
            margin: 6,
          ),
          bottomTitles: SideTitles(
            showTitles: true,
            getTextStyles: (value) => const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            getTitles: (double value) {
              return attendanceData[value.toInt()].month;
            },
            margin: 8,
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: attendanceData
            .asMap()
            .entries
            .map(
              (entry) => BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    y: entry.value.attended.toDouble(),
                    colors: [Colors.green],
                  ),
                  BarChartRodData(
                    y: entry.value.late.toDouble(),
                    colors: [Colors.yellow],
                  ),
                  BarChartRodData(
                    y: entry.value.absent.toDouble(),
                    colors: [Colors.red],
                  ),
                ],
                showingTooltipIndicators: [0],
              ),
            )
            .toList(),
      ),
    );
  }
}

class AttendanceData {
  final String month;
  final int attended;
  final int late;
  final int absent;

  AttendanceData(this.month, this.attended, this.late, this.absent);
}

class LegendIndicator extends StatelessWidget {
  final Color color;
  final String text;

  const LegendIndicator({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}

class EmployeeDetailPage extends StatelessWidget {
  final Employee employee;

  const EmployeeDetailPage({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          employee.name,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Color(0xFF007BFF),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employee details
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
                  children: const [
                    Text(
                      'Mawar Eva de Jongh',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Front end Development',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF007BFF),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'NIP: 0988767656s657897',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Usia : 25 Tahun',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Kantor : Kantor Pusat Operasional',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'INDEX RATA-RATA KPI 4.0',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF007BFF),
                          ),
                        ),
                        SizedBox(width: 8),
                        Row(
                          children: [
                            Icon(Icons.star,
                                color: Colors.amber,
                                size: 15), // Changed to gold
                            Icon(Icons.star,
                                color: Colors.amber,
                                size: 15), // Changed to gold
                            Icon(Icons.star,
                                color: Colors.amber,
                                size: 15), // Changed to gold
                            Icon(Icons.star,
                                color: Colors.amber,
                                size: 15), // Changed to gold
                            Icon(Icons.star_border,
                                color: Colors.amber,
                                size: 15), // Changed to golds.star,
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 20),
            // Add spacing before attendance section
            _buildAttendanceTable()
          ],
        ),
      ),
    );
  }

  // Helper method to build attendance rows
  Widget _buildAttendanceTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey), // Adds borders to the table
      columnWidths: const <int, TableColumnWidth>{
        0: FlexColumnWidth(2), // Width for the month column
        1: FlexColumnWidth(1), // Width for the hadir (attendance) column
        2: FlexColumnWidth(1), // Width for the cuti (leave) column
      },
      children: [
        _buildTableHeaderRow(), // Table header
        _buildTableRow('Januari', '23 h', '2 h'), // Data for January
        _buildTableRow('Februari', '23 h', '2 h'), // Data for February
        _buildTableRow('Maret', '23 h', '2 h'), // Data for March
        // Add more rows as needed
      ],
    );
  }

  // Helper method to build the table header
  TableRow _buildTableHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(
        color:  Colors.blue[50], // Blue background for header
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10), // Rounded top corners
          topRight: Radius.circular(10),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Bulan', // Month
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Hadir', // Attendance
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Cuti', // Leave
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  // Helper method to build a table row for attendance data
  TableRow _buildTableRow(String month, String hadir, String cuti) {
    return TableRow(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: month == 'Maret' // Apply rounded corners to last row
            ? BorderRadius.only(
                bottomLeft: Radius.circular(10), // Rounded bottom corners
                bottomRight: Radius.circular(10),
              )
            : BorderRadius.zero,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            month,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            hadir,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            cuti,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class Group56 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.all(8.0), // Adds padding around the whole container
      child: Container(
        width: 342,
        height: 251,
        decoration: BoxDecoration(
          color: Colors.white, // Background color for the whole container
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Color(0xFFCCCCCC), width: 1),
          boxShadow: [
            // Adds a shadow for a 3D effect
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header Container
            _buildHeaderContainer(),
            // Header Texts
            _buildHeaderRow(),
            // Static Data Rows
            Expanded(child: _buildDataRows()),
          ],
        ),
      ),
    );
  }

  // Method to build header container
  // Method to build header container
  Container _buildHeaderContainer() {
    return Container(
      width: 340,
      height: 37,
      decoration: BoxDecoration(
        color: Color(0xFFCCCCCC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        border: Border(bottom: BorderSide(width: 1, color: Color(0xFFCCCCCC))),
      ),
      child: Center(
        // Center the text within the container
        child: Text(
          'Kehadiran', // Text to display
          style: TextStyle(
            color: Colors.black, // Text color
            fontSize: 13, // Font size
            fontFamily: 'Poppins', // Font family
            fontWeight: FontWeight.w500, // Font weight
          ),
        ),
      ),
    );
  }

  // Method to build header row
  Row _buildHeaderRow() {
    List<String> headers = [
      'Kd',
      'Cabang',
      'H',
      'T',
      'T H',
      'PA',
      'P',
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: headers.map((header) => _buildHeaderText(header)).toList(),
    );
  }

  // Method to build header text
  // Method to build header text
  Widget _buildHeaderText(String text) {
    return SizedBox(
      width: 45,
      height: 18,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center, // Center the text
      ),
    );
  }

  // Method to build the data rows
  Widget _buildDataRows() {
    List<List<String>> dataRows = [
      ['1.1', 'Semarang', '20', '3', '5', '-', '2'],
      ['1.2', 'Pekalongan', '22', '1', '3', '2', '1'],
      ['1.3', 'Tegal', '21', '1', '4', '3', '1'],
      ['1.4', 'Boyolali', '24', '-', '1', '2', '2'],
      ['1.5', 'Temanggung', '24', '3', '1', '1', '3'],
      ['1.6', 'Jepara', '21', '2', '4', '1', '-'],
      ['1.7', 'Klaten', '22', '1', '3', '-', '2'],
    ];

    return ListView.builder(
      itemCount: dataRows.length,
      itemBuilder: (context, index) {
        return _buildRow(dataRows[index]);
      },
    );
  }

  // Method to build a row of data
  Widget _buildRow(List<String> values) {
    return Container(
      width: 340,
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(width: 1, color: Colors.grey.withOpacity(0.5))),
      ),
      child: Row(
        children: values.map((value) => _buildCell(value)).toList(),
      ),
    );
  }

  // Method to build individual cell
  Widget _buildCell(String value) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
            vertical: 10), // Increased padding for better spacing
        child: Text(
          value,
          maxLines: 1, // Limit to one line
          overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
          style: TextStyle(
            fontSize: 10,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            color: Colors.black, // Ensure text is readable
          ),
        ),
      ),
    );
  }
}