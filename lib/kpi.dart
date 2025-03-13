import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // for the line chart
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:ehr_report/api/api.dart';
import 'package:ehr_report/widget/widgetkpi.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'widget/pertumbuhankinerja.dart'; // for circular indicators

class KPIPage extends StatefulWidget {
  const KPIPage({Key? key}) : super(key: key);

  @override
  _KPIPageState createState() => _KPIPageState();
}

class _KPIPageState extends State<KPIPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  


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
    // IconButton(
    //   icon: const Icon(Icons.search, color: Colors.white),
    //   onPressed: () {
    //     // Define search action here
    //   },
    // ),
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

class IndividuTab extends StatefulWidget {
  const IndividuTab({Key? key}) : super(key: key);
  

  @override
  _IndividuTabState createState() => _IndividuTabState();
}
class IndividuData {
  final String pegawaiId;
  final String nama_pegawai;
  final String jabatan;
  final String profil;
  final String usia;
  final String nip;
  final String kantor_cabang;

  IndividuData({
    required this.pegawaiId,
    required this.nama_pegawai,
    required this.jabatan,
    required this.profil,
    required this.usia,
    required this.nip,
    required this.kantor_cabang,
  });

  factory IndividuData.fromJson(Map<String, dynamic> json) {
    return IndividuData(
      pegawaiId: json['pegawai_id'] ?? '',
      nama_pegawai: json['nama_pegawai'] ?? '',
      jabatan: json['jabatan'] ?? '',
      profil: json['profil'] ?? '',
      usia: json['usia'] != null ? json['usia'].toString() : '0',
      nip: json['nip'] != null ? json['nip'].toString() : '',
      kantor_cabang: json['kantor_cabang'] ?? '',
    );
  }
}
class _IndividuTabState extends State<IndividuTab> {
  // final _formSearch = GlobalKey<FormBuilderState>();
  List<IndividuData> individuDataList = [];
  bool isLoading = true;
  String search = "";
  Timer? _debounce;
  List<IndividuData> allIndividuData = [];
  List<IndividuData> filteredIndividuData = [];
  List<IndividuData> paginatedIndividuData = [];
  int currentPage = 1;
  final int itemsPerPage = 10; // Jumlah data per halaman
  int totalPages = 1;
  @override
  void initState() {
    super.initState();
    fetchIndividuData();
  }

  Future<void> fetchIndividuData({String? query}) async {
    try {
      setState(() {
        isLoading = true;
      });

      String url = '/kpireport';
      if (query != null && query.isNotEmpty) {
        url += '?search=$query';
      }

      var dat = await ApiHandler().getData(url);
      debugPrint('API Response Status Code: ${dat.statusCode}');

      if (dat.statusCode == 200 && dat.body != null) {
        final dynamic jsonResponse = jsonDecode(dat.body);
        List<dynamic> data = jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('data')
            ? jsonResponse['data']
            : (jsonResponse is List ? jsonResponse : []);
            final branchSet = <String>{'Semua Cabang'};
              for (var item in data) {
                var kpiData = IndividuData.fromJson(item); // Konversi dari Map ke Object
                if (kpiData.kantor_cabang != null && kpiData.kantor_cabang!.trim().isNotEmpty) {
                  branchSet.add(kpiData.kantor_cabang!);
                }
              }

        setState(() {
          individuDataList = data.map((item) => IndividuData.fromJson(item)).toList();
          filteredIndividuData = List.from(individuDataList);

          // Update daftar branches, pastikan tidak ada nilai kosong atau duplikat
          branches = branchSet.where((branch) => branch.isNotEmpty).toList();

          // **Jika selectedBranch saat ini tidak ada dalam daftar baru, reset ke 'Semua Cabang'**
          if (!branches.contains(selectedBranch)) {
            selectedBranch = 'Semua Cabang';
          }
          // **Tambahkan perhitungan total halaman di sini**
          totalPages = (filteredIndividuData.length / itemsPerPage).ceil();

          isLoading = false;
          updatePaginatedData();
        });

      } else {
        throw Exception('Failed to fetch data');
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
    setState(() {
      search = value;

      // Pencarian hanya di cabang yang sudah difilter sebelumnya
      filteredIndividuData = individuDataList.where((item) {
        bool matchesBranch = selectedBranch == 'Semua Cabang' || 
          item.kantor_cabang.trim().toLowerCase() == selectedBranch.trim().toLowerCase();
        
        bool matchesSearch = item.nama_pegawai.toLowerCase().contains(value.toLowerCase());
        
        return matchesBranch && matchesSearch;
      }).toList();

      currentPage = 1;
      totalPages = (filteredIndividuData.length / itemsPerPage).ceil();
      updatePaginatedData();
    });

    debugPrint('Search Query: $value');
    debugPrint('Filtered Data Count: ${filteredIndividuData.length}');
  });
}


  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
  String selectedBranch = 'Semua Cabang';
  List<String> branches = ['Semua Cabang'];
  void applyFilter() {
  setState(() {
    filteredIndividuData = individuDataList.where((leave) {
      String cleanedBranch = leave.kantor_cabang.trim().toLowerCase();
      String cleanedSelectedBranch = selectedBranch.trim().toLowerCase();

      bool matchesBranch = selectedBranch == 'Semua Cabang' || cleanedBranch == cleanedSelectedBranch;
      return matchesBranch;
    }).toList();

    // **Cek apakah selectedBranch masih ada dalam branches terbaru**
    if (!branches.contains(selectedBranch)) {
      selectedBranch = 'Semua Cabang'; // Reset ke default jika tidak ditemukan
    }

    currentPage = 1; // Reset ke halaman pertama setelah filter diubah
    totalPages = (filteredIndividuData.length / itemsPerPage).ceil();
    updatePaginatedData();
  });

  debugPrint('Selected Branch: $selectedBranch');
  debugPrint('Filtered Data Count: ${filteredIndividuData.length}');
}



