import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tadakir/Controller/SingInWithEmailController.dart';
import 'package:tadakir/View/Screens/CreatNewAccount.dart';

class SignInWithEmail extends StatefulWidget {
  const SignInWithEmail({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignInWithEmailState createState() => _SignInWithEmailState();
}

class _SignInWithEmailState extends State<SignInWithEmail> {
  final emailController = TextEditingController();
  //bool isLoading = false; // State to manage loading indicator
  final Singinwithemailcontroller singInWithEmailController =
      Get.put(Singinwithemailcontroller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                // Logo Section
                Image.asset(
                  'assets/images/logo-default.webp',
                  width: 180,
                ),
                const SizedBox(height: 110),

                // Title Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sign in \nyour account',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Experience the thrill of the game with our football ticket booking app! Find, book, and secure your seats in just a few taps',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 232, 232),
                              border: Border.all(
                                color: const Color.fromARGB(255, 255, 0, 0),
                                width: 1,
                              ),
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  bottomLeft: Radius.circular(5)),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Text(
                                "e-mail",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 211, 49, 58),
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color.fromARGB(255, 190, 190, 190),
                                width: 1,
                              ),
                              borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(5),
                                  topRight: Radius.circular(5)),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Text(
                                "phone",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 190, 190, 190),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Email Input Field
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'example@gmail.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: singInWithEmailController.isLoading.value
                          ? null
                          : () => singInWithEmailController.handleSignIn(
                              context, emailController.text.trim().toString()),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color.fromARGB(255, 211, 49, 58),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      child: singInWithEmailController.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Sign Up Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => const CreateNewAccount());
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 211, 49, 58),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
