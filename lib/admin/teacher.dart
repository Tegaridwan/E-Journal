import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/user/izin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/admin/register.dart';
import 'package:myapp/login.dart';

class Teacher extends StatefulWidget {
  const Teacher({super.key});

  @override
  State<Teacher> createState() => _TeacherState();
}

class _TeacherState extends State<Teacher> {
  int _selectedIndex = 0;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _dateController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Map<String, dynamic>> _attendanceData = [];

  @override
  void initState() {
    super.initState();
    _loadSelectedIndex();
    _dateController.text = _formatDate(_selectedDate);
  }

  Future<void> _loadSelectedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedIndex = prefs.getInt('selectedIndex') ?? 0;
    });
  }

  Future<void> _saveSelectedIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedIndex', index);
  }

// Suggested code may be subject to a license. Learn more: ~LicenseLog:2508817938.
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = _formatDate(_selectedDate);
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _saveSelectedIndex(index); // Save selected index
    Navigator.pop(context); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
        title: const Text(
          "Hai Admin",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
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
                                  backgroundColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
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
                },
              );
              if (confirmLogout == true) {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              }
            },
            icon: const Icon(
              Icons.logout,
            ),
          )
        ],
      ),
      drawer: SizedBox(
        width: 250.0,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      'images/logo.png',
                      fit: BoxFit.contain,
                      height: 100,
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Prakerin UPT Komputer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Halaman Awal'),
                selected: _selectedIndex == 0,
                onTap: () => _onItemTapped(0),
              ),
              ListTile(
                leading: const Icon(Icons.note),
                title: const Text('Jurnal Harian Prakerin'),
                selected: _selectedIndex == 1,
                onTap: () => _onItemTapped(1),
              ),
              ListTile(
                leading: const Icon(Icons.sick),
                title: const Text('Riwayat Izin'),
                selected: _selectedIndex == 5,
                onTap: () => _onItemTapped(5),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Data User'),
                selected: _selectedIndex == 2,
                onTap: () => _onItemTapped(2),
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Tambah User'),
                selected: _selectedIndex == 3,
                onTap: () => _onItemTapped(3),
              ),
              ListTile(
                leading: const Icon(Icons.notification_add_outlined),
                title: const Text('Tambah pemberitahuan'),
                selected: _selectedIndex == 4,
                onTap: () => _onItemTapped(4),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          AdminPage(),
          JournalContent(), // Jurnal Harian Prakerin
          UserDataContent(), // Data User
          AddUserContent(), // Tambah User
          NotifContent(),
          izinContent()
        ],
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Logging out..."),
            ],
          ),
        );
      },
    );
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _dateController = TextEditingController();
  List<Map<String, dynamic>> _attendanceData = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(_selectedDate);
    _fetchAttendanceData(); // Mengambil semua data tanpa filter tanggal
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = _formatDate(_selectedDate);
      });
      _fetchAttendanceData(); // Jika filter tanggal diinginkan, bisa diterapkan lagi di sini
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Future<void> _fetchAttendanceData() async {
    print("Mengambil data users...");
    QuerySnapshot userSnapshot = await _firestore.collection('users').get();
    List<Map<String, dynamic>> attendanceData = [];

    for (var userDoc in userSnapshot.docs) {
      print("Mengambil data absen untuk user: ${userDoc['full_name']}");
      String userId = userDoc.id;

      // Mengambil semua absen tanpa filter tanggal
      QuerySnapshot absenSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('absen')
          .get();

      if (absenSnapshot.docs.isNotEmpty) {
        // Iterasi setiap dokumen absen
        for (var absenDoc in absenSnapshot.docs) {
          attendanceData.add({
            'nama': userDoc['full_name'], // Mengambil nama dari dokumen user
            'nisn': userDoc['nisn'], // Mengambil NISN dari dokumen user
            'status': absenDoc['status'], // Mengambil status dari dokumen absen
          });
        }
      } else {
        // Jika tidak ada absen, tandai sebagai "Tidak hadir"
        attendanceData.add({
          'nama': userDoc['full_name'],
          'nisn': userDoc['nisn'],
          'status': 'Tidak hadir',
        });
      }
    }

    print("Data absen yang berhasil diambil: ${attendanceData.length}");

    setState(() {
      _attendanceData = attendanceData;
    });
  }

  Future<void> _editStatus(int index) async {
    String? newStatus = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String selectedStatus = _attendanceData[index]['status'];
        return AlertDialog(
          title: const Text('Edit Keterangan'),
          content: DropdownButton<String>(
            value: selectedStatus,
            items: ['Hadir', 'Tidak Hadir'].map((String status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                selectedStatus = value!;
              });
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                Navigator.of(context).pop(selectedStatus);
              },
            ),
          ],
        );
      },
    );

    if (newStatus != null) {
      setState(() {
        _attendanceData[index]['status'] = newStatus;
      });
    }
  }

  Future<void> _showEditDialog() async {
    int? selectedIndex = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Siswa untuk Diedit'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_attendanceData.length, (index) {
                return ListTile(
                  title: Text(_attendanceData[index]['nama']),
                  onTap: () {
                    Navigator.of(context).pop(index);
                  },
                );
              }),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    if (selectedIndex != null) {
      _editStatus(selectedIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: const Text(
              'Data Absen Siswa Hari Ini :',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: TextField(
                  controller: _dateController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  readOnly: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: _showEditDialog,
                child: const Text('Edit Data'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Nama')),
                  DataColumn(label: Text('Status')),
                ],
                rows: _attendanceData.map((data) {
                  return DataRow(cells: [
                    DataCell(Text(data['nama'])),
                    DataCell(Text(data['status'])),
                  ]);
                }).toList(),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class JournalContent extends StatefulWidget {
  const JournalContent({super.key});

  @override
  State<JournalContent> createState() => _JournalContentState();
}

class _JournalContentState extends State<JournalContent> {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  DateTime? selectedDate;

  Future<void> _selectedDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2101));

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Jurnal harian Upt Komputer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0))),
              onPressed: () => _selectedDate(context),
              child: Text(
                selectedDate == null
                    ? 'Pilih Tanggal'
                    : ' ${formatDate(selectedDate!)}',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: usersCollection
                  .where('rool', whereIn: ['Siswa', 'Student'])
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var userDocs = snapshot.data!.docs;

                if (userDocs.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada data siswa yang ditemukan.'),
                  );
                }

                return ListView.builder(
                  itemCount: userDocs.length,
                  itemBuilder: (context, index) {
                    var user = userDocs[index];
                    var userData = user.data() as Map<String, dynamic>?;

                    var userName =
                        userData != null && userData.containsKey('full_name')
                            ? userData['full_name']
                            : 'Siswa';

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: selectedDate != null
                                      ? () {
                                          showDialog(
                                            context: context,
                                            barrierDismissible:
                                                true, 
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                content: FutureBuilder<
                                                    QuerySnapshot>(
                                                  future: usersCollection
                                                      .doc(user.id)
                                                      .collection('journals')
                                                      .where('date',
                                                          isEqualTo: formatDate(
                                                              selectedDate!))
                                                      .get(),
                                                  builder:
                                                      (context, subSnapshot) {
                                                    if (!subSnapshot.hasData) {
                                                      return const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      );
                                                    }

                                                    var attendanceRecords =
                                                        subSnapshot.data!.docs;

                                                    if (attendanceRecords
                                                        .isEmpty) {
                                                      return SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const Text(
                                                              'Detail Jurnal',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 20),
                                                            ),
                                                            Text(
                                                              '$userName',
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 20),
                                                            ),
                                                            const Divider(
                                                              color:
                                                                  Colors.black,
                                                              indent: 5,
                                                              endIndent: 5,
                                                            ),
                                                            const Text(
                                                                'Siswa belum menginputkan jurnal'),
                                                            const Divider(
                                                              color:
                                                                  Colors.black,
                                                              indent: 5,
                                                              endIndent: 5,
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }

                                                    var attendance =
                                                        attendanceRecords.first;

                                                    return SingleChildScrollView(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Text(
                                                            'Detail Jurnal',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20),
                                                          ),
                                                          Text(
                                                            '$userName',
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 20),
                                                          ),
                                                          const Divider(
                                                            color: Colors.black,
                                                            indent: 5,
                                                            endIndent: 5,
                                                          ),
                                                          Text(
                                                              '${attendance['date']}'),
                                                          const Text(
                                                              'Kegiatan Jurnal:'),
                                                          Text(
                                                              '${attendance['jurnal']}'),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Image.network(
                                                              '${attendance['image_url']}'),
                                                          const Divider(
                                                            color: Colors.black,
                                                            indent: 5,
                                                            endIndent: 5,
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(); 
                                                    },
                                                    child: const Text('Close'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      : null, 
                                  icon: const Icon(Icons.visibility_outlined),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (selectedDate == null)
                              const Text('Pilih tanggal untuk melihat jurnal')
                            else
                              FutureBuilder<QuerySnapshot>(
                                future: usersCollection
                                    .doc(user.id)
                                    .collection('journals')
                                    .where('date',
                                        isEqualTo: formatDate(selectedDate!))
                                    .get(),
                                builder: (context, subSnapshot) {
                                  if (!subSnapshot.hasData) {
                                    return const Text('Memuat jurnal...');
                                  }

                                  var attendanceRecords =
                                      subSnapshot.data!.docs;

                                  if (attendanceRecords.isEmpty) {
                                    return const Text(
                                        'Siswa belum menginputkan jurnal');
                                  }

                                  var attendance = attendanceRecords.first;

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('${attendance['date']}'),
                                      Text(
                                          '${attendance['jurnal']}'),
                                    ],
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
            ),
          )
        ],
      ),
    );
  }
}


