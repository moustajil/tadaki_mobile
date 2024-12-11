import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:tadakir/Controller/API.dart';
import 'package:tadakir/Controller/ControllerSharedPrefrances.dart';
import 'package:tadakir/Controller/OtpVerificationController.dart';

class OtpVerification extends StatefulWidget {
  const OtpVerification({super.key});

  @override
  State<OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  final sharedsPrefrenaces = ControllerSharedPreferences();
  final TextEditingController _otpController = TextEditingController();
  final otpVerificationController = Otpverificationcontroller();
  late Timer _timer;
  int _remainingSeconds = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel(); // Stop the countdown
        _showResendOtpDialog(); // Show the dialog to ask for OTP resend
      }
    });
  }

  void _showResendOtpDialog() {
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
                      await sharedsPrefrenaces.getEmail(); // Await the Future
                  if (email != null && email.isNotEmpty) {
                    _remainingSeconds = 60; // Reset the countdown
                    _startCountdown(); // Restart the countdown
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

  Future<void> sendEmailAndRestartTimer() async {
    try {
      dynamic email = sharedsPrefrenaces.getEmail();
      await sendEmail(context, email);
    } catch (e) {
      // Handle any exceptions (e.g., log or show an error message)
      print('Error sending email: $e');
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'OTP Verification',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Container(
          height: double.infinity,
          color: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/otp_img.png',
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.height * 0.3,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 60),
                const Text(
                  'Enter the OTP sent to your email:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    hintText: 'Enter OTP',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color.fromARGB(255, 255, 255, 255),
                    counterText: '',
                  ),
                  style: const TextStyle(fontSize: 18),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Obx(
                    () {
                      return ElevatedButton(
                        onPressed: otpVerificationController.isLoading.value
                            ? null // Disable button when loading
                            : () {
                                otpVerificationController
                                    .handlingClickOnVerificationOtp(
                                  context,
                                  _otpController.text.trim(),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                        ),
                        child: otpVerificationController.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 1,
                                ),
                              )
                            : const Text(
                                'Verify',
                                style: TextStyle(color: Colors.white),
                              ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    _formatTime(_remainingSeconds),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
