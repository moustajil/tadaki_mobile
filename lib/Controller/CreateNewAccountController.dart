import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tadakir/Controller/API.dart';
import 'package:tadakir/Controller/ControllerSharedPrefrances.dart';

class CreateNewAccountController extends GetxController {
  final sharedPrefers = ControllerSharedPreferences();
  String baseUrl = "https://preprod.tadakir.net";
  RxString sex = "".obs;
  RxBool isMale = false.obs;
  RxBool isFemale = false.obs;
  RxInt cndp = 0.obs;
  RxInt cgv = 0.obs;
  RxBool cndpBool = false.obs;
  RxBool trmBool = false.obs;
  RxBool isLoading = false.obs;

  void getSexOfPerson() {
    isMale.value = false;
    if (isMale.value) {
      sex.value = "male";
    } else {
      sex.value = "female";
    }
  }

  void getValueCndp() {
    cndpBool.value = true;
    if (cndpBool.value) {
      cndp.value = 1;
    } else {
      cndp.value = 0;
    }
  }

  void getValuetrm() {
    trmBool.value = true;
    if (trmBool.value) {
      cgv.value = 1;
    } else {
      cndp.value = 0;
    }
  }

  // ignore: non_constant_identifier_names
  void ShowDialogForSendInformationOfUSer(
    BuildContext context,
    String firstName,
    String secondName,
    String dateOfBirth,
    String phone,
    String cin,
    String city,
    String email,
  ) {
    var otpController = TextEditingController(); // Controller for OTP input

    // Show a dialog for user information
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dialog from being dismissed by tapping outside
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              15.0), // Add rounded corners for a modern look
        ),
        title: const Text(
          'Enter OTP',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Padding(
          padding: const EdgeInsets.all(16.0), // Add padding for better layout
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please enter the OTP sent to your email: $email',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                decoration: const InputDecoration(
                  labelText: 'OTP',
                  hintText: 'Enter OTP',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12), // Improved padding
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 16), // Font size adjustment
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12), // More padding
              backgroundColor: Colors.grey[200], // Subtle background color
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(8), // Rounded corners for button
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16), // Style the cancel button text
            ),
          ),
          TextButton(
            onPressed: () {
              // Validate OTP and user data
              if (otpController.text.isNotEmpty) {
                // Call a method to submit data (like creating account or verifying OTP)
                createNewAccount(
                  context,
                  firstName,
                  secondName,
                  sex.value,
                  dateOfBirth,
                  phone,
                  cin,
                  city,
                  email,
                  otpController.text, // Pass the OTP entered by the user
                  cgv.value, // Use the consent and agreement values
                  cndp.value,
                );
                Navigator.of(context).pop(); // Close the dialog
              } else {
                // Show an error if OTP is empty
                Get.snackbar(
                  'Error',
                  'Please enter the OTP',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12), // More padding
              backgroundColor: const Color.fromARGB(
                  255, 173, 19, 19), // Primary color for the submit button
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(8), // Rounded corners for button
              ),
            ),
            child: const Text(
              'Submit',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16), // Style the submit button text
            ),
          ),
        ],
      ),
    );
  }
}