class UserDataContent extends StatefulWidget {
  const UserDataContent({super.key});

  @override
  State<UserDataContent> createState() => _UserDataContentState();
}

class _UserDataContentState extends State<UserDataContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            var users = snapshot.data!.docs;

            return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  var user = users[index].data() as Map<String, dynamic>;
                  String profileImageUrl = user['profile_images_url'] ??
                      'https://example.com/default_profile_image.png'; // URL gambar default
                  String fullName = user['full_name'] ?? 'Nama tidak diisi';
                  String nisn = user['nisn']?.toString() ?? 'NISN tidak diisi';
                  String address = user['address'] ?? 'Alamat tidak diisi';
                  String phone =
                      user['phone'] ?? 'Nomor telepon tidak ditemukan';
                  String rool = user['rool'] ?? '';
                  String school = user['school'] ?? 'Sekolah tidak diisi';
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(profileImageUrl),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(rool),
                            ],
                          ),
                          const SizedBox(
                            width: 15,
                          ),

                          // Text(fullName),
                          // Text(nisn),
                          // Text(school)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Memastikan teks berjajar ke kiri
                              children: [
                                Text(
                                  fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Text(nisn),
                                const SizedBox(height: 4),
                                Text(
                                  phone,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  school,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[
                                        600], // Menambahkan warna teks yang lebih lembut
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  _showDeleteConfirmationDialog(
                                      context, users[index].id);
                                },
                                icon: const Icon(Icons.delete),
                              ),
                              // IconButton(
                              //     onPressed: () {
                              //       showDialog(
                              //           context: context,
                              //           builder: (BuildContext context) {
                              //             return SingleChildScrollView(
                              //               child: AlertDialog(
                              //                 shape: RoundedRectangleBorder(
                              //                   borderRadius: BorderRadius.circular(1)
                              //                 ),
                              //                 content: Column(
                              //                   crossAxisAlignment: CrossAxisAlignment.center,
                              //                   mainAxisSize: MainAxisSize.min,
                              //                   children: [
                              //                     CircleAvatar(
                              //                       backgroundImage: NetworkImage(profileImageUrl),
                              //                     ),
                              //                     Text(fullName),
                              //                     Text(phone),
                              //                     Text(school)
                              //                   ],
                              //                 ),
                              //               ),
                              //             );
                              //           });
                              //     },
                              //     icon: const Icon(Icons.remove_red_eye))
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                });
          }),
    );
  }

  // Fungsi untuk memunculkan dialog konfirmasi
  void _showDeleteConfirmationDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: const Text("Apakah Anda yakin ingin menghapus user ini?"),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
            ),
            TextButton(
              child: const Text("Hapus"),
              onPressed: () {
                // Memanggil fungsi hapus user
                _deleteUser(userId);
                Navigator.of(context).pop(); // Menutup dialog
              },
            ),
          ],
        );
      },
    );
  }

  //fungsi delete user
  void _deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User berhasil dihapus'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus user: $e')),
      );
    }
  }
}

