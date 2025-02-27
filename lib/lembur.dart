import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kpi/api/api.dart';

class LemburPage extends StatefulWidget {
  const LemburPage({required this.prevPage, super.key});
  final String prevPage;

  @override
  _LemburPageState createState() => _LemburPageState();
}

class LemburData {
  final String pegawai_id;
  final String nama;
  final String jabatan;
  final String profil;
  final String usia;
  final String nip;
  final String cabang;

  LemburData({
    required this.pegawai_id,
    required this.nama,
    required this.jabatan,
    required this.profil,
    required this.usia,
    required this.nip,
    required this.cabang,
  });

  factory LemburData.fromJson(Map<String, dynamic> json) {
    return LemburData(
      pegawai_id: json['pegawai_id'] ?? '',
      nama: json['nama'] ?? '',
      jabatan: json['jabatan'] ?? '',
      profil: json['profil'] ?? '',
      usia: json['usia'] != null ? json['usia'].toString() : '0',
      nip: json['nip'] != null ? json['nip'].toString() : '',
      cabang: json['cabang'] ?? '',
    );
  }
}

class _LemburPageState extends State<LemburPage> {
  List<LemburData> lemburDataList = [];
  bool isLoading = true;
  String search = "";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchLemburData();
  }


  Future<void> fetchLemburData({String? query}) async {
    try {
      setState(() {
        isLoading = true;
      });

      var url = '/lemburreport';
      if (query != null && query.isNotEmpty) {
        url += '?search=$query';
      }
      var dat = await ApiHandler().getData(url);
      debugPrint('API Response Status Code: ${dat.statusCode}');
      debugPrint('API Response Body: ${dat.body}');

      if (dat.statusCode == 200 && dat.body != null) {
        final Map<String, dynamic> jsonResponse = jsonDecode(dat.body);
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
          final List<dynamic> data = jsonResponse['data'];
          List<LemburData> tempList =
              data.map((item) => LemburData.fromJson(item)).toList();

          setState(() {
            lemburDataList = tempList;
            isLoading = false;
          });
        } else {
          throw Exception('Invalid data format');
        }
      } else {
        throw Exception('Failed to fetch data. Status code: ${dat.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }
  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchLemburData(query: value);
    });

    setState(() {
      search = value;
    });
  }
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lembur'),
        backgroundColor: const Color(0xFF007BFF),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        centerTitle: true,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.search, color: Colors.white),
          //   onPressed: () {
          //     // Implement search functionality here if needed
          //   },
          // ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Row(
              children: [
                // Add your dropdowns here if needed
              ],
            ),
            SizedBox(height: 20,),
            Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  onChanged: _onSearchChanged, // Panggil otomatis saat mengetik
                  decoration: InputDecoration(
                    labelText: "Search berdasarkan nama",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    suffixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : lemburDataList.isEmpty
                      ? const Center(child: Text('No data found.'))
                      : ListView.builder(
                          itemCount: lemburDataList.length,
                          itemBuilder: (context, index) {
                            final lembur = lemburDataList[index];
                            return LemburCard(lembur: lembur);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class LemburCard extends StatelessWidget {
  final LemburData lembur;

  const LemburCard({Key? key, required this.lembur}) : super(key: key);

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
                  Get.to(()=> LemburDetailScreen(lemburData:lembur));
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
                          image: lembur.profil.isNotEmpty &&
                                  Uri.tryParse(lembur.profil)?.hasAbsolutePath ==
                                      true
                              ? NetworkImage(lembur.profil)
                              : const AssetImage('assets/images/default.jpg')
                                  as ImageProvider,
                                  fit: BoxFit.cover
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lembur.nama,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            lembur.jabatan,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'NIP: ${lembur.nip}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Kantor: ${lembur.cabang}',
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
class DetailLemburData {
  final String bulan;
  final int jumlah;
  

  DetailLemburData({
    required this.bulan,
    required this.jumlah,
   
  });

  factory DetailLemburData.fromJson(Map<String, dynamic> json) {
    return DetailLemburData(
      bulan: json['bulan'],
      jumlah: json['jumlah'],
    );
  }
}
class LemburDetailScreen extends StatefulWidget {
  final LemburData lemburData;
  const LemburDetailScreen({required this.lemburData, Key? key}) : super(key: key);

  @override
  State<LemburDetailScreen> createState() => _LemburDetailScreenState();
}

class _LemburDetailScreenState extends State<LemburDetailScreen> {
  // Future<void> fetchLemburDetail() async {
  List<DetailLemburData> lemburDetails = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchLemburDetail();
  }

  Future<void> fetchLemburDetail() async {
    try {
      setState(() {
        isLoading = true;
      });
      
      var url = '/detaillemburreport/${widget.lemburData.pegawai_id}';
      var dat = await ApiHandler().getData(url);
      
      if (dat.statusCode == 200 && dat.body != null) {
        final Map<String, dynamic> jsonResponse = jsonDecode(dat.body);
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
          final List<dynamic> data = jsonResponse['data'];
          setState(() {
            lemburDetails = data.map((item) => DetailLemburData.fromJson(item)).toList();
            isLoading = false;
          });
        } else {
          throw Exception('Invalid data format');
        }
      } else {
        throw Exception('Failed to fetch data. Status code: ${dat.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  String formatBulan(String bulanTahun) {
    try {
      DateTime date = DateFormat("yyyy-MM").parse(bulanTahun);
      return DateFormat("MMMM yyyy", "id_ID").format(date); // Format ke "Juli 2024"
    } catch (e) {
      return bulanTahun; // Jika error, tetap pakai format awal
    }
  }
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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(40),
                    image: DecorationImage(
                      image: widget.lemburData.profil.isNotEmpty
                          ? (widget.lemburData.profil.startsWith('http')
                              ? NetworkImage(widget.lemburData.profil) // URL gambar
                              : AssetImage(widget.lemburData.profil) as ImageProvider) // Path lokal
                          : const AssetImage('assets/images/profile.jpeg'), // Gambar default
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    Text(
                      '${widget.lemburData.nama}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${widget.lemburData.jabatan}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF007BFF),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'NIP: ${widget.lemburData.nip}',
                      style: TextStyle(fontSize: 14), // Menambahkan fontSize 14
                    ),
                    Text(
                      'Usia: ${widget.lemburData.usia} Tahun',
                      style: TextStyle(fontSize: 14), // Menambahkan fontSize 14
                    ),
                    Text(
                      'Kantor: ${widget.lemburData.cabang}',
                    style: TextStyle(fontSize: 14), // Menambahkan fontSize 14
                    ),
                    SizedBox(height: 4),
                    // Row(
                    //   children: [
                    //     Text(
                    //       'INDEX RATA-RATA KPI 4.0',
                    //       style: TextStyle(
                    //         fontSize: 14,
                    //         fontWeight: FontWeight.bold,
                    //         color: Color(0xFF007BFF),
                    //       ),
                    //     ),
                    //     SizedBox(width: 8),
                    //     Row(
                    //       children: [
                    //         Icon(Icons.star, color: Colors.amber, size: 15),  // Changed to gold
                    //         Icon(Icons.star, color: Colors.amber, size: 15),  // Changed to gold
                    //         Icon(Icons.star, color: Colors.amber, size: 15),  // Changed to gold
                    //         Icon(Icons.star, color: Colors.amber, size: 15),  // Changed to gold
                    //         Icon(Icons.star_border, color: Colors.amber, size: 15),  // Changed to golds.star,
                    //       ],
                    //     ),
                    //   ],
                    // ),
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
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : lemburDetails.isEmpty
                      ? Center(child: Text("Tidak ada data."))
                      : ListView.builder(
                          itemCount: lemburDetails.length,
                          itemBuilder: (context, index) {
                            final detail = lemburDetails[index];
                            return Card(
                              color: Colors.blue[50],
                              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Jarak antar card
                              elevation: 3, // Efek shadow
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      formatBulan(detail.bulan),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${detail.jumlah} kali lembur",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        // color: Colors.blueAccent,
                                      ),
                                    ),
                                  ],
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