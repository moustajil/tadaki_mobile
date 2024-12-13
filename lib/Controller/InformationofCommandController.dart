// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:tadakir/Controller/API.dart';
// import 'package:tadakir/Controller/ControllerSharedPrefrances.dart';

// class InformationofCommandController extends GetxController {
//   final sharedPrefs = ControllerSharedPreferences();
//   late RxMap commandDetail = {}.obs;
//   late Timer timer;
//   RxInt remainingSeconds = 0.obs; // Start with 0, will be updated later.
//   RxBool isEmailSent = false.obs;
//   DateTime currentTime = DateTime.now();
//   DateTime? expiredAt;

//   get otpVerificationController => null;

//   void startCountdown() {
//     timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (remainingSeconds > 0) {
//         remainingSeconds.value--;
//       // ignore: unrelated_type_equality_checks
//       } else if (remainingSeconds == 0 && !isEmailSent.value) {
//         isEmailSent.value = true;
//         // Avoid blocking the UI thread with await in countdown
//         otpVerificationController
//             .sendEmail(sharedPrefs.getEmail() as String)
//             .then((_) {
//           startCountdown(); // Restart the countdown after sending the email.
//         });
//       }
//     });
//   }

//   Future<void> fetchDetailCommand(BuildContext context) async {
//     try {
//       String? token = await sharedPrefs.getToken();

//       if (token == null || token.isEmpty) {
//         print("Token is null or empty");
//         return;
//       }

//       // ignore: use_build_context_synchronously
//       final responseBody = await getCartIfExists(context, token);

//       commandDetail.value = responseBody;
//       expiredAt = DateTime.parse(commandDetail["expiredAt"]);
//       final difference = expiredAt?.difference(currentTime);
//       print("Current time: $currentTime");
//       print("Expired At: $expiredAt");
//       print(
//           "Difference: ${difference?.inHours} hours and ${difference!.inMinutes % 60} minutes");

//       // Calculate the remaining seconds directly
//       remainingSeconds.value = difference.inSeconds;

//       // Start the countdown
//       startCountdown();
//     } catch (e) {
//       print("Error fetching command details: $e");
//     }
//   }
// }