class AddUserContent extends StatefulWidget {
  const AddUserContent({super.key});

  @override
  _AddUserContentState createState() => _AddUserContentState();
}

class _AddUserContentState extends State<AddUserContent> {
  _AddUserContentState();

  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final TextEditingController name = TextEditingController();
  final TextEditingController nisnController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController mobile = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController schoolController = TextEditingController();

  final bool _obscurePassword = true;
  final bool _acceptTerms = false;

  bool showProgress = false;
  bool visible = false;

  bool _isObscure = true;
  bool _isObscure2 = true;
  var options = ['Siswa', 'Admin'];
  var _currentItemSelected = "Siswa";
  var rool = "Siswa";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Tambah User Baru',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: fullNameController,
                  decoration: InputDecoration(
                    hintText: 'Nama Lengkap',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nisnController,
                  decoration: InputDecoration(
                    hintText: 'NIS',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.school),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'NISN tidak boleh kosong';
                    } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'NISN harus terdiri dari 10 digit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return 'Email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    } else if (value.length < 6) {
                      return 'Password harus terdiri dari minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: _isObscure2,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure2 ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure2 = !_isObscure2;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    } else if (value.length < 6) {
                      return 'Password harus terdiri dari minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10.0), // Jarak antara field
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // DropdownButtonFormField
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: Colors.blueGrey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: Colors.black26),
                            ),
                            hintText: 'Please select a role',
                            hintStyle: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          dropdownColor: Colors.white,
                          isDense: true,
                          isExpanded: true,
                          iconEnabledColor: Colors.blue,
                          items: options.map((String dropDownStringItem) {
                            return DropdownMenuItem<String>(
                              value: dropDownStringItem,
                              child: Text(
                                dropDownStringItem,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (newValueSelected) {
                            setState(() {
                              _currentItemSelected = newValueSelected!;
                              rool = newValueSelected;
                            });
                          },
                          value: _currentItemSelected,
                        ),
                        const SizedBox(height: 5), // Space below the dropdown

                        // // Additional form fields or buttons can be added here
                        // ElevatedButton(
                        //   onPressed: () {
                        //     if (_currentItemSelected == null) {
                        //       ScaffoldMessenger.of(context).showSnackBar(
                        //         SnackBar(
                        //           content: Text('Please select a role.'),
                        //           backgroundColor: Colors.red,
                        //         ),
                        //       );
                        //     } else {
                        //       // Handle the form submission or other actions
                        //       ScaffoldMessenger.of(context).showSnackBar(
                        //         SnackBar(
                        //           content: Text(
                        //               'Selected role: $_currentItemSelected'),
                        //           backgroundColor: Colors.green,
                        //         ),
                        //       );
                        //     }
                        //   },
                        //   child: Text('Submit'),
                        // ),
                      ],
                    ),
                  ),
                ),

                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Form(
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: [
                //             Text(
                //               "Rool : ",
                //               style: TextStyle(
                //                 fontSize: 20,
                //                 fontWeight: FontWeight.bold,
                //                 color: Colors.blue,
                //               ),
                //             ),
                //             SizedBox(
                //               width: 200,
                //               child: DropdownButtonFormField<String>(
                //                 decoration: InputDecoration(),
                //                 dropdownColor: Colors.blue[900],
                //                 isDense: true,
                //                 isExpanded: false,
                //                 iconEnabledColor: Colors.blue,
                //                 focusColor: Colors.blue,
                //                 items: options.map((String dropDownStringItem) {
                //                   return DropdownMenuItem<String>(
                //                     value: dropDownStringItem,
                //                     child: Text(
                //                       dropDownStringItem,
                //                       style: TextStyle(
                //                         color: Colors.blue,
                //                         fontWeight: FontWeight.bold,
                //                         fontSize: 20,
                //                       ),
                //                     ),
                //                   );
                //                 }).toList(),
                //                 onChanged: (newValueSelected) {
                //                   setState(() {
                //                     _currentItemSelected = newValueSelected!;
                //                     rool = newValueSelected;
                //                   });
                //                 },
                //                 value: _currentItemSelected,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      minimumSize: const Size(double.infinity, 35),
                      backgroundColor: Colors.blueAccent),
                  onPressed: () {
                    setState(() {
                      showProgress = true;
                    });
                    signUp(emailController.text, passwordController.text, rool);
                  },
                  child: const Text(
                    'Kirim',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void signUp(String email, String password, String rool) async {
    if (_formKey.currentState!.validate()) {
      // Use _formKey here
      try {
        // Proses registrasi Firebase Authentication
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Setelah registrasi berhasil, simpan data ke Firestore
        await postDetailsToFirestore(userCredential.user!, email, rool);

        // Tampilkan dialog peringatan
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Sukses',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              content: Text(
                'Anda berhasil menambahkan user',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup dialog
                    setState(() {
                      showProgress = false;
                    });
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      } catch (e) {
        // Tampilkan error jika registrasi gagal
        print('Error during registration: $e');
      }
    }
  }

  // Fungsi untuk menyimpan data ke Firestore
  Future<void> postDetailsToFirestore(
      User user, String email, String rool) async {
    try {
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

      // Simpan data user ke Firestore
      await firebaseFirestore.collection('users').doc(user.uid).set({
        'email': emailController.text,
        'full_name': fullNameController.text,
        'nisn': int.parse(nisnController.text), // Pastikan nisn adalah angka
        'rool': rool,
      });

      // Membuat koleksi journals untuk pengguna baru
      await firebaseFirestore
          .collection('users')
          .doc(user.uid)
          .collection('journals')
          .add({
        'first_entry': 'Welcome to your journal!',
        'timestamp': DateTime.now(),
        'date': '',
        'jurnal': '',
        'image_url': '',
        'user_id': '',
        'create_at': FieldValue.serverTimestamp()
      });

      // membuat koleksi izin
      await firebaseFirestore
          .collection('users')
          .doc(user.uid)
          .collection('izin')
          .add({
        'first_entry': 'Welcome to your journal!',
        'timestamp': DateTime.now(),
        'date': '',
        'alasan': '',
        'image_url': '',
        'user_id': '',
        'create_at': FieldValue.serverTimestamp()
      });

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Sukses',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              content: Text(
                'pendaftaran berhasil',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        showProgress = false;
                        name.clear();
                        emailController.clear();
                        nisnController.clear();
                        passwordController.clear();
                        confirmPasswordController.clear();
                        fullNameController.clear();
                      });
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ))
              ],
            );
          });
    } catch (e) {
      print('Error saving user data: $e');
    }
  }
}

