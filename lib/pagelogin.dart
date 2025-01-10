import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kpi/api/api.dart';
import 'package:kpi/halamanutama.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
                    obscureText: _isObscure,
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
                    onPressed: () async {
                      String email = emailController.text.trim();
                      String password = passwordController.text.trim();

                      if (email.isEmpty || password.isEmpty) {
                        Fluttertoast.showToast(
                          msg: "Email dan password tidak boleh kosong.",
                        );
                        return;
                      }

                      // Tampilkan loading
                      EasyLoading.show(status: 'Loading...');
                       print("Attempting to login with email: $email");

                      try {
                        ApiHandler apiHandler = ApiHandler();
                        var response = await apiHandler.authData(
                          {
                            'email': email,
                            'password': password,
                            'device': 'Mobile EHR',
                          },
                          '/login', // Endpoint API untuk login
                        );

                        // Log response status dan body
                        print("Response Status: ${response.statusCode}");
                        print("Response Body: ${response.body}");

                        // Parsing respons
                        var responseBody = jsonDecode(response.body);
                        if (response.statusCode == 200 &&
                            responseBody['success'] == true) {
                          // Login berhasil
                            print("Login successful");
                            // Mengambil token dari respons API
                            String token = responseBody['token']['token']; // Sesuaikan dengan struktur data yang benar
                            Map<String, dynamic> user = responseBody['user']; // Sesuaikan dengan struktur respons Anda

                            // Simpan token dan data pengguna ke SharedPreferences
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            await prefs.setString('token', token);
                            await prefs.setString('user', jsonEncode(user)); // Simpan data pengguna dalam format JSON
                            

                          EasyLoading.dismiss();
                          Fluttertoast.showToast(msg: "Login berhasil!");

                          // Navigasi ke halaman HomeScreen
                          Navigator.of(context).pop();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(prevPage: '',),
                            ),
                          );
                        } else {
                          print("Login failed: ${responseBody['message']}");
                          EasyLoading.dismiss();
                          Fluttertoast.showToast(
                            msg: responseBody['message'] ??
                                'Login gagal, periksa kredensial Anda.',
                          );
                        }
                      } catch (e) {
                        print("Error during login: $e");
                        EasyLoading.dismiss();
                        Fluttertoast.showToast(
                          msg: 'Terjadi kesalahan: $e',
                        );
                      }
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