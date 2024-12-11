import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tadakir/Controller/ControllerSharedPrefrances.dart';
import 'package:tadakir/View/Screens/EventListPage.dart';
import 'package:tadakir/View/ShowDialog/ShowDialog.dart';

class Otpverificationcontroller extends GetxController {
  var ctrPrefs = ControllerSharedPreferences();
  RxBool isLoading = false.obs;
  void handlingClickOnVerificationOtp(BuildContext context,String otp) async {

    if (otp.length == 6) {
      final email = await ctrPrefs.getEmail();

      if (email != null && email.isNotEmpty) {
        if (context.mounted) {
            isLoading.value = true; // Start loading
          await sendEmailAndOtpVerification(context, email, otp);
          ctrPrefs.saveOtp(otp);
            isLoading.value = false; // Stop loading after the verification
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('No email found. Please try again.'),
            ),
          );
        }
      }
    } else {
      if (context.mounted) {
        // Show error message if OTP is not valid
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Please enter a valid 6-digit OTP'),
          ),
        );
      }
    }
  }

  Future<void> sendEmailAndOtpVerification(
      BuildContext context, String email, String otp) async {
    const String baseUrl = "https://preprod.tadakir.net";

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/mobile/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      if (context.mounted) {
        Navigator.of(context).pop(); // Close the loading dialog
      }

      if (response.statusCode == 200) {
        showDialogOtpVerification(context, "body", response.body);
        // print("${response.body}");
        Get.off(const EventListPage());
        final data = jsonDecode(response.body);

        // Navigate to EventListPage
        if (context.mounted) {
          if (data.containsKey('token') && data['token'] != null) {
            ctrPrefs.saveToken(data['token'].toString());
            showDialogOtpVerification(
              context,
              "token",
              data['token'].toString(),
            );
          } else {
            print("Token is missing or null");
          }

          Get.offAll(const EventListPage());
        }
      } else {
        String errorMessage = "OTP verification failed.";
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (_) {
          // Fall back to default error message
        }
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Error'),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close the loading dialog

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: Text('An error occurred: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}