class NotifContent extends StatefulWidget {
  const NotifContent({super.key});

  @override
  _NotifContentState createState() => _NotifContentState();
}

class _NotifContentState extends State<NotifContent> {
  final List<NotificationItem> _notifications = [];
  final bool _hasNotifications = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();

  // void _addNotification(String message) {
  //   setState(() {
  //     _notifications.add(NotificationItem(
  //       message: message,
  //       date: DateTime.now(),
  //     ));
  //     _hasNotifications = true;
  //   });
  // }

  // void _editNotification(int index, String newMessage) {
  //   setState(() {
  //     _notifications[index] =
  //         _notifications[index].copyWith(message: newMessage);
  //   });
  // }

  // void _removeNotification(int index) {
  //   setState(() {
  //     _notifications.removeAt(index);
  //     if (_notifications.isEmpty) {
  //       _hasNotifications = false;
  //     }
  //   });
  // }
  @override
  void dispose() {
    _messageController.dispose(); // Hapus controller saat widget dihancurkan
    super.dispose();
  }

  void _showAddNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          title: const Text('Tambah Pesan'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Pesan'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Pesan tidak boleh kosong';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _addNotificationToFirestore(_messageController.text);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text(
                  'Simpan',
                  style: TextStyle(color: Colors.blue),
                )),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Batal
                },
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Colors.blue),
                ))
          ],
        );
      },
    );
  }

  void _showEditNotificationDialog(
      BuildContext context, String docId, String currentMessage) {
    _messageController.text = currentMessage; //set pesan yang akan di edit
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          title: const Text('Edit Pesan'),
          content: Form(
              key: _formKey,
              child: TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(labelText: 'Pesan'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pesan tidak boleh kosong';
                  }
                  return null;
                },
              )),
          actions: [
            TextButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _editNotificationsInFirestore(
                        docId, _messageController.text);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text(
                  'Simpan',
                  style: TextStyle(color: Colors.blue),
                )),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menambahkan notifikasi ke Firestore
  Future<void> _addNotificationToFirestore(String message) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'message': message,
        'date': DateTime.now(), // Simpan waktu saat notifikasi ditambahkan
      });

      // Tampilkan pesan sukses setelah berhasil ditambahkan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifikasi berhasil ditambahkan')),
      );

      // Kosongkan TextField setelah berhasil menambahkan
      _messageController.clear();
    } catch (e) {
      // Tampilkan pesan error jika gagal
      print("Error: $e"); // Log the error for debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan notifikasi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('notifications').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('Belum ada notifikasi yang ditambahkan.'));
          }

          // Mengonversi dokumen Firestore menjadi objek notifikasi
          List<DocumentSnapshot> docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              String message = data['message'];
              DateTime date = (data['date'] as Timestamp).toDate();
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(message),
                  subtitle:
                      Text('Tanggal: ${DateFormat('yyyy-MM-dd').format(date)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showEditNotificationDialog(context, doc.id, message);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _removeNotification(
                              docs[index].id); // Gunakan ID dari Firestore
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddNotificationDialog(context);
        },
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 45,
        ),
      ),
    );
  }

  // Fungsi untuk menghapus notifikasi dari Firestore
  Future<void> _removeNotification(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifikasi berhasil dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus notifikasi: $e')),
      );
    }
  }

  //fungsi untuk mengedit
  Future<void> _editNotificationsInFirestore(
      String docId, String newMessage) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(docId)
          .update({
        'message': newMessage,
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifikasi berhasil diperbarui')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui notifikasi: $e')));
    }
  }
}

