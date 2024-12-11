import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tadakir/Controller/ControllerSharedPrefrances.dart';
import 'package:tadakir/Controller/SingInAndSingOuntController.dart';
import 'package:tadakir/View/Screens/CreatNewAccount.dart';
import 'package:tadakir/View/Screens/SingInWithEmail.dart';

class SinginandSingout extends StatefulWidget {
  const SinginandSingout({super.key});

  @override
  State<SinginandSingout> createState() => _SinginandsingoutState();
}

class _SinginandsingoutState extends State<SinginandSingout> {
  final controllerLanguages = ControllerSharedPreferences();
  final SignInAndSignOutController controller =
      Get.put(SignInAndSignOutController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color.fromARGB(255, 211, 49, 58),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Obx(
                  () => DropdownButton<String>(
                    value: controller.selectedLanguage.value,
                    icon: const Icon(Icons.arrow_drop_down,
                        color: Color.fromARGB(255, 255, 255, 255)),
                    dropdownColor: const Color.fromARGB(255, 211, 49, 58),
                    underline: Container(),
                    items: ["English", "Français", "Arab"]
                        .map(
                          (language) => DropdownMenuItem<String>(
                            value: language,
                            child: Text(
                              language,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.changeLanguage(value);
                      }
                    },
                  ),
                ),
              ),
              const Spacer(flex: 6),
              // Logo
              const Image(
                image: AssetImage('assets/images/logo-modern.webp'),
                width: 200,
              ),
              const Spacer(flex: 6),
              const Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Welcome to Our Goair \nTicket Booking Mobile App",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.white),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Booking with just tap,\nand enjoy your everyday.",
                  style: TextStyle(
                      fontSize: 15, color: Color.fromARGB(255, 241, 238, 238)),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  Get.to(const SignInWithEmail());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color.fromARGB(255, 211, 49, 58),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: const Text(
                  "Sign In",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Get.to(const CreateNewAccount());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 211, 49, 58),
                  side: const BorderSide(color: Colors.white),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: const Text(
                  "Sign Up",
                  style: TextStyle(
                      fontSize: 16, color: Color.fromARGB(255, 255, 255, 255)),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  Get.to(const CreateNewAccount());
                },
                child: const Text.rich(
                  TextSpan(
                    text: "Already have an account? ",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    children: [
                      TextSpan(
                        text: "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(flex: 1), // Space at the bottom
            ],
          ),
        ),
      ),
    );
  }
}
