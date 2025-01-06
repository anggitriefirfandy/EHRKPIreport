import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // for the line chart
import 'package:percent_indicator/percent_indicator.dart'; // for circular indicators

class KPIPage extends StatefulWidget {
  const KPIPage({Key? key}) : super(key: key);

  @override
  _KPIPageState createState() => _KPIPageState();
}

class _KPIPageState extends State<KPIPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
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

  // Employee data
  final List<Employee> employees = const [
    Employee('Mawar Eva de Jongh', 'Front end Development', '09887676565657897', 'Kantor Pusat', 4.0),
    Employee('Bryan Domani', 'Back end Development', '09887676565657897', 'Kantor Pusat', 4.0),
    Employee('Iqbal Ramadhan', 'Back end Development', '09887676565657897', 'Kantor Cabang 1', 4.0),
    Employee('Syifa Hadju', 'UI & UX', '09887676565657897', 'Kantor Cabang 2', 4.0),
    Employee('Aisyah Aqillah', 'UI & UX', '09887676565657897', 'Kantor Pusat', 4.0),
    Employee('Bastian Steel', 'Front end Development', '09887676565657897', 'Kantor Cabang 1', 4.0),
  ];

  List<Employee> filteredEmployees = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KPI',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF007BFF),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
         actions: [
    IconButton(
      icon: const Icon(Icons.search, color: Colors.white),
      onPressed: () {
        // Define search action here
      },
    ),
  ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Rekap'),
            Tab(text: 'Individu'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cabang:', style: TextStyle(fontWeight: FontWeight.normal)),
                    SizedBox(
                      width: 200, // Set a fixed width for the dropdown
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedBranch,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedBranch = newValue!;
                          });
                        },
                        items: branches.map((String branch) {
                          return DropdownMenuItem<String>(
                            value: branch,
                            child: Text(
                              branch,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          );
                        }).toList(),
                        style: const TextStyle(color: Colors.black),
                        dropdownColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bulan:', style: TextStyle(fontWeight: FontWeight.normal)),
                    SizedBox(
                      width: 140, // Set the same fixed width for the month dropdown
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedMonth,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedMonth = newValue!;
                          });
                        },
                        items: months.map((String month) {
                          return DropdownMenuItem<String>(
                            value: month,
                            child: Text(
                              month,
                              style: const TextStyle(fontWeight: FontWeight.w500)
                            ),
                          );
                        }).t
                        oList(),
                        style: const TextStyle(color: Colors.black),
                        dropdownColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const Center(child: Text('Rekap Content Here')),
                const IndividuTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class IndividuTab extends StatelessWidget {
  const IndividuTab({Key? key}) : super(key: key);

  final List<Employee> employees = const [
    Employee('Mawar Eva de Jongh', 'Front end Development', '09887676565657897',
        'Kantor Pusat', 4.0),
    Employee('Bryan Domani', 'Back end Development', '09887676565657897',
        'Kantor Pusat', 4.0),
    Employee('Iqbal Ramadhan', 'Back end Development', '09887676565657897',
        'Kantor Pusat', 4.0),
    Employee('Syifa Hadju', 'UI & UX', '09887676565657897',
        'Kantor Pusat', 4.0),
    Employee('Aisyah Aqillah', 'UI & UX', '09887676565657897',
        'Kantor Pusat', 4.0),
    Employee('Bastian Steel', 'Front end Development', '09887676565657897',
        'Kantor Pusat', 4.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: employees.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (employees[index].name == 'Mawar Eva de Jongh') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const KpiDetailPage(),
                  ),
                );
              }
            },
            child: EmployeeCard(employee: employees[index], index: index + 1),
          );
        },
      ),
    );
  }
}

class EmployeeCard extends StatelessWidget {
  const EmployeeCard({Key? key, required this.employee, required this.index})
      : super(key: key);

  final Employee employee;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$index. ${employee.name}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              employee.role,
              style: const TextStyle(fontSize: 14, color: Color(0xFF007BFF)),
            ),
            const SizedBox(height: 4),
            Text('NIP : ${employee.nip}'),
            const SizedBox(height: 4),
            Text('Kantor : ${employee.office}'),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'INDEX RATA-RATA KPI ${employee.kpi.toStringAsFixed(1)}',
                  style: const TextStyle(color: Color(0xFF007BFF)),
                ),
                const SizedBox(width: 8),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < employee.kpi.toInt()
                          ? Icons.star
                          : Icons.star_border,
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
    );
  }
}

class Employee {
  final String name;
  final String role;
  final String nip;
  final String office;
  final double kpi;