class NotificationItem {
  final String message;
  final DateTime date;

  NotificationItem({required this.message, required this.date});

  NotificationItem copyWith({String? message, DateTime? date}) {
    return NotificationItem(
      message: message ?? this.message,
      date: date ?? this.date,
    );
  }
}

// class AddNotificationForm extends StatefulWidget {
//   final Function(String) onSubmit;
//   final String initialMessage;

//   AddNotificationForm({
//     required this.onSubmit,
//     this.initialMessage = '',
//   });

//   @override
//   _AddNotificationFormState createState() => _AddNotificationFormState();
// }

// class _AddNotificationFormState extends State<AddNotificationForm> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _messageController;

//   @override
//   void initState() {
//     super.initState();
//     _messageController = TextEditingController(text: widget.initialMessage);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextFormField(
//             controller: _messageController,
//             decoration: InputDecoration(labelText: 'Pesan'),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Pesan tidak boleh kosong';
//               }
//               return null;
//             },
//           ),
//           SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: () {
//               if (_formKey.currentState?.validate() ?? false) {
//                 _addNotificationToFirestore(_messageController.text);
//               }
//             },
//             child: Text('Simpan'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Fungsi untuk menambahkan notifikasi ke Firestore
//   Future<void> _addNotificationToFirestore(String message) async {
//     try {
//       await FirebaseFirestore.instance.collection('notifications').add({
//         'message': message,
//         'date': DateTime.now(), // Simpan waktu saat notifikasi ditambahkan
//       });