  void updatePaginatedData() {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;

    setState(() {
      paginatedIndividuData =
          filteredIndividuData.sublist(startIndex, endIndex.clamp(0, filteredIndividuData.length));
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
          children: [
            Padding(padding: EdgeInsets.all(10),
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
                SizedBox(width: 10,),
                Expanded(
                  child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: TextField(
                  onChanged: _onSearchChanged, // Panggil otomatis saat mengetik
                  decoration: InputDecoration(
                    labelText: "Masukan Nama",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                   
                  ),
                                ),
                              ),
                ),
              ],
            ),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(bottom: 10),
            //   child: TextField(
            //     onChanged: _onSearchChanged, // Panggil otomatis saat mengetik
            //     decoration: InputDecoration(
            //       labelText: "Search berdasarkan nama",
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(15.0),
            //       ),
            //       suffixIcon: Icon(Icons.search),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : individuDataList.isEmpty
                      ? const Center(child: Text('No data found.'))
                      : ListView.builder(
                        itemCount: paginatedIndividuData.length, // Gunakan data yang sudah difilter dan dipaginasi
                        itemBuilder: (context, index) {
                          final individu = paginatedIndividuData[index];
                          return IndividuCard(individu: individu);
                        },
                      )

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

class IndividuCard extends StatelessWidget {
  final IndividuData individu;

  const IndividuCard({Key? key, required this.individu}) : super(key: key);

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailKPIPage(pegawaiId: individu.pegawaiId),
                    ),
                  );
                },

                // onTap: () async {
                //   String apiUrl = '/detailkpireport/${individu.pegawai_id}';
                  
                //   try {
                //     var response = await ApiHandler().getData(apiUrl);
                //     debugPrint('API Response Status Code detail: ${response.statusCode}');
                //     debugPrint('API Response Body detail: ${response.body}');
                    
                //     if (response.statusCode == 200) {
                //       var jsonResponse = jsonDecode(response.body);
                //       debugPrint('Detail KPI Data: $jsonResponse');
                //     } else {
                //       debugPrint('Gagal mengambil data KPI detail');
                //     }
                //   } catch (e) {
                //     debugPrint('Error: $e');
                //   }
                // },
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
                          image: individu.profil.isNotEmpty &&
                                  Uri.tryParse(individu.profil)?.hasAbsolutePath ==
                                      true
                              ? NetworkImage(individu.profil)
                              : const AssetImage('assets/images/default.jpg')
                                  as ImageProvider,
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
                            individu.nama_pegawai,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            individu.jabatan,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'NIP: ${individu.nip}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Kantor: ${individu.kantor_cabang}',
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

class DetailKpiData {
  final String pegawaiId;
  final String nama;
  final String profil;
  final String nip;
  final String jabatan_pegawai;
  final String kantor_cabang_pegawai;
  final double skor;

