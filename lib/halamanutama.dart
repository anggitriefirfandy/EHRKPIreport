import 'dart:convert';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kpi/absen.dart';
import 'package:kpi/api/api.dart';
import 'package:kpi/cuti.dart';
import 'package:kpi/elibrary.dart';
import 'package:kpi/exam.dart';
import 'package:kpi/handler/imageNetwork.dart';
import 'package:kpi/kpi.dart';
import 'package:kpi/kunjungan.dart';
import 'package:kpi/lembur.dart';
import 'package:kpi/pagelogin.dart';
import 'package:kpi/widget/widgethalamanutama.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Assumed to have a login page

class HomeScreen extends StatefulWidget {
  const HomeScreen(
    {required this.prevPage, this.alertPop, this.infoPop, super.key});

    final String prevPage;
  final String? alertPop;
  final String? infoPop;
  

  @override
  State<HomeScreen> createState() => _HomeScreenState();
  
  
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> halamanData = [];
  bool isLoading = true;
  int totalPegawai = 0;
  int totalAbsenHariIni = 0;
  int totalTerlambat = 0;
  String _username = '-';
  Image _profimg = Image.asset(
    'assets/images/def_img.png',
    width: 39,
    height: 39,
    fit: BoxFit.fill,
  );
  @override
  void initState() {
    super.initState();
    getuser(); // Panggil fungsi untuk memuat data pengguna
    fetchWidgetkpi();
  }
  Future<void> fetchWidgetkpi() async {
    try {
      setState(() {
        isLoading = true;
      });

      var url = '/widgetdashboardreport';
      var dat = await ApiHandler().getData(url);
      debugPrint('API Response widget Status Code: ${dat.statusCode}');
      debugPrint('API Response widget Body: ${dat.body}');

      if (dat.statusCode == 200 && dat.body != null) {
        final Map<String, dynamic> jsonResponse = jsonDecode(dat.body);

        setState(() {
          totalPegawai = jsonResponse['total_pegawai'] ?? 0;
          totalAbsenHariIni = jsonResponse['total_absen_hari_ini'] ?? 0;
          totalTerlambat = jsonResponse['total_terlambat'] ?? 0;
          isLoading = false;
        });
      } else {
          throw Exception('Invalid data format');
        }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Stack(
            children: [
              // Blue Background with gradient
              Container(
                height: 300, // Height for the blue header
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF007BFF), // Start color
                      Color(0xFF0056b3), // End color
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    // Dashboard Row with Logout Icon on the right
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // IconButton(
                          //   icon: Icon(Icons.refresh, color: Colors.white),
                          //   onPressed: () {
                          //     fetchWidgetkpi(); // Panggil fungsi untuk refresh data
                          //   },
                          // ),
                          const SizedBox(width: 40),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => LoginPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Profile Row
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: ClipRRect(
                           borderRadius: BorderRadius.circular(50),
                           child: Container(
                            width: 39,
                            height: 39,
                            color: Colors.white,
                            child: _profimg,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _username,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        
              // White Container with Rounded Top
              Positioned(
                top: 220,
                left: 0,
                right: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height - 220,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                ),
              ),
        
              // Menu Row Positioned to meet the white container's curve
              Positioned(
                top: 180,
                left: 0,
                right: 0,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Enables horizontal scrolling
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      buildMenuItem('assets/images/kpi.png', 'KPI', KPIPage(), context),
                      buildMenuItem('assets/images/absensi.png', 'Absensi', AbsensiPage(prevPage: '',), context),
                      buildMenuItem('assets/images/cuti.png', 'Cuti', EmployeeLeavePage(prevPage: '',), context),
                      buildMenuItem('assets/images/exam.png', 'Exam', ExamApp(), context), // New menu item,
                      buildMenuItem('assets/images/library.png', 'Elibrary', ElibraryApp(), context),
                      buildMenuItem('assets/images/lembur.png', 'Lembur', LemburPage(prevPage: '',), context),
                      buildMenuItem('assets/images/kunjungan.png', 'Kunjungan', KunjunganScreen(prevPage: '',), context),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
        
              // Performance Growth Section
              Padding(
                padding: const EdgeInsets.only(top: 280),
                child: Column(
                  children: [
                    // Performance Growth Section
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: Icon(Icons.refresh, color: Colors.black),
                            onPressed: () {
                              fetchWidgetkpi(); // Panggil fungsi untuk refresh data
                            },
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              elevation: 4, // Menambahkan shadow
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12), // Membuat sudut melengkung
                              ),
                              color: Colors.blue[100], // Warna latar belakang yang soft
                              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Memberi ruang antar card
                              child: Padding(
                                padding: EdgeInsets.all(20), // Padding agar isi tidak terlalu mepet
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Total Pegawai",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[900], // Warna teks lebih gelap agar kontras
                                      ),
                                    ),
                                    SizedBox(height: 8), // Jarak antar teks
                                    Text(
                                      "$totalPegawai Orang",
                                      style: TextStyle(
                                        fontSize: 24, 
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87, // Warna teks utama
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              elevation: 4, // Menambahkan shadow
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12), // Membuat sudut melengkung
                              ),
                              color: Colors.blue[100], // Warna latar belakang yang soft
                              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Memberi ruang antar card
                              child: Padding(
                                padding: EdgeInsets.all(20), // Padding agar isi tidak terlalu mepet
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Total Absen Hari Ini",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[900], // Warna teks lebih gelap agar kontras
                                      ),
                                    ),
                                    SizedBox(height: 8), // Jarak antar teks
                                    Text(
                                      "$totalAbsenHariIni Orang",
                                      style: TextStyle(
                                        fontSize: 24, 
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87, // Warna teks utama
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              elevation: 4, // Menambahkan shadow
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12), // Membuat sudut melengkung
                              ),
                              color: Colors.blue[100], // Warna latar belakang yang soft
                              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Memberi ruang antar card
                              child: Padding(
                                padding: EdgeInsets.all(20), // Padding agar isi tidak terlalu mepet
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Total Terlambat",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[900], // Warna teks lebih gelap agar kontras
                                      ),
                                    ),
                                    SizedBox(height: 8), // Jarak antar teks
                                    Text(
                                      "$totalTerlambat Orang",
                                      style: TextStyle(
                                        fontSize: 24, 
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87, // Warna teks utama
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
        
                          
                          
                         
                          // const Text(
                          //   'Pertumbuhan Kinerja',
                          //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                          // ),
                          // const SizedBox(height: 12),
                          // SizedBox(
                          //   height: 200,
                          //   child: Padding(
                          //     padding: const EdgeInsets.symmetric(horizontal: 3),
                          //     child: LineChart(
                          //       LineChartData(
                          //         gridData: FlGridData(show: true),
                          //         borderData: FlBorderData(
                          //           show: true,
                          //           border: const Border(
                          //             left: BorderSide(color: Colors.black),
                          //             bottom: BorderSide(color: Colors.black),
                          //             right: BorderSide(color: Colors.black),
                          //             top: BorderSide(color: Colors.transparent),
                          //           ),
                          //         ),
                          //         titlesData: FlTitlesData(
                          //           bottomTitles: AxisTitles(
                          //             sideTitles: SideTitles(
                          //               showTitles: true,
                          //               reservedSize: 28,
                          //               getTitlesWidget: (value, meta) {
                          //                 String text;
                          //                 switch (value.toInt()) {
                          //                   case 0:
                          //                     text = 'Jan';
                          //                     break;
                          //                   case 1:
                          //                     text = 'Feb';
                          //                     break;
                          //                   case 2:
                          //                     text = 'Mar';
                          //                     break;
                          //                   case 3:
                          //                     text = 'Apr';
                          //                     break;
                          //                   case 4:
                          //                     text = 'May';
                          //                     break;
                          //                   case 5:
                          //                     text = 'Jun';
                          //                     break;
                          //                   case 6:
                          //                     text = 'Jul';
                          //                     break;
                          //                   case 7:
                          //                     text = 'Aug';
                          //                     break;
                          //                   case 8:
                          //                     text = 'Sep';
                          //                     break;
                          //                   case 9:
                          //                     text = 'Oct';
                          //                     break;
                          //                   case 10:
                          //                     text = 'Nov';
                          //                     break;
                          //                   case 11:
                          //                     text = 'Dec';
                          //                     break;
                          //                   default:
                          //                     text = '';
                          //                     break;
                          //                 }
                          //                 return SideTitleWidget(
                          //                   axisSide: meta.axisSide,
                          //                   child: Text(text, style: const TextStyle(fontSize: 12)),
                          //                 );
                          //               },
                          //             ),
                          //           ),
                          //           leftTitles: AxisTitles(
                          //             sideTitles: SideTitles(
                          //               showTitles: true,
                          //               reservedSize: 15,
                          //               getTitlesWidget: (value, meta) {
                          //                 if (value % 20 == 0) {
                          //                   return SideTitleWidget(
                          //                     axisSide: meta.axisSide,
                          //                     child: Text(value.toInt().toString(), style: const TextStyle(fontSize: 12)),
                          //                   );
                          //                 }
                          //                 return Container(); // Jika bukan kelipatan 20, tidak ditampilkan
                          //               },
                          //             ),
                          //           ),
                          //         ),
        
                          //         lineBarsData: [
                          //           LineChartBarData(
                          //             spots: [
                          //               FlSpot(0, 0),
                          //               FlSpot(1, 20),
                          //               FlSpot(2, 50),
                          //               FlSpot(3, 10),
                          //               FlSpot(4, 30),
                          //               FlSpot(5, 60),
                          //               FlSpot(6, 20),
                          //               FlSpot(7, 40),
                          //               FlSpot(8, 80),
                          //               FlSpot(9, 80),
                          //               FlSpot(10, 100),
                          //               FlSpot(11, 90),
                          //             ],
                          //             isCurved: true,
                          //             color: Colors.orange,
                          //             barWidth: 3,
                          //           ),
                          //         ],
                          //       )
                          //     ),
                          //   ),
                          // ),
                          // const SizedBox(height: 20),
        
                          // SingleChildScrollView(
                          //   scrollDirection: Axis.horizontal,
                          //   child: Row(
                          //     children: [
                          //       IconButton(
                          //         icon: const Icon(Icons.arrow_back_ios, size: 16),
                          //         onPressed: () {},
                          //       ),
                          //       _buildCircularProgress('Target', 0.25),
                          //       const SizedBox(width: 15),
                          //       _buildCircularProgress('Pengetahuan', 0.25),
                          //       const SizedBox(width: 15),
                          //       _buildCircularProgress('Kepemimpinan', 0.25),
                          //       const SizedBox(width: 15),
                          //       _buildCircularProgress('Kepatuhan', 0.25),
                          //       const SizedBox(width: 15),
                          //       _buildCircularProgress('Kerjasama tim', 0.25),
                          //       IconButton(
                          //         icon: const Icon(Icons.arrow_forward_ios, size: 16),
                          //         onPressed: () {},
                          //       ),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                    ),
        
                    // Ratio Section
                    // Container(
                    //   padding: const EdgeInsets.all(20),
                    //   margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(20),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: Colors.black.withOpacity(0.1),
                    //         spreadRadius: 2,
                    //         blurRadius: 5,
                    //         offset: const Offset(0, 3),
                    //       ),
                    //     ],
                    //   ),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       const Text(
                    //         'Rasio',
                    //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    //       ),
                    //       const SizedBox(height: 10),
                    //       SingleChildScrollView(
                    //         scrollDirection: Axis.horizontal,
                    //         child: Row(
                    //           children: [
                    //             IconButton(
                    //               icon: const Icon(Icons.arrow_back_ios, size: 16),
                    //               onPressed: () {},
                    //             ),
                    //             const SizedBox(width: 10),
                    //             _buildCircularRatio('Rasio Kehadiran', 'Terhadap hari kerja', 0.7),
                    //             const SizedBox(width: 10),
                    //             _buildCircularRatio('Rasio Izin & Cuti', 'Terhadap ketentuan Internal', 0.7),
                    //             const SizedBox(width: 10),
                    //             _buildCircularRatio('Rasio Izin & Cuti', 'Terhadap hari, menit kerja & izin', 0.7),
                    //             const SizedBox(width: 10),
                    //             _buildCircularRatio('Rasio Kinerja', 'Kinerja Pencapaian', 0.7),
                    //             const SizedBox(width: 10),
                    //             IconButton(
                    //               icon: const Icon(Icons.arrow_forward_ios, size: 16),
                    //               onPressed: () {},
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  }

  Widget buildMenuItem(String iconPath, String label, Widget targetPage, BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetPage),
      );
    },
    child: Card(
      elevation: 3, // Memberikan efek shadow pada Card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Membuat sudut rounded untuk Card
      ),
      child: Container(
        width: 65, // Menyesuaikan lebar untuk ikon dan teks
        height: 65, // Menyesuaikan tinggi untuk ikon dan teks
        padding: const EdgeInsets.all(10), // Memberikan padding di dalam Card
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Mengatur konten di tengah
          children: [
            Image.asset(iconPath, width: 30, height: 25, fit: BoxFit.contain), // Ikon
            const SizedBox(height: 5), // Jarak antara ikon dan teks
            Text(
              label,
              style: const TextStyle(
                fontSize: 8, // Ukuran font untuk teks label
                fontWeight: FontWeight.bold, // Memberikan font tebal
              ),
              textAlign: TextAlign.center, // Mengatur teks di tengah
            ),
          ],
        ),
      ),
    ),
  );
}

   // Circular progress builder
  Widget _buildCircularProgress(String label, double progress) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 77,
                height: 77,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  // Circular ratio builder
 Widget _buildCircularRatio(String label, String description, double progress) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 75,
                height: 75,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(fontSize: 8, color: Colors.grey),
          ),
        ],
      ),
    );
  }
  void getuser() async {
    SharedPreferences locStor = await SharedPreferences.getInstance();
    var usr = locStor.getString('user');
    print('Data user dari SharedPreferences: $usr');
    var usrName = '-';
    if (usr != null && usr != '') {
      var usrDec = jsonDecode(usr);
      usrName = usrDec['name'];
      
    }
    var img = await ImageNetwork().getimageprofil();
    if (widget.alertPop != null) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        title: 'PERINGATAN!',
        desc: widget.alertPop,
        btnCancel: null,
        btnOkOnPress: () {},
      ).show();
    }
    if (widget.infoPop != null) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        title: 'INFO!',
        desc: widget.infoPop,
        btnCancel: null,
        btnOkOnPress: () {},
      ).show();
    }
    setState(() {
      // _fab = FloatingButtonAttendance(currentMenu: 'home');
      _profimg = img;
      _username = usrName;
      print('Username updated: $_username');
      print('image updated: $img');
      // _jabatan = usrJabatan;
      // _startTime = st;
      // _endTime = et;
      // _menu = rowmenu;
    });
  }
}
