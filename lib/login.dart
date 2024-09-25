import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/CustomClipper.dart';
import 'package:myapp/forgotpassword.dart';
import 'package:myapp/user/cobaHalamanUser.dart';
import 'package:myapp/user/student.dart';
import 'package:myapp/admin/teacher.dart';
import 'admin/register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isObscure3 = true;
  bool visible = false;
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          // Hide the keyboard when tapping outside of the text fields
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: CustomPaint(
          painter: CurvedPainter(), // Use your custom painter here
          child: Center(
            child: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('images/logo.png', width: 100),
                    const SizedBox(height: 20),
                    const Text(
                      'Selamat datang di',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Colors.blueAccent,
                        fontFamily: 'Poppins-medium',
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Aplikasi Absensi Prakerin',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.blueAccent,
                        fontFamily: 'Poppins-medium',
                      ),
                    ),
                    const SizedBox(
                        height:
                            30), // Add spacing between the text and the card
                    Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20), // Margin for the card
                      elevation: 8, // Adjust the elevation as needed
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16), // Padding inside the card
                        child: Form(
                          key: _formkey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Form Login',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.blueAccent,
                                  fontFamily: 'Poppins-medium',
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Email Section
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Email Adress',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontFamily: 'Poppins-medium',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  prefixIcon:
                                      const Icon(Icons.email, color: Colors.blue),
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'Email',
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14.0, vertical: 8.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Email cannot be empty";
                                  }
                                  if (!RegExp(
                                          "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                      .hasMatch(value)) {
                                    return "Please enter a valid email";
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (value) {
                                  emailController.text = value!;
                                },
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 20),
                              // Password Section
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Password',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontFamily: 'Poppins-medium',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              TextFormField(
                                controller: passwordController,
                                obscureText: _isObscure3,
                                decoration: InputDecoration(
                                  prefixIcon:
                                      const Icon(Icons.key, color: Colors.blue),
                                  suffixIcon: IconButton(
                                      color: Colors.blue,
                                      icon: Icon(_isObscure3
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                      onPressed: () {
                                        setState(() {
                                          _isObscure3 = !_isObscure3;
                                        });
                                      }),
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: 'Password',
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14.0, vertical: 15.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                validator: (value) {
                                  RegExp regex = RegExp(r'^.{6,}$');
                                  if (value!.isEmpty) {
                                    return "Password cannot be empty";
                                  }
                                  if (!regex.hasMatch(value)) {
                                    return "Please enter a valid password min. 6 characters";
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (value) {
                                  passwordController.text = value!;
                                },
                                keyboardType: TextInputType.text,
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: MaterialButton(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0))),
                                  elevation: 5.0,
                                  height: 40,
                                  onPressed: () {
                                    setState(() {
                                      visible = true;
                                    });
                                    signIn(emailController.text,
                                        passwordController.text);
                                  },
                                  color: Colors.blueAccent,
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Forgotpassword(),
                                  ),
                                ),
                                child: const Text(
                                  'Lupa Password?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blue,
                                    fontFamily: 'Poppins-medium',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void route() {
    User? user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        if (documentSnapshot.get('rool') == "Teacher") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Teacher(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Cobahalamanuser(),
            ),
          );
        }
      } else {
        print('Document does not exist on the database');
      }
    });
  }

  void signIn(String email, String password) async {
    if (_formkey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        route();
      } on FirebaseAuthException catch (e) {
        setState(() {
          visible = false;
        });
        print(e.code);
        // if (e.code == 'user-not-found') {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //       SnackBar(content: Text('No user found for that email.')));
        // } else if (e.code == 'wrong-password') {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text('Incorrect password')),
        //   );
        // } else {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text(e.message.toString())),
        //   );
        // }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(e.code)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

String _getErrorMessage(String errorCode) {
  switch (errorCode) {
    case 'user-not-found':
      return 'Email tidak ditemukan';
    case 'wrong-password':
      return 'Password salah';
    case 'invalid-email':
      return 'Format email salah';
    case 'too-many-requests':
      return 'Terlalu banyak percobaan, coba lagi nanti';
    default:
      return 'Terjadi kesalahan, coba lagi';
  }
}