  DetailKpiData({
    required this.pegawaiId,
    required this.nama,
    required this.profil,
    required this.nip,
    required this.jabatan_pegawai,
    required this.kantor_cabang_pegawai,
    required this.skor,
  });

  factory DetailKpiData.fromJson(Map<String, dynamic> json) {
  var pegawai = json['pegawai'] ?? {};
  var kpiDetail = (json['kpi_detail'] as List?)?.isNotEmpty == true
      ? json['kpi_detail'][0]
      : {}; // Ambil data pertama dari kpi_detail jika ada

  return DetailKpiData(
    pegawaiId: pegawai['id'] ?? '',
    nama: pegawai['nama'] ?? '',
    nip: pegawai['nip'] ?? '',
    profil: pegawai['profil'] ?? '',
    jabatan_pegawai: pegawai['jabatan_pegawai'] ?? '',
    kantor_cabang_pegawai: pegawai['kantor_cabang_pegawai'] ?? '',
    skor: (kpiDetail['skor'] != null) ? double.tryParse(kpiDetail['skor'].toString()) ?? 0.0 : 0.0,
  );
}

}

class DetailKPIPage extends StatefulWidget {
  final String pegawaiId;

  const DetailKPIPage({Key? key, required this.pegawaiId}) : super(key: key);

  @override
  _DetailKPIPageState createState() => _DetailKPIPageState();
}

class _DetailKPIPageState extends State<DetailKPIPage> {
  DetailKpiData? detailKpiData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetailKpi();
  }

  Future<void> fetchDetailKpi() async {
    String apiUrl = '/detailkpireport/${widget.pegawaiId}';

    try {
      var response = await ApiHandler().getData(apiUrl);
      debugPrint('API Response Status Code: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}', wrapWidth: 1045);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        
        setState(() {
          detailKpiData = DetailKpiData.fromJson(jsonResponse);
          isLoading = false;
        });
      } else {
        debugPrint('Gagal mengambil data KPI detail');
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => isLoading = false);
    }
  }
  
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
            Container(
              width: double.infinity, // Membuat container memenuhi lebar yang tersedia
              height: 150, // Mengatur tinggi container
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
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(40),
                        image: DecorationImage(
                          image: (detailKpiData?.profil ?? '').isNotEmpty &&
                            Uri.tryParse(detailKpiData?.profil ?? '')?.hasAbsolutePath == true
                        ? NetworkImage(detailKpiData!.profil) // Gunakan ! karena sudah dicek null-nya
                        : const AssetImage('assets/images/profile.jpeg') as ImageProvider,
                        fit: BoxFit.cover
                        ),
                      ),
                    ),
                    const SizedBox(width: 20), // Jarak antara teks dan avatar
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:  [
                          Text(
                            '${detailKpiData?.nama ?? ''}',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${detailKpiData?.jabatan_pegawai}',
                            style: TextStyle(color: Color(0xFF007BFF)), // Mengubah warna teks menjadi biru
                          ),
                          Text('NIP: ${detailKpiData?.nip}'),
                          // Text('Usia: ${detailKpiData?.usia} Tahun'),
                          Text('Kantor: ${detailKpiData?.kantor_cabang_pegawai}'),
                          SizedBox(height: 8),
                          
                        ],
                      ),
                    ),
                    
                  ],
                ),
              ),
            ),
            // _buildEmployeeInfo(),
            const SizedBox(height: 20),
            const Divider(thickness: 1, color: Colors.grey), // Divider setelah grafik
            
            // New section for performance growth line chart
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: const Text(
                        'Pertumbuhan Kinerja',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                      ),
                    ),
                    Pertumbuhankinerja(pegawaiId: widget.pegawaiId)
                    ]),
                ),
               
                const SizedBox(height: 12),
                
              ],
            ),
            Widgetkpi(pegawaiId: widget.pegawaiId),

            // _buildKPIIndicators(), // Call to KPI indicators
            const SizedBox(height: 20),
            // const Divider(thickness: 1, color: Colors.grey), // Divider setelah grafik
            // _buildKPIRatios(),
            // const Divider(thickness: 1, color: Colors.grey), // Divider setelah rasio
            const SizedBox(height: 20),
            // _buildLastKPIValue(),
            const SizedBox(height: 20),
            // _buildOpinionSection(),
            // _buildSubmitButton(),
          ],
        ),
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
