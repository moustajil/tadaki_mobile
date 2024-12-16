import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tadakir/Controller/API.dart';
import 'package:tadakir/Controller/ControllerSharedPrefrances.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tadakir/View/Screens/InformationOfCommand.dart';
import 'package:tadakir/View/Screens/SingInAndSingOut.dart';
import 'package:tadakir/View/ShowDialog/ShowDialog.dart';

class InformationofCommandController extends GetxController {
  final sharedPrefs = ControllerSharedPreferences();
  RxMap commandDetail = {
    "id": 0,
    "createdAt": "",
    "expiredAt": "",
    "categorieNomFr": "",
    "amount": 0,
    "tickets": []
  }.obs;
  late Timer timer;
  RxInt remainingSeconds = 0.obs;
  RxBool isEmailSent = false.obs;
  DateTime currentTime = DateTime.now();
  DateTime? expiredAt;

  get otpVerificationController => null;

  void startCountdown() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        remainingSeconds.value--;
        // ignore: unrelated_type_equality_checks
      } else if (remainingSeconds == 0 && !isEmailSent.value) {
        isEmailSent.value = true;
        // Avoid blocking the UI thread with await in countdown
        otpVerificationController
            .sendEmail(sharedPrefs.getEmail() as String)
            .then((_) {
          startCountdown(); // Restart the countdown after sending the email.
        });
      }
    });
  }

  Future<void> fetchDetailCommand(BuildContext context) async {
    try {
      String? token = await sharedPrefs.getToken();

      if (token == null || token.isEmpty) {
        print("Token is null or empty");
        return;
      }

      // ignore: use_build_context_synchronously
      final responseBody = await getCartIfExists(context, token);

      commandDetail.value = responseBody;
      expiredAt = DateTime.parse(commandDetail["expiredAt"]);
      final difference = expiredAt?.difference(currentTime);
      print("Current time: $currentTime");
      print("Expired At: $expiredAt");
      print(
          "Difference: ${difference?.inHours} hours and ${difference!.inMinutes % 60} minutes");

      // Calculate the remaining seconds directly
      remainingSeconds.value = difference.inSeconds;

      // Start the countdown
      startCountdown();
    } catch (e) {
      print("Error fetching command details: $e");
    }
  }

  Future<Map<String, dynamic>> getCartIfExists(
      BuildContext context, String token) async {
    try {
      // Make the HTTP GET request
      final response = await http.get(
        Uri.parse('$baseUrl/api/mobile/order/cart'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      // Check the response status code
      if (response.statusCode == 200) {
        final dynamic responseBody = jsonDecode(response.body);
        return Map<String, dynamic>.from(responseBody);
      } else if (response.statusCode == 401) {
        if (context.mounted) {
          showDialogForResponse(
              context, 'Unauthorized', 'Please log in again.');
          Get.offAll(() => const SinginandSingout());
        }
      } else {
        // Handle other errors
        final errorBody = jsonDecode(response.body);
        if (context.mounted) {
          showDialogForResponse(
            context,
            'Error 12',
            'Failed: ${errorBody['message'] ?? 'Unknown error'}',
          );
        }
      }
    } catch (e) {
      // Handle any exceptions
      if (context.mounted) {
        showDialogForResponse(context, 'Error', 'An error occurred: $e');
      }
      debugPrint('Error 33: $e');
    }

    // Return an empty list in case of an error or failure
    return {};
  }

  Future<void> deletOrder(BuildContext context, String token) async {
    try {
      // Show loading indicator
      showDialog(
          context: context,
          builder: (_) => const Center(child: CircularProgressIndicator()));

      final response = await http.delete(
        Uri.parse('$baseUrl/api/mobile/order/cart'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // ignore: use_build_context_synchronously
      Navigator.pop(context);

      // Handle response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print(
            'Response Body: ---------------------------------------------------  $responseBody');
        if (context.mounted) {
          Get.to(const Informationofcommand());
        }
      } else if (response.statusCode == 401) {
        if (context.mounted) {
          showDialogForResponse(
              context, 'Unauthorized', 'Please log in again.');
          Get.offAll(() => const SinginandSingout());
        }
      } else {
        final errorBody = jsonDecode(response.body);
        if (context.mounted) {
          showDialogForResponse(
            context,
            'Error',
            'Failed: ${errorBody['message'] ?? 'Unknown error'}',
          );
        }
      }
    } catch (e) {
      Navigator.pop(context);
      if (context.mounted) {
        showDialogForResponse(context, 'Error', 'An error occurred: $e');
      }
      debugPrint('Error: $e');
    }
  }
}
