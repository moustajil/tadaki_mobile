import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tadakir/Controller/ControllerSharedPrefrances.dart';
import 'package:tadakir/View/Screens/EventListPage.dart';
import 'package:tadakir/View/Screens/OtpVerefecation.dart';
import 'package:tadakir/View/ShowDialog/ShowDialog.dart';

class Otpverificationcontroller extends GetxController {
  var ctrPrefs = ControllerSharedPreferences();
  RxBool isLoading = false.obs;
  final RxInt remainingSeconds = 60.obs;
  late Timer timer;
  final String baseUrl = "https://preprod.tadakir.net";

  void handlingClickOnVerificationOtp(BuildContext context, String otp) async {
    if (otp.length == 6) {
      final email = await ctrPrefs.getEmail();
      if (email != null && email.isNotEmpty) {
        if (context.mounted) {
          isLoading.value = true; // Start loading
          await sendEmailAndOtpVerification(context, email, otp);
          ctrPrefs.saveOtp(otp);
          isLoading.value = false;
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
        // ignore: use_build_context_synchronously
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


  void showResendOtpDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog without action
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Resend OTP'),
          content:
              const Text('The OTP has expired. Would you like to resend it?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog

                try {
                  final email =
                      await ctrPrefs.getEmail(); // Await the Future
                  if (email != null && email.isNotEmpty) {
                    remainingSeconds.value = 60; // Reset the countdown
                    startCountdown(context); // Restart the countdown
                    // ignore: use_build_context_synchronously
                    await sendEmail(context, email); // Resend the OTP
                  } else {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Unable to fetch email. Please try again.'),
                      ),
                    );
                  }
                } catch (e) {
                  // Handle potential errors
                  print('Error sending email: $e');
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                    ),
                  );
                }
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }


  void startCountdown(BuildContext context) {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
          remainingSeconds.value--;
      } else {
        timer.cancel(); // Stop the countdown
        showResendOtpDialog(context); // Show the dialog to ask for OTP resend
      }
    });
  }

  Future<void> sendEmail(BuildContext context, String email) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/mobile/auth/login/sendotp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      ctrPrefs.saveEmail(email);
      Get.to(const OtpVerification());
    } else {
      showDialog(
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
