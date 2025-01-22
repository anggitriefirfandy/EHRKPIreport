import 'dart:convert';
import 'dart:developer';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kpi/api/api.dart';
import 'package:kpi/halamanutama.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  int _constat = 1; // Misalnya, 1 berarti koneksi tersedia
  String _errorMessage = '';

  // Fungsi login
  void _login() async {
    print('mulai login');
    if (_constat == 0) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.infoReverse,
        headerAnimationLoop: false,
        animType: AnimType.bottomSlide,
        title: 'INFO',
        desc: 'Login hanya bisa dilakukan saat indikator koneksi berwarna hijau',
      ).show();
    } else if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        Fluttertoast.showToast(msg: "Email dan password tidak boleh kosong.");
        setState(() {
          _isLoading = false;
        });
        return;
      }

      var data = {'email': email, 'password': password, 'device': 'Mobile EHR'};
      var res = await ApiHandler().authData(data, '/login');
      var body = jsonDecode(res.body);

      if (res.statusCode == 200 && body['success']) {
        SharedPreferences locStor = await SharedPreferences.getInstance();
        locStor.setString('token', jsonEncode(body['token']));
        locStor.setString('user', jsonEncode(body['user']));
        log("Token disimpan: ${body['token']}");

        String? infmsg = body['infomessage']?.toString();
        String? alrmsg = body['alertmessage']?.toString();

        Get.off(() => HomeScreen(
              prevPage: '',
              infoPop: infmsg,
              alertPop: alrmsg,
            ));
      } else {
        String m = body['message'].toString();
        if (m.toLowerCase().contains('server error') ||
            m.toLowerCase().contains('timed out')) {
          m = 'Koneksi Bermasalah';
        }
        AwesomeDialog(
          context: context,
          dialogType: DialogType.infoReverse,
          headerAnimationLoop: false,
          animType: AnimType.bottomSlide,
          title: 'INFO',
          desc: m,
        ).show();
        setState(() {
          _errorMessage = m;
        });
      }

      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background with curved shape
          ClipPath(
            clipper: BackgroundClipper(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              color: Color(0xFF007BFF),
            ),
          ),

          // Logo at the very top
          Positioned(
            top: 300,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 55,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 260),

                  // Illustration without shadow
                  Image.asset(
                    'assets/images/masuk.png',
                    width: 500,
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 100),

                  // Login button
                  ElevatedButton(
                    onPressed: () {
                      // Show the login bottom sheet when the button is pressed
                      _showLoginBottomSheet(context);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF007BFF),
                      minimumSize: Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Login',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Wrap version text in a Container for positioning
                  Expanded(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        'version 0.1',
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to show login bottom sheet
  void _showLoginBottomSheet(BuildContext context) {
  // final TextEditingController emailController = TextEditingController();
  // final TextEditingController passwordController = TextEditingController();

  bool _isObscure = true; // Password visibility state

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Batalkan',
                        style: TextStyle(color: Color(0xFF007BFF)),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Login',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      labelText: 'Email',
                      hintText: 'Example@ehr.co.id',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() {
                          _isObscure = !_isObscure;
                        }),
                      ),
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                  onPressed: _login, // Panggil fungsi login di sini
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF007BFF),
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
}


// Custom clipper for the curved background shape
class BackgroundClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 100);
    var firstControlPoint = Offset(size.width / 2, size.height);
    var firstEndPoint = Offset(size.width, size.height - 100);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}