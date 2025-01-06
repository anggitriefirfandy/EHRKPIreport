import 'package:flutter/material.dart';
import 'package:kpi/cuti.dart';
import 'package:kpi/halamanutama.dart';
import 'package:kpi/pagelogin.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(), // Ensure this is pointing to the right page
    );
  }
}