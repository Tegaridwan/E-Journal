import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/user/list_jurnal.dart';

class RiwayatJurnal extends StatefulWidget {
  const RiwayatJurnal({super.key});

  @override
  State<RiwayatJurnal> createState() => _RiwayatJurnalState();
}

class _RiwayatJurnalState extends State<RiwayatJurnal> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueAccent,
        title: Image.asset('images/logo.png', width: 50),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              'Riwayat Jurnal PKL',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins-medium',
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user!.uid)
                    .collection('journals')
                    .orderBy('create_at', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("Error loading journals"),
                    );
                  }
                  var journals = snapshot.data!.docs;

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("Belum ada jurnal yang diinput"),
                    );
                  }

                  print('Total jurnal fetched: ${journals.length}');

                  return ListView.builder(
                    itemCount: journals.length,
                    itemBuilder: (context, index) {
                      var journalData =
                          journals[index].data() as Map<String, dynamic>;
                      String date =
                          journalData['date'] ?? 'Tanggal tidak tersedia';
                      String jurnalText =
                          journalData['jurnal'] ?? 'Keterangan tidak tersedia';
                      String imageUrl = journalData['image_url'] ?? '';

                      // Menampilkan output dalam bentuk ListTile untuk tampilan yang lebih sederhana
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Card(
                          elevation: 10,
                          color: Colors.blueAccent,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      date,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins-medium',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return SingleChildScrollView(
                                              child: AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(1),
                                                ),
                                                title: const Stack(
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    Text(
                                                      'Detail Jurnal',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Poppin-mediun',
                                                          fontSize: 20),
                                                    ),
                                                  ],
                                                ),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    const SizedBox(
                                                      height: 1,
                                                    ),
                                                    const Divider(
                                                      color: Colors.black,
                                                      indent: 5,
                                                      endIndent: 5,
                                                    ),
                                                    Text(
                                                      date,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    const Text(
                                                      'Kegiatan Jurnal: ',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Poppin-Bold'),
                                                    ),
                                                    Text(jurnalText),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    if (imageUrl.isNotEmpty)
                                                      Image.network(
                                                        imageUrl,
                                                      ),
                                                    const SizedBox(
                                                      height: 1,
                                                    ),
                                                    const Divider(
                                                      color: Colors.black,
                                                      indent: 5,
                                                      endIndent: 5,
                                                    ),
                                                    const Text(
                                                      'Catatan Dari PIC :',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Poppin-Bold'),
                                                    ),
                                                    const Text(
                                                      'Input dari admin ',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                    },
                                    icon: const Icon(
                                      Icons.visibility_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                color: Colors.white,
                                indent: 15,
                                endIndent: 15,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Keterangan Jurnal:',
                                      style: TextStyle(
                                        fontFamily: 'Poppins-medium',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      jurnalText,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins-medium',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(
                height: 5), // Add some space between the title and the card
          ],
        ),
      ),
    );
  }
}
