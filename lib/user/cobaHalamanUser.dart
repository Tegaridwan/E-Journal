import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/admin/register.dart';
import 'package:myapp/faq.dart';
import 'package:myapp/login.dart';
import 'package:intl/intl.dart';
import 'package:myapp/menuAdmin_page.dart';
import 'dart:io';
import 'package:myapp/user/forgotpassworuser.dart';
import 'package:myapp/user/izin.dart';
import 'package:myapp/user/riwayat.dart';
import 'package:myapp/user/riwayat_izin.dart';
import 'package:myapp/user/routes_home.dart';
import 'package:permission_handler/permission_handler.dart';

class Cobahalamanuser extends StatefulWidget {
  const Cobahalamanuser({super.key});

  @override
  State<Cobahalamanuser> createState() => _CobahalamanuserState();
}

class _CobahalamanuserState extends State<Cobahalamanuser> {
  int _selectedIndex = 0; // To keep track of the selected index
  final User? user = FirebaseAuth.instance.currentUser;

  // List of pages to show based on the selected index
  final List<Widget> _pages = [
    _HomeContent(),
    JurnalContent(),
    NotificationsContent(),
    ProfileContent(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'E-Journal Unipma',
          style: TextStyle(
            fontFamily: 'coco',
            color: Color.fromARGB(255, 240, 240, 240),
            fontSize: 30,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'images/logo.png', // Replace with your image path
              height: 40, // Adjust height as needed
              width: 40, // Adjust width as needed
            ),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      //   backgroundColor: Colors.blueAccent,
      //   selectedItemColor: Colors.blueAccent,
      //   unselectedItemColor: Color(0xFF626262),
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.note),
      //       label: 'Jurnal',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.notifications),
      //       label: 'Notifications',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.account_circle),
      //       label: 'Profile',
      //     ),
      //   ],
      // ),
    bottomNavigationBar: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('notifications').snapshots(),
        builder: (context, snapshot) {
          int notificationCount = 0;
          if (snapshot.hasData) {
            notificationCount = snapshot.data!.docs.length;
          }

          return BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.blueAccent,
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: const Color(0xFF626262),
            items: <BottomNavigationBarItem>[
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.note),
                label: 'Jurnal',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications),
                    if (notificationCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 4,
                            minHeight: 3,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              notificationCount > 99 ? '99+' : notificationCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Notifications',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }
}

// Home Content
class _HomeContent extends StatefulWidget {
  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  // Fungsi untuk memeriksa apakah hari ini sudah absen
  Future<bool> hasAbsenToday() async {
    var today = DateTime.now();
    var startOfToday = DateTime(today.year, today.month, today.day, 0, 0, 0);
    var endOfToday = DateTime(today.year, today.month, today.day, 23, 59, 59);

    var absenQuery = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('absen')
        .where('timestamp', isGreaterThanOrEqualTo: startOfToday)
        .where('timestamp', isLessThanOrEqualTo: endOfToday)
        .get();

    return absenQuery.docs.isNotEmpty;
  }

  //fungsi untuk absen
  Future<void> absen(BuildContext context) async {
    var now = DateTime.now();
    var dayOfweek = now.weekday; //1= senin 7=minggu
    var hourOfDay = now.hour;
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);

    //cek apakah hari ini hari minggu
    if (dayOfweek == 7) {
      _showPopUp(context, 'Absen gagal', 'Minggu libur njir', false);
      return;
    }

    //cek apakah di luar jam absen
    if (hourOfDay < 8 || hourOfDay > 16) {
      _showPopUp(context, 'Absen gagal', 'Anda terlambat', false);
      return;
    }

    //apakah sudah absen
    if (await hasAbsenToday()) {
      _showPopUp(context, 'Absen gagal', 'Anda sudah absen', false);
      return;
    }

    // Fetch user's full name
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();

    if (!userDoc.exists) {
      _showPopUp(context, 'Error', 'User data not found', false);
      return;
    }

    Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
    String fullName = data['full_name'] ?? 'Nama tidak ditemukan';

    //simpan absen jika belum absen
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('absen')
        .add({
      'timestamp': now,
      'status': 'hadir',
      'date': formattedDate,
      'full_name': fullName,
    });
    _showPopUp(
        context, 'Absen berhasil', 'Absen anda berhasil disimpan horee', true);
  }

  //pop-up
  void _showPopUp(
      BuildContext context, String title, String message, bool isSucces) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            title: Column(
              children: [
                Icon(
                  isSucces ? Icons.check_circle : Icons.error,
                  color: isSucces ? Colors.blue : Colors.red,
                  size: 60,
                ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Poppin-medium'),
                ),
              ],
            ),
            content: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Poppin-medium', fontSize: 15),
            ),
            actions: [
              Center(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: isSucces ? Colors.blue : Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4))),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.white),
                    )),
              )
              // TextButton(
              //   onPressed: () {
              //     Navigator.of(context).pop();
              //   },
              //   child: Text('OK'),
              // ),
            ],
          );
        });
  }

  void _PopupBerhasil(
      BuildContext context, String title, String message, bool isSucces) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            title: Column(
              children: [
                Icon(
                  isSucces ? Icons.check_circle : Icons.error,
                  color: isSucces ? Colors.blue : Colors.red,
                  size: 60,
                ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Poppin-medium'),
                ),
              ],
            ),
            content: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Poppin-medium', fontSize: 15),
            ),
            actions: [
              Center(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: isSucces ? Colors.blue : Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4))),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.white),
                    )),
              )
              // TextButton(
              //   onPressed: () {
              //     Navigator.of(context).pop();
              //   },
              //   child: Text('OK'),
              // ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Stack(
      children: [
        // Larger box (background)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 200,
          child: Container(
            color: Colors.blueAccent,
            child: const Center(),
          ),
        ),
        // Content Column
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Column(
            children: [
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData && snapshot.data?.data() != null) {
                      Map<String, dynamic> data =
                          snapshot.data!.data() as Map<String, dynamic>;
                      String fullName =
                          data['full_name'] ?? 'Nama tidak ditemukan';
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(10), // Rounded corners
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Selamat datang',
                                style: TextStyle(
                                    color: Color(0xFF7B7777),
                                    fontSize: 18,
                                    fontFamily: 'Poppin-Bold'),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                fullName,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 25,
                                    fontFamily: 'coco'),
                              ),
                              const Divider(thickness: 1.5),
                              const SizedBox(height: 16),
                              // First row of icons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _absenIconWithLabel(context, Icons.person_3,
                                      'Absen', '/absen'),
                                  _izinIconWithLabel(
                                      context, Icons.sick, 'izin', '/izin'),
                                  _riwayatIconWithLabel(context, Icons.history,
                                      'Riwayat', '/riwayat'),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Second row of icons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _adminIconWithLabel(context,
                                      Icons.support_agent, 'CS', '/admin'),
                                  _faqIconWithLabel(
                                      context, Icons.help, 'FAQ', '/info'),
                                  _logoutIconWithLabel(context, Icons.logout,
                                      'Logout', '/logout'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return const Text(
                        'Data tidak ditemukan',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: 'Poppins-medium'),
                      );
                    }
                  } else {
                    // If you don't want to show anything while loading, return an empty container.
                    return Container();
                  }
                },
              ),
              const SizedBox(height: 16), // Space between boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Masuk',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '08.00',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16), // Space between boxes
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pulang',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '16.00',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  //absen
  Widget _absenIconWithLabel(
      BuildContext context, icon, String label, String routes) {
    return GestureDetector(
      onTap: () {
        absen(context);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              size: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _izinIconWithLabel(
    BuildContext context, icon, String label, String routes) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => IzinContent()));
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            size: 30,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget _riwayatIconWithLabel(
    BuildContext context, IconData icon, String label, String routes) {
  return GestureDetector(
    onTap: () {
      // Menampilkan dialog ketika ikon diklik
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            contentPadding: EdgeInsets.zero,
            titlePadding: EdgeInsets.zero,
            title: Stack(
              clipBehavior: Clip
                  .none, // Allows the close button to be placed outside of the bounds
              children: [
                Container(
                  color: Colors.blueAccent,
                  padding: const EdgeInsets.all(16),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Pilih Riwayat',
                          style: TextStyle(
                            fontFamily: 'Poppin-Bold',
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Remove Positioned from here
                    ],
                  ),
                ),
                Positioned(
                  top: -14, // Adjust the distance from the top edge
                  right: -8, // Adjust the distance from the right edge
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle, // Circular shape for the button
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                      },
                    ),
                  ),
                ),
              ],
            ),
            content: Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.history, color: Colors.blueAccent),
                    title: const Text(
                      'Riwayat Jurnal',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Close the dialog
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RiwayatJurnal(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.perm_contact_calendar,
                        color: Colors.blueAccent),
                    title: const Text(
                      'Riwayat Izin',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Close the dialog
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RiwayatIzin(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            size: 30,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget _adminIconWithLabel(
    BuildContext context, icon, String label, String routes) {
  return GestureDetector(
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const Admin()));
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            size: 30,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget _faqIconWithLabel(
    BuildContext context, icon, String label, String routes) {
  return GestureDetector(
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const Faq()));
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            size: 30,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget _logoutIconWithLabel(
    BuildContext context, icon, String label, String routes) {
  return GestureDetector(
    onTap: () async {
      bool? confirmLogout = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.asset(
                      'images/logout.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Apakah Anda Yakin Ingin Logout?",
                    style: TextStyle(
                      fontFamily:
                          'Poppin-medium', // Pastikan nama fontnya benar
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Setelah keluar, Anda harus memasukkan email dan password Anda untuk masuk kembali.",
                    style: TextStyle(
                      fontFamily:
                          'Poppin-medium', // Pastikan nama fontnya benar
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                SizedBox(
                  width: double
                      .infinity, // Memastikan tombol-tombol menggunakan lebar penuh
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Menyelaraskan tombol di tengah
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12), // Menambah padding vertikal
                          ),
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: const Text(
                            "Tidak",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          child: const Text(
                            "Ya",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          });
      if (confirmLogout == true) {
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      }
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            size: 30,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

class JurnalContent extends StatefulWidget {
  const JurnalContent({super.key});

  @override
  State<JurnalContent> createState() => _JurnalContentState();
}

class _JurnalContentState extends State<JurnalContent> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _jurnalController = TextEditingController();
  final ImagePicker _picker = ImagePicker(); // Instance of ImagePicker
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  XFile? _image;
  bool _isLoading = false;
  Future<void> _submitJurnal() async {
    User? user = _auth.currentUser;
    String selectedDate = _dateController.text;

    if (user != null &&
        _image != null &&
        selectedDate.isNotEmpty &&
        _jurnalController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String fullname = userData['full_name'] ?? 'Anonymous';
        int nisn = userData['nisn'] ?? 0000000000;

        // Cek apakah sudah ada entri untuk tanggal yang dipilih
        QuerySnapshot existingEntries = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('journals')
            .where('date', isEqualTo: selectedDate)
            .get();

        if (existingEntries.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Anda sudah mengisi jurnal untuk tanggal ini.'),
          ));
          setState(() {
            _isLoading = false;
          });
          return; // Menghentikan eksekusi jika entri sudah ada
        }

        // Unggah gambar
        String imagePath = 'images/${user.uid}/${DateTime.now()}.jpg';
        Reference ref = _storage.ref().child(imagePath);
        await ref.putFile(File(_image!.path));

        // Dapatkan URL unduhan
        String imageUrl = await ref.getDownloadURL();

        // Simpan jurnal ke database
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('journals')
            .add({
          'user_id': user.uid,
          'date': selectedDate,
          'jurnal': _jurnalController.text,
          'image_url': imageUrl,
          'create_at': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Jurnal berhasil disimpan'),
        ));
        setState(() {
          _isLoading = false;
          _image = null;
          _dateController.clear();
          _jurnalController.clear();
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString()}'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Lengkapi semua data'),
      ));
    }
  }

  // Future<void> _submitJurnal() async {
  //   User? user = _auth.currentUser;

  //   if (user != null &&
  //       _image != null &&
  //       _dateController.text.isNotEmpty &&
  //       _jurnalController.text.isNotEmpty) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     try {
  //       DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(user.uid)
  //           .get();
  //       Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
  //       String fullname = userData['full_name'] ?? 'Anonymous';
  //       int nisn = userData['nisn'] ?? 0000000000;

  //       //upload image
  //       String imagePath = 'images/${user.uid}/${DateTime.now()}.jpg';
  //       Reference ref = _storage.ref().child(imagePath);
  //       await ref.putFile(File(_image!.path));

  //       //Get downlod url
  //       String imageUrl = await ref.getDownloadURL();

  //       //save jurnal ke database
  //       await _firestore
  //           .collection('users')
  //           .doc(user.uid)
  //           .collection('journals')
  //           .add({
  //         'user_id': user.uid,
  //         'date': _dateController.text,
  //         'jurnal': _jurnalController.text,
  //         'image_url': imageUrl,
  //         'create_at': FieldValue.serverTimestamp(),
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text('Jurnal berhasil disimpan'),
  //       ));
  //       setState(() {
  //         _isLoading = false;
  //         _image = null;
  //         _dateController.clear();
  //         _jurnalController.clear();
  //       });
  //     } catch (e) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text('Error: ${e.toString()}'),
  //       ));
  //     } WIB, dan 22.00 WIB
// Selasa: Pukul 09.00 WIB, 12.00 WIB, dan 16
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text('Lengkapi semua data'),
  //     ));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RiwayatJurnal()),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(3),
                ),
                padding: const EdgeInsets.all(5.0),
                margin: const EdgeInsets.only(bottom: 10.0),
                width: double.infinity,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 30, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Riwayat Jurnal',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData && snapshot.data?.data() != null) {
                    Map<String, dynamic> data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    String fullName =
                        data['full_name'] ?? 'Nama tidak ditemukan';
                    int nisn = data['nisn'] ?? 0000000000;
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(232, 230, 230, 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.only(bottom: 10.0),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Nama Siswa :',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide:
                                    const BorderSide(color: Colors.blue, width: 2.0),
                              ),
                              hintText: fullName,
                              hintStyle:
                                  const TextStyle(color: Colors.black, fontSize: 15),
                            ),
                            readOnly: true,
                          ),
                          const SizedBox(height: 5),
                          const Text('NISN :',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              hintText: nisn.toString(),
                              hintStyle:
                                  const TextStyle(color: Colors.black, fontSize: 15),
                            ),
                            readOnly: true,
                          ),
                          const SizedBox(height: 5),
                          const Text('Tanggal :',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          TextFormField(
                            controller: _dateController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              hintText: 'Pilih tanggal',
                              hintStyle:
                                  const TextStyle(color: Colors.black, fontSize: 15),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () => _selectDate(context),
                              ),
                            ),
                            readOnly: true,
                          ),
                          const SizedBox(height: 5),
                          const Text('Jurnal :',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          //untuk menulis keterangan jurnal
                          TextField(
                            controller: _jurnalController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              hintText: 'Jurnal hari ini',
                              hintStyle:
                                  const TextStyle(color: Colors.black, fontSize: 15),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Divider(
                            indent: 15,
                            endIndent: 15,
                            thickness: 1.2,
                            color: Colors.black,
                          ),
                          if (_image ==
                              null) // Only show the button if no image is selected
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                              ),
                              padding: const EdgeInsets.all(16.0),
                              margin: const EdgeInsets.only(bottom: 10.0),
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  //upload gambar
                                  const Text('Upload Bukti',
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed:
                                        _pickImage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      // minimumSize: Size(double.infinity, 35),
                                      elevation: 10,
                                    ), // Call the method to pick image
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.upload,
                                          color: Colors.white,
                                        ),
                                        SizedBox(
                                            width:
                                                8), // Add spacing between icon and text
                                        Text(
                                          "Upload Bukti",
                                          style: TextStyle(color: Colors.white),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_image != null)
                            Stack(
                              children: [
                                Center(
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 10.0),
                                    child: Image.file(
                                      File(_image!.path),
                                      height:
                                          150, // Set desired height for the image
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.cancel, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _image = null; // Clear the image
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 10),
                          Center(
                            //button kirim
                            child: ElevatedButton(
                              onPressed: () {
                                _isLoading ? null : _submitJurnal();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                // minimumSize: size(5, 35),
                                elevation: 10,
                              ), // Call the method to pick image
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.send,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                      width:
                                          8), // Add spacing between icon and text
                                  Text(
                                    "Kirim Jurnal",
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const Text('Data tidak ditemukan',
                        style:
                            TextStyle(color: Colors.blueAccent, fontSize: 15));
                  }
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(currentDate.year - 5),
      lastDate: DateTime(currentDate.year + 5),
    );

    if (selectedDate != null) {
      setState(() {
        _dateController.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage; // Store the picked image
      });
    }
  }
}

