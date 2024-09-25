import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myapp/login.dart';
import 'package:myapp/user/cobaHalamanUser.dart';
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Timer untuk berpindah halaman setelah 4 detik
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Cobahalamanuser()), // Ganti dengan halaman yang ingin dituju
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, //
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'images/logo.png', 
              height: 150.0,
              fit: BoxFit.cover,
            ),
           const SizedBox(height: 20),
            const Text(
              'Selamat datang!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
