
import 'package:bill_split/home_page.dart';
import 'package:bill_split/login_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  Color buttoncolor = Colors.black;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 224, 186, 235),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 67, 33, 83),
        title: const Text(
          "NexSplit",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),
            child: Container(
  padding: const EdgeInsets.all(25),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.3),
    borderRadius: BorderRadius.circular(20),
  ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(25),
  margin: const EdgeInsets.only(bottom: 25),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.3),
    borderRadius: BorderRadius.circular(20),
  ),
  child: const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "NexSplit",
        style: TextStyle(
          fontSize: 35,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 101, 19, 163)
        ),
      ),

      SizedBox(height: 15),

      Text(
        "Never argue over shared expenses again.",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color.fromARGB(255, 171, 92, 190)
        ),
      ),

      SizedBox(height: 10),

      Text(
        "NexSplit helps friends, roommates and travel groups split expenses fairly and instantly.",
      ),

      SizedBox(height: 15),

      Text("✓ Add Friends"),
      Text("✓ Track who paid what"),
      Text("✓ Automatic bill splitting"),
      Text("✓ Instant settlement summary"),
      Text("✓ Paid? Mark as Done"),
    ],
  ),
),

                  const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: "Name",
                      filled: true,
                      fillColor: const Color.fromARGB(255, 255, 249, 249),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: "Email",
                      filled: true,
                      fillColor: const Color.fromARGB(255, 255, 249, 249),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: "Password",
                      filled: true,
                      fillColor: const Color.fromARGB(255, 255, 249, 249),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          buttoncolor =
                              const Color.fromARGB(255, 95, 98, 91);
                        });

                        if (nameController.text.trim().isEmpty ||
                            emailController.text.trim().isEmpty ||
                            passwordController.text.trim().isEmpty) {
                          setState(() {
                            buttoncolor = Colors.black;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill all fields"),
                            ),
                          );
                          return;
                        }

                        try {
                          UserCredential userCredential =
                              await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );

                          await FirebaseFirestore.instance
                              .collection("users")
                              .doc(userCredential.user!.uid)
                              .set({
                            "name": nameController.text.trim(),
                            "email": emailController.text.trim(),
                          });

                          if (!mounted) return;

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                          );
                        } on FirebaseAuthException catch (e) {
                          String message = "Signup failed";

                          if (e.code == 'email-already-in-use') {
                            message = "Email already exists";
                          } else if (e.code == 'weak-password') {
                            message = "Password is too weak";
                          } else if (e.code == 'invalid-email') {
                            message = "Invalid email";
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(message)),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Something went wrong"),
                            ),
                          );
                        }

                        if (mounted) {
                          setState(() {
                            buttoncolor = Colors.black;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttoncolor,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Already have an account? Login",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),),
    );
  }
}