  const Employee(this.name, this.role, this.nip, this.office, this.kpi);
}

class KpiDetailPage extends StatelessWidget {
  const KpiDetailPage({Key? key}) : super(key: key);

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
  title: const Text(
    'Detail KPI',
    style: TextStyle(
      fontSize: 20, // Set font size to 20
    ),
  ),
  backgroundColor: Color(0xFF007BFF),
  foregroundColor: Colors.white, // Mengubah warna teks menjadi putih
  centerTitle: true, // Mengatur teks agar berada di tengah
),

    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEmployeeInfo(),
            const SizedBox(height: 20),
            const Divider(thickness: 1, color: Colors.grey), // Divider setelah grafik
            
            // New section for performance growth line chart
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pertumbuhan Kinerja',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(
                          show: true,
                          border: const Border(
                            left: BorderSide(color: Colors.black),
                            bottom: BorderSide(color: Colors.black),
                            right: BorderSide(color: Colors.black),
                            top: BorderSide(color: Colors.transparent),
                          ),
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitles: (value) {
                              switch (value.toInt()) {
                                case 0:
                                  return 'Jan';
                                case 1:
                                  return 'Feb';
                                case 2:
                                  return 'Mar';
                                case 3:
                                  return 'Apr';
                                case 4:
                                  return 'May';
                                case 5:
                                  return 'Jun';
                                case 6:
                                  return 'Jul';
                                case 7:
                                  return 'Aug';
                                case 8:
                                  return 'Sep';
                                case 9:
                                  return 'Oct';
                                case 10:
                                  return 'Nov';
                                case 11:
                                  return 'Dec';
                                default:
                                  return '';
                              }
                            },
                          ),
                          leftTitles: SideTitles(
                            showTitles: true,
                            getTitles: (value) {
                              if (value % 20 == 0) {
                                return value.toInt().toString(); // Only show 0, 20, 40, 60, 80, 100
                              }
                              return '';
                            },
                            reservedSize: 15,
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              FlSpot(0, 0),
                              FlSpot(1, 20),
                              FlSpot(2, 50),
                              FlSpot(3, 10),
                              FlSpot(4, 30),
                              FlSpot(5, 60),
                              FlSpot(6, 20),
                              FlSpot(7, 40),
                              FlSpot(8, 80),
                              FlSpot(9, 80),
                              FlSpot(10, 100),
                              FlSpot(11, 90),
                            ],
                            isCurved: true,
                            colors: [Colors.orange],
                            barWidth: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            _buildKPIIndicators(), // Call to KPI indicators
            const SizedBox(height: 20),
            const Divider(thickness: 1, color: Colors.grey), // Divider setelah grafik
            _buildKPIRatios(),
            const Divider(thickness: 1, color: Colors.grey), // Divider setelah rasio
            const SizedBox(height: 20),
            _buildLastKPIValue(),
            const SizedBox(height: 20),
            _buildOpinionSection(),
            _buildSubmitButton(),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildEmployeeInfo() {
  return Container(
    width: double.infinity, // Membuat container memenuhi lebar yang tersedia
    height: 180, // Mengatur tinggi container
    decoration: BoxDecoration(
      color: Colors.white, // Warna latar belakang
      borderRadius: BorderRadius.circular(8), // Mengatur sudut bulat
      boxShadow: [
        BoxShadow(
          color: Colors.black26, // Warna bayangan
          blurRadius: 8, // Seberapa buram bayangan
          offset: Offset(0, 4), // Posisi bayangan
        ),
      ],
    ),
    padding: const EdgeInsets.all(16), // Padding di dalam container
    child: SingleChildScrollView( // Menambahkan SingleChildScrollView
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Mengatur avatar di sebelah kanan
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Mawar Eva de Jongh',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Frontend',
                  style: TextStyle(color: Color(0xFF007BFF)), // Mengubah warna teks menjadi biru
                ),
                Text('NIP: 2388787656s657897'),
                Text('Usia: 25 Tahun'),
                Text('Kantor: Kantor Pusat'),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'INDEX RATA-RATA KPI 4.0',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue, // Set text color to blue
                      ),
                    ),
                    SizedBox(width: 3), // Mengurangi jarak untuk menghindari overflow
                    Flexible( // Menambahkan Flexible di sini
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 13), // Mengatur ukuran ikon
                          Icon(Icons.star, color: Colors.amber, size: 13), // Mengatur ukuran ikon
                          Icon(Icons.star, color: Colors.amber, size: 13), // Mengatur ukuran ikon
                          Icon(Icons.star, color: Colors.amber, size: 13), // Mengatur ukuran ikon
                          Icon(Icons.star_border, color: Colors.amber, size: 14), // Mengatur ukuran ikon
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 14), // Jarak antara teks dan avatar
          CircleAvatar(
            radius: 35,
            backgroundImage: AssetImage('assets/images/profile.jpeg'),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildKPIIndicators() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal, // Mengatur agar bisa scroll horizontal
    child: Row(
      children: [
        _buildCircularIndicator('Target', 0.25, Color(0xFF007BFF)),
        const SizedBox(width: 16), // Menambah jarak antar indikator
        _buildCircularIndicator('Pengetahuan', 0.25, Color(0xFF007BFF)),
        const SizedBox(width: 16),
        _buildCircularIndicator('Kepemimpinan', 0.25, Color(0xFF007BFF)),
        const SizedBox(width: 16),
        _buildCircularIndicator('Kepatuhan', 0.25, Color(0xFF007BFF)),
        const SizedBox(width: 16),
        _buildCircularIndicator('Kerjasama Tim', 0.25, Color(0xFF007BFF)),
        // Tambahkan lebih banyak indikator jika diperlukan
      ],
    ),
  );
}

  Widget _buildCircularIndicator(String label, double percent, Color color) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 40.0,
          lineWidth: 5.0,
          percent: percent,
          center: Text('${(percent * 100).toInt()}%'),
          progressColor: color,
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildKPIRatios() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildRatioCard('Rasio Kehadiran', 'Terhadap kehadiran kerja', 0.7, 0.3)),
            const SizedBox(width: 8),
            Expanded(child: _buildRatioCard('Rasio Izin & Cuti', 'Terhadap ketentuan internal', 0.7, 0.3)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildRatioCard('Rasio Kehadiran', 'Terhadap hari menit kerja & izin', 0.7, 0.3)),
            const SizedBox(width: 8),
            Expanded(child: _buildRatioCard('Rasio Pelanggaran', 'Terhadap hari menit kerja & izin', 0.7, 0.3)),
          ],
        ),
      ],
    );
  }

  Widget _buildRatioCard(String title, String subtitle, double ratio1, double ratio2) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: ratio1,
              backgroundColor: Colors.red,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF007BFF)),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(ratio1 * 100).toInt()}%', style: const TextStyle(color: Color(0xFF007BFF))),
                Text('${(ratio2 * 100).toInt()}%', style: const TextStyle(color: Colors.red)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget for Last KPI Value
  Widget _buildLastKPIValue() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Nilai KPI Terakhir",
        style: TextStyle(color: Color(0xFF007BFF), fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          CircularPercentIndicator(
            radius: 50.0,
            lineWidth: 10.0,
            percent: 0.8,
            center: const Text(
              "80%",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            progressColor: Color(0xFF007BFF),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Kelebihan", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                  // Hapus tinggi agar kontainer dapat menyesuaikan ukuran
                  width: double.infinity,
                  child: SingleChildScrollView( // Menambahkan SingleChildScrollView
                    child: const Text(
                      "Ramah, Cepat dalam mengerjakan Task yang diberikan, "
                      "Tegas terhadap rekan Tim, "
                      "Mampu membimbing rekan tim yang tidak bisa",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Kekurangan", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                  height: 60,
                  width: double.infinity,
                  child: const Text(
                    "Lumayan Sering Terlambat melebihi toleransi Jam Telat",
                    style: TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}


  // Widget for Opinion Section
  Widget _buildOpinionSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Pendapat Anda",
          style: TextStyle(color: Color(0xFF007BFF), fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextField(
        maxLines: 3,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Tulis pendapat anda di sini...',
        ),
      ),
      const SizedBox(height: 20), // Menambahkan jarak antara opini dan tombol
    ],
  );
}

// Widget for Submit Button
Widget _buildSubmitButton() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16.0), // Padding untuk jarak lebih besar
    child: Center(
      child: ElevatedButton(
        onPressed: () {
          // Implement submission action here
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF007BFF),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
        child: const Text(
          'Kirim',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white, // Set text color to white
          ),
        ),
      ),
    ),
  );
}

  // Helper function to create circular KPI indicators
  Widget _buildKpiCircle(String title, double percentage) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 40.0, // Ubah radius di sini
          lineWidth: 8.0, // Sesuaikan lineWidth jika perlu
          percent: percentage / 100,
          center: Text(
            "${percentage.toInt()}%",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          progressColor: Colors.green,
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
