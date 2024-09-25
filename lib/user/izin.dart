import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/user/cobaHalamanUser.dart';
import 'package:myapp/user/riwayat.dart';
import 'package:myapp/user/riwayat_izin.dart';

class IzinContent extends StatefulWidget {
  const IzinContent({super.key});

  @override
  State<IzinContent> createState() => _IzinContentState();
}

class _IzinContentState extends State<IzinContent> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  XFile? _image;
  bool _isLoading = false;

  Future<void> _submitIzin() async {
    User? user = _auth.currentUser;

    if (user != null &&
        _image != null &&
        _dateController.text.isNotEmpty &&
        _keteranganController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      try {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        String fullName = userData['full_name'] ?? 'Nama tidak ditemukan';
        int nisn = userData['nisn'] ?? 0000000000;

        //upload image
        String imagePath = 'images/${user.uid}/${DateTime.now()}.jpg';
        Reference ref = _storage.ref().child(imagePath);
        await ref.putFile(File(_image!.path));
        String imageUrl = await ref.getDownloadURL();

        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('izin')
            .add({
          'user_id': user.uid,
          'date': _dateController.text,
          'jurnal': _keteranganController.text,
          'image_url': imageUrl,
          'create_at': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Izin berhasil dikirim'),
        ));
        setState(() {
          _isLoading = false;
          _image = null;
          _dateController.clear();
          _keteranganController.clear();
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error:${e.toString()}'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Mohon isi semua field'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Image.asset('images/logo.png', width: 50),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RiwayatIzin()),
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
                        'Riwayat izin',
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
                                  borderSide: const BorderSide(
                                      color: Colors.blue, width: 2.0),
                                ),
                                hintText: fullName,
                                hintStyle: const TextStyle(
                                    color: Colors.black, fontSize: 15),
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
                                hintStyle: const TextStyle(
                                    color: Colors.black, fontSize: 15),
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
                                hintStyle: const TextStyle(
                                    color: Colors.black, fontSize: 15),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: () => _selectDate(context),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text('keterangan izin :',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _keteranganController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                hintText: 'Masukkan keterangan izin',
                                hintStyle: const TextStyle(
                                    color: Colors.black, fontSize: 15),
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
                                    const Text(' Bukti',
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
                                        minimumSize: const Size(double.infinity, 35),
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
                                            style:
                                                TextStyle(color: Colors.white),
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
                                      icon:
                                          const Icon(Icons.cancel, color: Colors.red),
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
                              child: ElevatedButton(
                                onPressed: () {
                                  _isLoading ? null : _submitIzin();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25)),
                                  minimumSize: const Size(5, 35),
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
                                      "Kirim bukti",
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
                          style: TextStyle(
                              color: Colors.blueAccent, fontSize: 15));
                    }
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
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
