import 'package:flutter/material.dart';

class Faq extends StatefulWidget {
  const Faq({super.key});

  @override
  State<Faq> createState() => _FaqState();
}

class _FaqState extends State<Faq> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: <Widget>[
          // Center the FAQ title below the AppBar
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16.0),
            child: const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontFamily: 'Poppin-Bold',
                fontSize: 24.0,
              ),
            ),
          ),
          // Expanded to take the remaining space
          Expanded(
            child: ListView(
              children: <Widget>[
                _buildFaqItem(
                  question: 'Apa itu aplikasi Prakerin UNIPMA?',
                  answer:
                      'Aplikasi Prakerin UNIPMA adalah platform yang dirancang untuk membantu siswa Magang dalam mengelola dan mengikuti program magang. Aplikasi ini menyediakan informasi, jadwal, dan berbagai sumber daya penting terkait program magang.',
                ),
                _buildFaqItem(
                  question:
                      'Apa yang harus saya lakukan jika saya lupa kata sandi akun saya?',
                  answer:
                      'Jika Anda lupa kata sandi, gunakan fitur "Lupa Kata Sandi" di halaman login aplikasi. Ikuti petunjuk untuk mereset kata sandi melalui email yang terdaftar.',
                ),
                _buildFaqItem(
                  question:
                      ' Di mana saya bisa menemukan bantuan tambahan jika pertanyaan saya tidak terjawab di sini?',
                  answer:
                      'Jika Anda tidak menemukan jawaban yang Anda butuhkan, Anda bisa menghubungi tim dukungan melalui fitur chat pribadi yang ada dimenu cs di aplikasi, mengirimkan email ke prakerinunipma@gmail.com, atau mengunjungi UPt Komputer di Universitas PGRI Madiun.',
                ),
                _buildFaqItem(
                  question:
                      'Bagaimana cara mengetahui informasi terbaru tentang program magang?',
                  answer:
                      ' Informasi terbaru tentang program magang dapat ditemukan di bagian Menu Notifikasi di aplikasi. Pastikan Anda memeriksa secara berkala untuk tetap mendapatkan informasi terbaru.',
                ),
                // Add more FAQ items here
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontFamily: 'Poppin-mediun'),),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(answer),
        ),
      ],
    );
  }
}