//       // Tampilkan pesan sukses setelah berhasil ditambahkan
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Notifikasi berhasil ditambahkan')),
//       );

//       // Kosongkan TextField setelah berhasil menambahkan
//       _messageController.clear();
//     } catch (e) {
//       // Tampilkan pesan error jika gagal
//       print("Error: $e"); // Log the error for debugging
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Gagal menambahkan notifikasi: $e')),
//       );
//     }
//   }
// }

// class NotificationItem {
//   final String message;
//   final DateTime date;

//   NotificationItem({required this.message, required this.date});

//   NotificationItem copyWith({String? message}) {
//     return NotificationItem(
//       message: message ?? this.message,
//       date: this.date,
//     );
//   }
// }

// class NotifContent extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Tambah Notifikasi'),
//       ),
//       body: Center(
//         child: Text(
//           'Konten Tambah notifikasi',
//           style: TextStyle(fontSize: 20),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _showAddNotificationDialog(context);
//         },
//         child: Icon(
//           Icons.add,
//           color: Colors.white,
//           size: 45,
//         ),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }

//   void _showAddNotificationDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//           title: Text('Tambah Pesan'),
//           content: AddNotificationForm(),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Batal'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 // You can add functionality to save the notification here
//                 Navigator.of(context).pop();
//               },
//               child: Text('Simpan'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// class AddNotificationForm extends StatefulWidget {
//   @override
//   _AddNotificationFormState createState() => _AddNotificationFormState();
// }

