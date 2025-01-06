import 'package:flutter/material.dart';

void main() {
  runApp(LemburApp());
}

class LemburApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Lembur1(),
    );
  }
}

class Lembur1 extends StatefulWidget {
  @override
  _Lembur1State createState() => _Lembur1State();
}

class _Lembur1State extends State<Lembur1> {
  String searchQuery = "";
  String selectedJobType = 'Posisi'; // Updated default to match jobTypes
  String selectedBranch = 'Cabang'; // Updated default to match branches

  final List<String> branches = [
    'Cabang',
    'Kantor Pusat',
    'Kantor Pusat Kreatif',
    'Kantor Cabang A',
    'Kantor Cabang B'
  ];

  final List<String> jobTypes = [
    'Posisi',
    'Front end Development',
    'Back end Development',
    'UI/UX Designer'
  ];

  final List<Map<String, String>> lemburData = [
    {
      'name': 'Mawar',
      'position': 'Front end Development',
      'nip': '0988767656s657897',
      'office': 'Kantor Pusat',
      'rating': '4.0'
    },
    {
      'name': 'John',
      'position': 'Back end Development',
      'nip': '9876543210123456',
      'office': 'Kantor Pusat',
      'rating': '4.5'
    },
    {
      'name': 'Jane Smith',
      'position': 'UI/UX Designer',
      'nip': '1122334455667788',
      'office': 'Kantor Pusat Kreatif',
      'rating': '4.2'
    },
    {
      'name': 'Tom Hanks',
      'position': 'Back end Development',
      'nip': '4567891234567890',
      'office': 'Kantor Cabang A',
      'rating': '3.9'
    },
    {
      'name': 'Sarah Connor',
      'position': 'Front end Development',
      'nip': '6543217890123456',
      'office': 'Kantor Cabang B',
      'rating': '4.7'
    },
  ];

