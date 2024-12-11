import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tadakir/Controller/ControllerSharedPrefrances.dart';
import 'package:tadakir/View/Screens/OtpVerefecation.dart';

class Singinwithemailcontroller extends GetxController {
  RxBool isLoading = false.obs;
  String baseUrl = "https://preprod.tadakir.net";
  final sharedPref = ControllerSharedPreferences();

  void handleSignIn(BuildContext context, String email) async {
    if (email.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a valid email',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Simulate API call with delay
      await Future.delayed(
          const Duration(seconds: 2)); // Replace with actual API call
      // ignore: use_build_context_synchronously
      sendEmail(context, email.trim());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign in. Please try again later.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false; // Hide loading indicator
    }
  }

  Future<void> sendEmail(BuildContext context, String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/mobile/auth/login/sendotp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        sharedPref.saveEmail(email);
        Get.to(const OtpVerification());
      } else {
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Errore'),
            // content: Text(jsonDecode(response.body)["message"]),
            content: const Text("Email not found"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text('An error occurred: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