// class _AddNotificationFormState extends State<AddNotificationForm> {
//   final _formKey = GlobalKey<FormState>();
//   final _messageController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextFormField(
//             controller: _messageController,
//             decoration: InputDecoration(labelText: 'Pesan'),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Pesan tidak boleh kosong';
//               }
//               return null;
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  DateTime? selectedDate; // To store the selected date

  // Function to pick a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020), // You can set the range
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Format date to match the format in Firestore (YYYY-MM-DD)
  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Status Absen Siswa Prakerin',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Button to pick a date
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => _selectDate(context),
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              )),
              child: Text(
                selectedDate == null
                    ? 'Pilih Tanggal'
                    : '${formatDate(selectedDate!)}',
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          ),

          // Display the list of users and attendance based on selected date
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Filter hanya untuk pengguna dengan role siswa atau student
              stream: usersCollection
                  .where('rool', whereIn: ['Siswa', 'Student'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var userDocs = snapshot.data!.docs;

                if (userDocs.isEmpty) {
                  return const Center(
                    child: Text('Tidak ada data siswa yang ditemukan.'),
                  );
                }

                return ListView.builder(
                  itemCount: userDocs.length,
                  itemBuilder: (context, index) {
                    var user = userDocs[index];
                    var userData = user.data() as Map<String, dynamic>?;

                    // Safely check if 'full_name' exists
                    var userName =
                        userData != null && userData.containsKey('full_name')
                            ? userData['full_name']
                            : 'Admin';

                    // Check for selected date
                    if (selectedDate == null) {
                      return ListTile(
                        title: Text(userName),
                        subtitle: const Text(
                            'Pilih tanggal untuk melihat status siswa'),
                      );
                    }

                    // Fetch attendance records for the selected date
                    return FutureBuilder<QuerySnapshot>(
                      future: usersCollection
                          .doc(user.id)
                          .collection('absen')
                          .where('date', isEqualTo: formatDate(selectedDate!))
                          .get(),
                      builder: (context, subSnapshot) {
                        if (!subSnapshot.hasData) {
                          return ListTile(
                            title: Text(userName),
                            subtitle: const Text('Loading attendance...'),
                          );
                        }

                        var attendanceRecords = subSnapshot.data!.docs;

                        if (attendanceRecords.isEmpty) {
                          return ListTile(
                            title: Text(userName),
                            subtitle: const Text('Status: Siswa belum hadir'),
                          );
                        }

                        var attendance = attendanceRecords.first;

                        return ListTile(
                          title: Text(userName),
                          subtitle: Text(
                              'Status: ${attendance['status']}, Date: ${attendance['date']}'),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class izinContent extends StatefulWidget {
  const izinContent({super.key});

  @override
  State<izinContent> createState() => _izinContentState();
}

class _izinContentState extends State<izinContent> {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  DateTime? selectedDate;

  Future<void> _selectedDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2101));

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Riwayat Izin', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0))),
              onPressed: () => _selectedDate(context),
              child: Text(
                selectedDate == null
                    ? 'Pilih Tanggal'
                    : '${formatDate(selectedDate!)}',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  // Menampilkan hanya pengguna dengan role 'siswa' atau 'student'
                  stream: usersCollection
                      .where('rool', whereIn: ['Siswa', 'Student'])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    var userDocs = snapshot.data!.docs;

                    if (userDocs.isEmpty) {
                      return const Center(
                        child: Text('Tidak ada data siswa yang ditemukan.'),
                      );
                    }

                    return ListView.builder(
                        itemCount: userDocs.length,
                        itemBuilder: (context, index) {
                          var user = userDocs[index];
                          var userData = user.data() as Map<String, dynamic>?;
                          var userName = userData != null &&
                                  userData.containsKey('full_name')
                              ? userData['full_name']
                              : 'Admin';

                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        userName,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: selectedDate != null
                                            ? () {
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible:
                                                      true, // Menutup dialog ketika mengklik di luar
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      content: FutureBuilder<
                                                          QuerySnapshot>(
                                                        future: usersCollection
                                                            .doc(user.id)
                                                            .collection('izin')
                                                            .where('date',
                                                                isEqualTo:
                                                                    formatDate(
                                                                        selectedDate!))
                                                            .get(),
                                                        builder: (context,
                                                            subSnapshot) {
                                                          if (!subSnapshot
                                                              .hasData) {
                                                            return const Center(
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            );
                                                          }

                                                          var attendanceRecords =
                                                              subSnapshot
                                                                  .data!.docs;

                                                          if (attendanceRecords
                                                              .isEmpty) {
                                                            return SingleChildScrollView(
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  const Text(
                                                                    'Detail Izin',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            20),
                                                                  ),
                                                                  Text(
                                                                    '$userName',
                                                                    style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            20),
                                                                  ),
                                                                  const Divider(
                                                                    color: Colors
                                                                        .black,
                                                                    indent: 5,
                                                                    endIndent:
                                                                        5,
                                                                  ),
                                                                  const Text(
                                                                      'Tidak ada Izin'),
                                                                  const Divider(
                                                                    color: Colors
                                                                        .black,
                                                                    indent: 5,
                                                                    endIndent:
                                                                        5,
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          }

                                                          var attendance =
                                                              attendanceRecords
                                                                  .first;

                                                          return SingleChildScrollView(
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                const Text(
                                                                  'Detail Izin',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          20),
                                                                ),
                                                                Text(
                                                                  '$userName',
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          20),
                                                                ),
                                                                const Divider(
                                                                  color: Colors
                                                                      .black,
                                                                  indent: 5,
                                                                  endIndent: 5,
                                                                ),
                                                                Text(
                                                                    '${attendance['date']}'),
                                                                const Text(
                                                                    'Alasan:'),
                                                                Text(
                                                                    '${attendance['jurnal']}'),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Image.network(
                                                                    '${attendance['image_url']}'),
                                                                const Divider(
                                                                  color: Colors
                                                                      .black,
                                                                  indent: 5,
                                                                  endIndent: 5,
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(); // Menutup dialog
                                                          },
                                                          child: const Text(
                                                              'Close'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                            : null, // Set to null untuk menonaktifkan tombol jika tidak ada tanggal yang dipilih
                                        icon: const Icon(
                                            Icons.visibility_outlined),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (selectedDate == null)
                                    const Text(
                                        'Pilih tanggal untuk melihat Izin')
                                  else
                                    FutureBuilder<QuerySnapshot>(
                                      future: usersCollection
                                          .doc(user.id)
                                          .collection('izin')
                                          .where('date',
                                              isEqualTo:
                                                  formatDate(selectedDate!))
                                          .get(),
                                      builder: (context, subSnapshot) {
                                        if (!subSnapshot.hasData) {
                                          return const Text(
                                              'Loading attendance...');
                                        }

                                        var attendanceRecords =
                                            subSnapshot.data!.docs;

                                        if (attendanceRecords.isEmpty) {
                                          return const Text('Tidak ada Izin');
                                        }

                                        var attendance =
                                            attendanceRecords.first;

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('${attendance['date']}'),
                                            Text(
                                                '${attendance['jurnal']}'), // Assuming there's a status field
                                          ],
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          );
                        });
                  }))
        ],
      ),
    );
  }
}
