import 'package:flutter/material.dart';

class JurnalPage extends StatelessWidget {
  const JurnalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jurnal'),
      ),
      body: const Center(
        child: Text('Ini adalah halaman Jurnal'),
      ),
    );
  }
}