  List<Map<String, String>> get filteredLemburData {
    return lemburData.where((item) {
      final branchMatches =
          selectedBranch == 'Cabang' || item['office'] == selectedBranch;
      final jobTypeMatches =
          selectedJobType == 'Posisi' || item['position'] == selectedJobType;
      return jobTypeMatches &&
          branchMatches &&
          item['name']!.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lembur'),
        backgroundColor: Color(0xFF007BFF),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white,),
            onPressed: () {
              showSearch(
                context: context,
                delegate: LemburSearchDelegate(
                  lemburData: lemburData,
                  filterOffice: selectedBranch,
                  filterCategory: selectedJobType,
                  showFilterDialog: () {},
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
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
                              child: Text(value, style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Daftar karyawan yang sudah difilter
              Column(
                children: (filteredLemburData.isNotEmpty)
                    ? List.generate(
                        filteredLemburData.length,
                        (index) {
                          final item = filteredLemburData[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LemburDetailScreen(
                                    name: item['name']!,
                                    position: item['position']!,
                                    nip: item['nip']!,
                                    office: item['office']!,
                                    rating: item['rating']!,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              child: Card(
                                elevation: 4.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.asset(
                                          'assets/images/profile.jpeg', // Ensure this image exists
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['name']!,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              item['position']!,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF007BFF),
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text('NIP: ${item['nip'] }',
                                            style: TextStyle(fontSize: 14),),
                                            Text('Kantor: ${item['office']}',
                                            style: TextStyle(fontSize: 14),),
                                            SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: List.generate(
                                                    5,
                                                    (i) => Icon(
                                                      i <
                                                              double.parse(item[
                                                                  'rating']!)
                                                          ? Icons.star
                                                          : Icons.star_border,
                                                      size: 16,
                                                      color: Colors.amber,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                    'Rating: ${item['rating']}'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : [
                        Text('Tidak ada karyawan yang sesuai.')
                      ], // Pesan jika tidak ada karyawan
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LemburDetailScreen extends StatelessWidget {
  final String name;
  final String position;
  final String nip;
  final String office;
  final String rating;

  final List<Map<String, String>> lemburDetails = [
    {"month": "April 2024", "count": "2 kali lembur"},
    {"month": "Mei 2024", "count": "5 kali lembur"},
    {"month": "Juli 2024", "count": "1 kali lembur"},
    {"month": "Agustus 2024", "count": "3 kali lembur"},
  ];

  LemburDetailScreen({
    Key? key,
    required this.name,
    required this.position,
    required this.nip,
    required this.office,
    required this.rating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Lembur'),
        backgroundColor: Color(0xFF007BFF),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20,),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    Text(
                      'NIP: 0988767656s657897',
                      style: TextStyle(fontSize: 14), // Menambahkan fontSize 14
                    ),
                    Text(
                      'Usia: 25 Tahun',
                      style: TextStyle(fontSize: 14), // Menambahkan fontSize 14
                    ),
                    Text(
                      'Kantor: Kantor Pusat',
                    style: TextStyle(fontSize: 14), // Menambahkan fontSize 14
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'INDEX RATA-RATA KPI 4.0',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF007BFF),
                          ),
                        ),
                        SizedBox(width: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 15),  // Changed to gold
                            Icon(Icons.star, color: Colors.amber, size: 15),  // Changed to gold
                            Icon(Icons.star, color: Colors.amber, size: 15),  // Changed to gold
                            Icon(Icons.star, color: Colors.amber, size: 15),  // Changed to gold
                            Icon(Icons.star_border, color: Colors.amber, size: 15),  // Changed to golds.star,
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 20),
            Text(
              'Detail Lembur per Bulan:',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: lemburDetails.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Navigating to the detail page for the selected month
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LemburDetailMonthScreen(
                            month: lemburDetails[index]["month"]!,
                            name: name,
                            position: position,
                            nip: nip,
                            office: office,
                            rating: rating,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.blue.shade300),
                        ),
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lemburDetails[index]["month"]!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              lemburDetails[index]["count"]!,
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// New screen to show the details for a specific month
class LemburDetailMonthScreen extends StatelessWidget {
  final String month;
  final String name;
  final String position;
  final String nip;
  final String office;
  final String rating;

  // Daftar data lembur
  final List<Map<String, String>> lemburData = [
    {
      'tanggal': '08/08/2024',
      'waktuLembur': '16.00 - 22.00',
      'keterangan': 'Menyelesaikan deadline',
      'buktiLembur': 'assets/images/lembur.jpg',
    },
    {
      'tanggal': '09/08/2024',
      'waktuLembur': '17.00 - 21.00',
      'keterangan': 'Pengerjaan proyek',
      'buktiLembur': 'assets/images/lembur.jpg',
    },
    {
      'tanggal': '10/08/2024',
      'waktuLembur': '15.00 - 19.00',
      'keterangan': 'Pertemuan klien',
      'buktiLembur': 'assets/images/lembur.jpg',
    },
  ];

  LemburDetailMonthScreen({
    required this.month,
    required this.name,
    required this.position,
    required this.nip,
    required this.office,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    Text(
                      'NIP: 0988767656s657897',
                      style: TextStyle(fontSize: 14), // Menambahkan fontSize 14
                    ),
                    Text(
                      'Usia: 25 Tahun',
                      style: TextStyle(fontSize: 14), // Menambahkan fontSize 14
                    ),
                    Text(
                      'Kantor: Kantor Pusat',
                    style: TextStyle(fontSize: 14), // Menambahkan fontSize 14
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'INDEX RATA-RATA KPI 4.0',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF007BFF),
                          ),
                        ),
                        SizedBox(width: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 15),  // Changed to gold
                            Icon(Icons.star, color: Colors.amber, size: 15),  // Changed to gold
                            Icon(Icons.star, color: Colors.amber, size: 15),  // Changed to gold
                            Icon(Icons.star, color: Colors.amber, size: 15),  // Changed to gold
                            Icon(Icons.star_border, color: Colors.amber, size: 15),  // Changed to golds.star,
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 20),
            Text(
              'Riwayat Lembur:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: _buildMonthTable(lemburData), // Menggunakan lemburData
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthTable(List<Map<String, String>> lemburData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Table(
            border: TableBorder.all(color: Colors.transparent),
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(3),
              3: FlexColumnWidth(2),
            },
            children: [
              // Header Tabel
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Tanggal',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Waktu Lembur',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Keterangan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Bukti Lembur',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              // Baris Data Tabel
              ...lemburData.map((data) {
                return _buildTableRow(
                  tanggal: data['tanggal'] ?? '',
                  waktuLembur: data['waktuLembur'] ?? '',
                  keterangan: data['keterangan'] ?? '',
                  buktiLembur: data['buktiLembur'] ?? '',
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow({
    required String tanggal,
    required String waktuLembur,
    required String keterangan,
    required String buktiLembur,
  }) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            tanggal,
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            waktuLembur,
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            keterangan,
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            buktiLembur,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}

class LemburSearchDelegate extends SearchDelegate {
  final List<Map<String, String>> lemburData;
  final String? filterCategory;
  final String? filterOffice;
  final VoidCallback showFilterDialog;

  LemburSearchDelegate({
    required this.lemburData,
    required this.filterCategory,
    required this.filterOffice,
    required this.showFilterDialog,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredLemburData = lemburData.where((item) {
      bool matchesSearch =
          item['name']!.toLowerCase().contains(query.toLowerCase());
      bool matchesFilterCategory =
          filterCategory == null || item['position'] == filterCategory;
      bool matchesFilterOffice =
          filterOffice == null || item['office'] == filterOffice;
      return matchesSearch && matchesFilterCategory && matchesFilterOffice;
    }).toList();

    if (filteredLemburData.isEmpty) {
      return Center(
        child: Text('Tidak ditemukan hasil'),
      );
    }

    return ListView.builder(
      itemCount: filteredLemburData.length,
      itemBuilder: (context, index) {
        final item = filteredLemburData[index];
        return ListTile(
          title: Text(item['name']!),
          subtitle: Text(item['position']!),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LemburDetailMonthScreen(
                  month: 'Agustus',
                  name: item['name']!,
                  position: item['position']!,
                  nip: item['nip']!,
                  office: item['office']!,
                  rating: item['rating']!,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}