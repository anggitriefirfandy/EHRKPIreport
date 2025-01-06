import 'package:flutter/material.dart';

class KunjunganScreen extends StatefulWidget {
  const KunjunganScreen({super.key});

  @override
  State<KunjunganScreen> createState() => _KunjunganScreenState();
}

class Employee {
  final String name;
  final String position;
  final String nip;
  final String office;
  final double kpi;
  final String imagePath;

  const Employee(this.name, this.position, this.nip, this.office, this.kpi, this.imagePath);
}

class _KunjunganScreenState extends State<KunjunganScreen> {
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

  final List<Employee> employees = [
    const Employee('Mawar Eva de Jongh', 'Manager', '12345', 'Kantor Pusat', 4.5, 'assets/images/mawareva.jpg'),
    const Employee('Bryan Domani', 'Staff', '12346', 'Kantor Cabang 1', 3.8, 'assets/images/bryan.jpg'),
    const Employee('Iqbal Ramadhan', 'Staff', '12347', 'Kantor Cabang 2', 4.0, 'assets/images/iqbal2.jpg'),
    const Employee('Syifa Hadju', 'Manager', '12348', 'Kantor Pusat', 5.0, 'assets/images/bella.jpg'),
    const Employee('Aisyah Aqillah', 'Manager', '12349', 'Kantor Pusat', 5.0, 'assets/images/aisyah.jpg'),
    const Employee('Vino G. Bastian', 'Manager', '12349', 'Kantor Pusat', 5.0, 'assets/images/bastian.jpg'),
    const Employee('Bella Hadid', 'Manager', '12349', 'Kantor Pusat', 5.0, 'assets/images/hadid.jpg'),
    const Employee('Gigi Hadid', 'Manager', '12349', 'Kantor Pusat', 5.0, 'assets/images/gigi.jpg'),
    const Employee('Bastian Steel', 'Manager', '12349', 'Kantor Pusat', 5.0, 'assets/images/bastian.jpg'),
    const Employee('Farell Haryanto', 'Manager', '12349', 'Kantor Pusat', 5.0, 'assets/images/haryo.jpg'),
  ];

  String selectedBranch = 'All';
  String selectedMonth = 'All';
  int selectedEmployeeIndex = -1;
  int currentPage = 0;
  final int itemsPerPage = 10;

