import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/faq.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  void _launchWhatsApp(String phone, String message) async {
    final url = 'https://wa.me/$phone?text=${Uri.encodeComponent(message)}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'prakerinunipma@gmail.com',
      query: 'subject=Subject Here&body=Body Here',
    );

    if (await canLaunch(emailUri.toString())) {
      await launch(emailUri.toString());
    } else {
      throw 'Could not launch $emailUri';
    }
  }

  void _launchWhatsAppGroup() async {
    const url = 'https://chat.whatsapp.com/EAjdBTsHwK4CJxq4omNSXZ';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background putih dengan card
          Positioned(
            top: MediaQuery.of(context).size.height *
                0.2, // Posisi mulai card tepat di bawah background biru
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          Card(
                            elevation: 0,
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            margin: const EdgeInsets.symmetric(
                                vertical: 1.0, horizontal: 8.0),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 16.0),
                              leading: const Icon(
                                Icons.help_outline,
                                size: 40,
                              ),
                              title: const Text(
                                'Pertanyaan Umum',
                                style: TextStyle(fontFamily: 'Poppin-Bold'),
                              ),
                              subtitle: const Text(
                                  'Temukan Semua Pertanyaan yang sering diajukan disini'),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Faq()),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 2), // Jarak antar card
                          Card(
                            elevation: 0,
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            margin: const EdgeInsets.symmetric(
                                vertical: 1.0, horizontal: 8.0),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 16.0),
                              leading: const Icon(
                                Icons.message_outlined,
                                size: 40,
                              ),
                              title: const Text(
                                'Bantuan Chat',
                                style: TextStyle(fontFamily: 'Poppin-Bold'),
                              ),
                              subtitle: const Text('Chat Langsung Dengan Admin'),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                _launchWhatsApp('082134953089',
                                    'Halo, saya butuh bantuan.');
                              },
                            ),
                          ),
                          const SizedBox(height: 1), // Jarak antar card
                          Card(
                            elevation: 0,
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            margin: const EdgeInsets.symmetric(
                                vertical: 1.0, horizontal: 8.0),
                            child: InkWell(
                               onTap: _launchWhatsAppGroup,
                              child: const ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 16.0),
                                leading: FaIcon(
                                  FontAwesomeIcons.whatsapp,
                                  size: 40,
                                ),
                                title: Text(
                                  'Grub Prakerin',
                                  style: TextStyle(fontFamily: 'Poppin-Bold'),
                                ),
                                subtitle: Text(
                                    'Gabung Grub Prakerin Untuk Mengetahui Info Terbaru'),
                                trailing: Icon(Icons.arrow_forward_ios),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 2.0, horizontal: 12.0),
                      child: Text(
                        "Sebagai alternatif, Kamu dapat menghubungi kami melalui Whatsapp di 081293190070 atau melalui email di prakerinunipma@gmail.com untuk bantuan lebih lanjut",
                        style: TextStyle(fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 70),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Colors.blueAccent, width: 1),
                              iconColor: const Color(
                                  0xFF4CAF50), // Warna background tombol Whatsapp
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              _launchWhatsApp(
                                  '082134953089', 'Halo, saya butuh bantuan.');
                              // Aksi untuk Whatsapp
                            },
                            icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 20),
                            label: const Text(
                              'Whatsapp',
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ),
                        const SizedBox(width: 50), // Jarak antara tombol
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              iconColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              _launchEmail();
                              // Aksi untuk Email
                            },
                            icon: const Icon(Icons.email, size: 20),
                            label: const Text(
                              'Email',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Background biru
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              color: Colors.blueAccent,
              height: MediaQuery.of(context).size.height * 0.2,
              width: double.infinity, // Lebar penuh
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Butuh Bantuan ?',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Poppin-Bold'),
                    ),
                    SizedBox(height: 8), // Jarak antara teks
                    Text(
                      'Hubungi Kami!',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Poppin-Bold'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