// Notifications Content (Placeholder for notifications page)
// class NotificationsContent extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.notifications_none,
//             size: 50,
//             color: Colors.black38,
//           ),
//           SizedBox(height: 20),
//           Text(
//             'Tidak Ada Pemberitahuan Untuk Saat ini',
//             style: TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.bold,
//               color: Colors.black38,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class NotificationsContent extends StatelessWidget {
  const NotificationsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('notifications').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 50,
                  color: Colors.black38,
                ),
                SizedBox(height: 20),
                Text(
                  'Tidak Ada Pemberitahuan Untuk Saat ini',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black38,
                  ),
                ),
              ],
            );
          }

          final notifications = snapshot.data!.docs;
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index].data() as Map<String, dynamic>;
              final Timestamp timestamp = notification['date'] as Timestamp;
              final DateTime date = timestamp.toDate();
              final formattedDate = DateFormat('dd MMM yyyy').format(date);

              return Card(
                elevation: 4, // Shadow effect
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Spacing
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16), // Padding inside the card
                  title: Text(
                    formattedDate,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(notification['message']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
// Profile Content (Placeholder for profile page)

class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  _ProfileContentState createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String? _profileImageUrl;
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController schoolController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  // Load profile image from storage or use default if none exists
  Future<void> _loadProfileImage() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          _profileImageUrl = userDoc.data()?['profile_images_url'];
          phoneController.text = userDoc['phone'] ?? '';
          addressController.text = userDoc['address'] ?? '';
          schoolController.text = userDoc['school'] ?? '';
        });
      }
    }
  }

  Future<void> _uploadImage() async {
    final User? user = _auth.currentUser;
    if (user != null && _profileImage != null) {
      try {
        final storageRef = _storage.ref().child('profile_images/${user.uid}');
        await storageRef.putFile(_profileImage!);
        final downloadUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'profile_images_url': downloadUrl});
        setState(() {
          _profileImageUrl = downloadUrl;
        });
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   content: Text("Profile image uploaded succes!"),
        //   backgroundColor: Colors.green,
        // ));
      } catch (e) {
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   content: Text("Failed to upload image: $e"),
        //   backgroundColor: Colors.red,
        // ));
      }
    }
  }

  Future<void> _updateUserProfile() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'phone': phoneController.text,
          'address': addressController.text,
          'school': schoolController.text
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Profile update succes!"),
          backgroundColor: Colors.green,
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to update profile: $e"),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path); // Update profile image
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Card(
                    color: Colors.blueAccent,
                    elevation: 18,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            ' Profile Prakerin',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontFamily: 'Poppins-medium',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // Handle tap on avatar if needed
                                },
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 55,
                                  backgroundImage: _profileImage != null
                                      ? FileImage(_profileImage!)
                                      : (_profileImageUrl != null
                                          ? NetworkImage(_profileImageUrl!)
                                          : null), // Show profile image or default
                                  child: _profileImage == null &&
                                          _profileImageUrl == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 55,
                                          color: Colors.grey,
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.black),
                                  onPressed: _pickImage,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(user!.uid)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.hasData &&
                                    snapshot.data!.data() != null) {
                                  Map<String, dynamic> data = snapshot.data!
                                      .data() as Map<String, dynamic>;
                                  String fullName = data['full_name'] ??
                                      'Nama tidak ditemukan';
                                  int nisn = data['nisn'] ?? 0000000000;
                                  String email =
                                      data['email'] ?? 'Email tidak ditemukan';
                                  phoneController.text = data['phone'] ?? '';
                                  addressController.text =
                                      data['address'] ?? '';
                                  schoolController.text = data['school'] ?? '';
                                  return Stack(
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            fullName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontFamily: 'Poppins-medium',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            nisn.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontFamily: 'Poppins-medium',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          const Text(
                                            'Edit Profile',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              hintText: fullName,
                                              border: const OutlineInputBorder(),
                                              prefixIcon: const Icon(Icons.person),
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                            readOnly: true,
                                          ),
                                          const SizedBox(height: 16),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              hintText: email,
                                              border: const OutlineInputBorder(),
                                              prefixIcon: const Icon(Icons.email),
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            readOnly: true,
                                          ),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          TextFormField(
                                            controller: schoolController,
                                            decoration: const InputDecoration(
                                              hintText: 'Sekolah',
                                              border: OutlineInputBorder(),
                                              prefixIcon: Icon(Icons.school),
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                            keyboardType:
                                                TextInputType.emailAddress,
                                          ),
                                          const SizedBox(height: 16),
                                          TextFormField(
                                            controller: phoneController,
                                            decoration: const InputDecoration(
                                              hintText: 'No Telephone',
                                              border: OutlineInputBorder(),
                                              prefixIcon: Icon(Icons.phone),
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                            keyboardType: TextInputType.phone,
                                          ),
                                          const SizedBox(height: 16),
                                          TextFormField(
                                            controller: addressController,
                                            decoration: const InputDecoration(
                                              hintText: 'Alamat',
                                              border: OutlineInputBorder(),
                                              prefixIcon: Icon(Icons.home),
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                            maxLines: 3,
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                } else {
                                  return const Text(
                                    'Data tidak ditemukan',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontFamily: 'Poppins-medium'),
                                  );
                                }
                              } else {
                                return const CircularProgressIndicator(
                                  color: Colors.white,
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                // Handle form submission
                                await _updateUserProfile();
                                if (_profileImage != null) {
                                  await _uploadImage();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 10),
                              ),
                              child: const Text(
                                'Simpan Perubahan',
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Register()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                      ),
                      child: const Text(
                        'Reset Password',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        bool? confirmLogout = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                title: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: Image.asset(
                                        'images/logout.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      "Apakah Anda Yakin Ingin Logout?",
                                      style: TextStyle(
                                        fontFamily:
                                            'Poppin-medium', // Pastikan nama fontnya benar
                                        fontSize: 15,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      "Setelah keluar, Anda harus memasukkan email dan password Anda untuk masuk kembali.",
                                      style: TextStyle(
                                        fontFamily:
                                            'Poppin-medium', // Pastikan nama fontnya benar
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                actions: [
                                  SizedBox(
                                    width: double
                                        .infinity, // Memastikan tombol-tombol menggunakan lebar penuh
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center, // Menyelaraskan tombol di tengah
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.blueAccent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              padding: const EdgeInsets.symmetric(
                                                  vertical:
                                                      12), // Menambah padding vertikal
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context, false);
                                            },
                                            child: const Text(
                                              "Tidak",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 12),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context, true);
                                            },
                                            child: const Text(
                                              "Ya",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            });
                        if (confirmLogout == true) {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 17, 0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
