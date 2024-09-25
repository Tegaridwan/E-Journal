import 'package:flutter/material.dart';
import 'package:myapp/user/riwayat.dart';

class ListJurnal extends StatelessWidget {
  const ListJurnal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B03FF),
        title: Image.asset('images/logo.png', width: 50),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            // Navigate back to RiwayatJurnal when pressing the back button
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const RiwayatJurnal()),
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              'Detail Jurnal PKL',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins-medium',
              ),
            ),
            const  Text(
              'tanggal input jurnal',
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'Poppins-medium',
              ),
            ),
            const SizedBox(height: 5),
            Container(
              width: MediaQuery.of(context).size.width - 20,
              padding: const EdgeInsets.all(5),
              child:  Card(
                elevation: 10,
                color: const Color(0xFF433DF0),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Center(
                          child: Image.asset(
                            'images/logo.png',
                            width: 100,
                          ),
                        ),
                      const  SizedBox(height: 10,),
                      const Padding(
                         padding:  EdgeInsets.all(8.0),
                         child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                              Text('Kegiatan jurnal : ', style: TextStyle(
                                        fontFamily: 'Poppins-medium',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),),
                                        SizedBox(height: 4), // Space between Keterangan Jurnal and its detail
                               Text(
                                'membuat website dengan html dan frameworck tailwind css',
                                style: TextStyle(
                                  fontFamily: 'Poppins-medium',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                           ],
                         )
                       ),
                       const Divider(indent: 5, endIndent: 5, thickness: 3,color: Colors.white,),
                      const Padding(
                         padding:  EdgeInsets.all(8.0),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text('Catatan Dari TIC :', style: TextStyle(
                                              fontFamily: 'Poppins-medium',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),),
                             Text(
                                'Belajar yang semangat',
                                style: TextStyle(
                                  fontFamily: 'Poppins-medium',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),                
                           ],
                         ),
                       ),
                      ],
                    ),
                      ],
                    ),
                  
                ),
              ),
          ],
        ),
      ),
    );
  }
}
