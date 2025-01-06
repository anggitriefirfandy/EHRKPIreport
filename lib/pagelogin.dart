import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kpi/halamanutama.dart';

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

    // Password visibility state
    bool _isObscure = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to adjust to the keyboard
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Padding to adjust to the keyboard
            return Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20, // Extra bottom padding
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cancel button on the top-left
                    Align(
                      alignment: Alignment.topLeft,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Batalkan', style: TextStyle(color: Color(0xFF007BFF))),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Title of the dialog
                    Text(
                      'Login',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Email field
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

                    // Password field with visibility toggle
                    TextField(
                      controller: passwordController,
                      obscureText: _isObscure, // Toggle this
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            // Update visibility state
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),

                    // Login button
                    ElevatedButton(
                      onPressed: () {
                        // Perform login logic here
                        String email = emailController.text;
                        String password = passwordController.text;

                        // Example login logic, replace with your actual validation
                        if (email == 'akarindo@ehr.co.id' && password == '1234567890') {
                          // Navigate to MainPage if login is successful
                          Navigator.of(context).pop(); // Close the bottom sheet
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                          );
                        } else {
                          // Show error message if login fails
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Invalid email or password')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xFF007BFF),
                        minimumSize: Size(200, 50), // Set a specific width, e.g., 200
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