  void _onSearchPressed() {
    showSearch<Employee?>(context: context, delegate: EmployeeSearchDelegate(employees)).then((selectedEmployee) {
      if (selectedEmployee != null) {
        print('Selected Employee: ${selectedEmployee.name}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kunjungan",
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color(0xFF007BFF),
        centerTitle: true,
        leading: IconButton( // Add this line for the back button
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _onSearchPressed,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFilters(),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Data Pegawai",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 1.2,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Table(
                            border: TableBorder.all(color: Colors.grey),
                            columnWidths: const {
                              0: FixedColumnWidth(40),
                              1: FixedColumnWidth(60),
                              2: FlexColumnWidth(3),
                              3: FlexColumnWidth(1.5),
                              4: FlexColumnWidth(1.5),
                              5: FlexColumnWidth(1.5),
                            },
                            children: [
                              _buildTableHeader(),
                              ..._buildTableRows(),
                            ],
                          ),
                        ),
                      ),
                      _buildPaginationControls(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cabang:'),
              DropdownButton<String>(
                isExpanded: true,
                value: selectedBranch,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedBranch = newValue ?? 'All';
                  });
                },
                items: branches.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
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
              const Text('Bulan:'),
              DropdownButton<String>(
                isExpanded: true,
                value: selectedMonth,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedMonth = newValue ?? 'All';
                  });
                },
                items: months.map<DropdownMenuItem<String>>((String value) {
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
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 165, 165, 165),
      ),
      children: [
        _buildTableHeaderCell('No'),
        _buildTableHeaderCell('Image'),
        _buildTableHeaderCell('Nama'),
        _buildTableHeaderCell('Fanding'),
        _buildTableHeaderCell('Landing'),
        _buildTableHeaderCell('Total'),
      ],
    );
  }

  List<TableRow> _buildTableRows() {
  final startIndex = currentPage * itemsPerPage;
  final endIndex = (startIndex + itemsPerPage < employees.length)
      ? startIndex + itemsPerPage
      : employees.length;

  return List.generate(
    endIndex - startIndex,
    (index) {
      final actualIndex = startIndex + index;
      final employee = employees[actualIndex];
      
      // Example values for fanding, landing, and total
      double fanding = 70.0; // Should be of type double
      double landing = 30.0; // Should be of type double
      double total = 100.0;  // Should be of type double

      return _buildTableRow(
        (actualIndex + 1).toString(),
        employee,
        fanding,
        landing,
        total,
      );
    },
  );
}

  TableRow _buildTableRow(String no, Employee employee, double fanding, double landing, double total) {
  bool isSelected = employees.indexOf(employee) == selectedEmployeeIndex;

  // Check to prevent division by zero
  double fandingPercentage = total > 0 ? fanding / total : 0.0; 
  double landingPercentage = total > 0 ? landing / total : 0.0; 

  return TableRow(
    decoration: BoxDecoration(
      color: isSelected ? Colors.blue[100] : Colors.white,
    ),
    children: [
      _buildTableCell(no, center: true),
      Container(
        padding: const EdgeInsets.all(4.0),
        height: 50,
        width: 50,
        child: ClipRRect(
          borderRadius: BorderRadius.zero,
          child: Image.asset(
            employee.imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
              );
            },
          ),
        ),
      ),
      InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => KunjunganPage()),
          );
        },
        child: _buildTableCell(employee.name),
      ),
      _buildProgressCell(fandingPercentage, Colors.green),
      _buildProgressCell(landingPercentage, const Color.fromARGB(255, 255, 0, 0)),
      _buildProgressCell(1.0, Colors.blue), // Total is always 100%
    ],
  );
}

TableCell _buildProgressCell(double percentage, Color color) {
  return TableCell(
    child: Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          SizedBox(height: 5),
          Text('${(percentage * 100).toStringAsFixed(0)}%'), // Display percentage
        ],
      ),
    ),
  );
}

  TableCell _buildTableCell(String value, {bool center = false}) {
    return TableCell(
      child: Container(
        alignment: center ? Alignment.center : Alignment.centerLeft,
        padding: const EdgeInsets.all(8.0),
        child: Text(value),
      ),
    );
  }

  TableCell _buildTableHeaderCell(String value) {
    return TableCell(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: currentPage > 0
              ? () {
                  setState(() {
                    currentPage--;
                  });
                }
              : null,
        ),
        Text('Page ${currentPage + 1} of ${((employees.length / itemsPerPage).ceil())}'),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: (currentPage + 1) * itemsPerPage < employees.length
              ? () {
                  setState(() {
                    currentPage++;
                  });
                }
              : null,
        ),
      ],
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
    final List<Employee> results = employees
        .where((employee) => employee.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final employee = results[index];
        return ListTile(
          title: Text(employee.name),
          onTap: () {
            close(context, employee);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView.builder(
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        return ListTile(
          title: Text(employee.name),
          onTap: () {
            query = employee.name;
          },
        );
      },
    );
  }
}

class KunjunganPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Menghilangkan debug banner
      home: DefaultTabController(
        length: 2, // Jumlah tab
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context); // Go back to the previous screen
              },
            ),
            title: const Text(
              'Kunjungan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20, // Set font size to 20
              ),
            ),
            centerTitle: true,
            backgroundColor: const Color(0xFF007BFF),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {},
              ),
            ],
            bottom: TabBar(
              labelColor: Colors.white, // Warna teks tab yang dipilih
              unselectedLabelColor: Colors.white70, // Warna teks tab yang tidak dipilih
              indicatorColor: Colors.white, // Warna indikator di bawah tab
              tabs: [
                Tab(text: 'Data Nasabah'),
                Tab(text: 'Laporan Korelasi'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildDataNasabahView(),
              _buildLaporanKorelasiView(),
            ],
          ),
        ),
      ),
    );
  }

  // Halaman untuk "Data Nasabah"
  Widget _buildDataNasabahView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileSection(),
          SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text(
                  'Data Nasabah',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 2,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Expanded(child: _buildScrollableDataTable()), // Scrollable table
        ],
      ),
    );
  }

  // Halaman untuk "Laporan Korelasi"
  Widget _buildLaporanKorelasiView() {
    return Center(
      child: Text(
        'Laporan Korelasi',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
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
          backgroundImage: AssetImage('assets/images/mawareva.jpg'),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Mawar Eva de Jongh',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
            Text('NIP: 0988767656s657897'),
            Text('Usia : 25 Tahun'),
            Text('Kantor : Kantor Pusat Operasional'),
            SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'INDEX RATA-RATA KPI 4.0',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF007BFF),
                    fontSize: 14, // Set font size to 14
                  ),
                ),
                SizedBox(width: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 15), // Star icon
                    Icon(Icons.star, color: Colors.amber, size: 15), // Star icon
                    Icon(Icons.star, color: Colors.amber, size: 15), // Star icon
                    Icon(Icons.star, color: Colors.amber, size: 15), // Star icon
                    Icon(Icons.star_border, color: Colors.amber, size: 15), // Star border icon
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScrollableDataTable() {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blueGrey[100]!),
          border: TableBorder.all(
            color: Colors.grey,
            width: 1,
          ),
          columns: [
            DataColumn(label: _buildTableHeader('No')),
            DataColumn(label: _buildTableHeader('Nama Nasabah')),
            DataColumn(label: _buildTableHeader('Kol')),
            DataColumn(label: _buildTableHeader('T.Pokok')),
            DataColumn(label: _buildTableHeader('T.Bunga')),
            DataColumn(label: _buildTableHeader('T.Denda')),
            DataColumn(label: _buildTableHeader('Total')),
          ],
          rows: _buildTableRows(),
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Colors.black87,
      ),
    );
  }

  List<DataRow> _buildTableRows() {
    final data = [
      ['1', 'Slamet Wiyono', 'L', '000000000', '000000000', '000000000', '000000000'],
      ['2', 'Iswantoro', 'L', '000000000', '000000000', '000000000', '000000000'],
      ['3', 'Wirosasminto', 'L', '000000000', '000000000', '000000000', '000000000'],
      ['4', 'Kurniawanto', 'L', '000000000', '000000000', '000000000', '000000000'],
      ['5', 'Kinanti Putri', 'L', '000000000', '000000000', '000000000', '000000000'],
      ['6', 'Karina Aespa', 'L', '000000000', '000000000', '000000000', '000000000'],
      ['7', 'Ratna Kinasih', 'L', '000000000', '000000000', '000000000', '000000000'],
      ['8', 'Darwanti', 'L', '000000000', '000000000', '000000000', '000000000'],
      ['9', 'Eka Yuniaarti', 'L', '000000000', '000000000', '000000000', '000000000'],
      ['10', 'Larastaviki', 'L', '000000000', '000000000', '000000000', '000000000'],
      ['11', 'Reisa', 'L', '000000000', '000000000', '000000000', '000000000'],
      ['12', 'Saraswati', 'L', '000000000', '000000000', '000000000', '000000000'],
      ['13', 'Iyalas', 'L', '000000000', '000000000', '000000000', '000000000'],
      ['14', 'Mursyid', 'L', '000000000', '000000000', '000000000', '000000000'],
      ['15', 'Daryanto', 'L', '000000000', '000000000', '000000000', '000000000'],
    ];

    return List.generate(data.length, (index) {
      final row = data[index];
      return DataRow(
        color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          return index.isEven ? Colors.white : Colors.blueGrey[50];
        }),
        cells: [
          DataCell(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                row[0],
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          DataCell(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                row[1],
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          DataCell(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                row[2],
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          DataCell(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                row[3],
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          DataCell(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                row[4],
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          DataCell(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                row[5],
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          DataCell(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                row[6],
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      );
    });
  }
}
