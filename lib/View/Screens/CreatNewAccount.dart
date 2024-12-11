import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:tadakir/Controller/API.dart';
import 'package:tadakir/Controller/ControllerSharedPrefrances.dart';
import 'package:tadakir/Controller/CreateNewAccountController.dart';
import 'package:tadakir/View/InputText/BuildTextInput.dart';
import 'package:tadakir/View/Screens/SingInWithEmail.dart';
import 'package:tadakir/View/SnackBar/SnackBarView.dart';

class CreateNewAccount extends StatefulWidget {
  const CreateNewAccount({super.key});

  @override
  State<CreateNewAccount> createState() => _CreateNewAccountState();
}

class _CreateNewAccountState extends State<CreateNewAccount> {
  final firstName = TextEditingController();
  final secondName = TextEditingController();
  final cin = TextEditingController();
  final city = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final dateOfBirth = TextEditingController();

  final TextEditingController _dateNaissanceController =
      TextEditingController();

  final creatNewAccountCountroller = CreateNewAccountController();

  final bTextInput = BuildTextInput();
  final snackBar = SnackBarViewr();

  final ctrSharedPrefrances = ControllerSharedPreferences();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              const Text(
                'Create new\nyour account',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // Subtitle Section
              const Text(
                'Experience the world at your fingertips with our ticket booking mobile app!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              // Form Fields
              bTextInput.buildInputField(
                  'First Name', 'Clifton Simmons', firstName),
              const SizedBox(height: 10),
              bTextInput.buildInputField('Second Name', 'Simmons', secondName),
              const SizedBox(height: 10),
              bTextInput.buildInputField('CIN', '########', cin),
              const SizedBox(height: 10),
              bTextInput.buildInputField('City', 'Rabat', city),
              const SizedBox(height: 10),
              bTextInput.buildInputField('Phone', '+212 678 663 557', phone),
              const SizedBox(height: 10),
              TextField(
                controller: _dateNaissanceController,
                readOnly: true, // Prevent manual input
                decoration: InputDecoration(
                  labelText: "Date de Naissance",
                  hintText: "YYYY-MM-DD",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );

                      if (pickedDate != null) {
                        String formattedDate =
                            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                        setState(() {
                          _dateNaissanceController.text = formattedDate;
                        });
                      }
                    },
                  ),
                  enabledBorder: const UnderlineInputBorder(),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 146, 23, 23)),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              bTextInput.buildInputField(
                  'e-mail', 'moustajil.dev@gmail.com', email),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    "Sex:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      Obx(() {
                        return Checkbox(
                          value: creatNewAccountCountroller.isMale.value,
                          onChanged: (value) {
                            if (value == true) {
                              creatNewAccountCountroller.isMale.value = true;
                              creatNewAccountCountroller.isFemale.value = false;
                            } else {
                              creatNewAccountCountroller.isMale.value = false;
                            }
                            creatNewAccountCountroller;
                          },
                        );
                      }),
                      const Text("Male"),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      Obx(() {
                        return Checkbox(
                          value: creatNewAccountCountroller.isFemale.value,
                          onChanged: (value) {
                            if (value == true) {
                              creatNewAccountCountroller.isFemale.value = true;
                              creatNewAccountCountroller.isMale.value = false;
                            } else {
                              creatNewAccountCountroller.isFemale.value = false;
                            }
                            creatNewAccountCountroller;
                          },
                        );
                      }),
                      const Text("Female"),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Obx(
                        () {
                          return Checkbox(
                            value: creatNewAccountCountroller.cndpBool.value,
                            onChanged: (value) {
                              creatNewAccountCountroller.cndpBool.value =
                                  value ?? true;
                              creatNewAccountCountroller.getValueCndp();
                            },
                          );
                        },
                      ),
                      const Text("I accept the Terms and Conditions"),
                    ],
                  ),
                  Row(
                    children: [
                      Obx(
                        () {
                          return Checkbox(
                            value: creatNewAccountCountroller.trmBool.value,
                            onChanged: (value) {
                              creatNewAccountCountroller.trmBool.value =
                                  value ?? true;
                              creatNewAccountCountroller.getValuetrm();
                            },
                          );
                        },
                      ),
                      const Text(
                        "CNDP",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: Obx(() {
                  return ElevatedButton(
                    onPressed: () {
                      sendEmailForRegistration(
                        context,
                        email.text.trim(),
                      );
                      creatNewAccountCountroller
                          .ShowDialogForSendInformationOfUSer(
                        context,
                        firstName.text.trim(),
                        secondName.text.trim(),
                        dateOfBirth.text.trim(),
                        phone.text.trim(),
                        cin.text.trim(),
                        city.text.trim(),
                        email.text.trim(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Button background color
                      foregroundColor: Colors.white, // Text and icon color
                      padding: const EdgeInsets.symmetric(
                          vertical: 12), // Adjust button padding
                    ),
                    child: creatNewAccountCountroller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white, // Spinner color
                              strokeWidth: 1,
                            ),
                          )
                        : const Text(
                            'Send OTP',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors
                                  .white, // Explicit text color (optional)
                            ),
                          ),
                  );
                }),
              ),

              const SizedBox(height: 10),
              const SizedBox(height: 20),
              // // Sign In Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account?',
                    style: TextStyle(fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.off(const SignInWithEmail());
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 146, 23, 23),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
