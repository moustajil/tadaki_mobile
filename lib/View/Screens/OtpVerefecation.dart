import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
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

  @override
  void initState() {
    super.initState();
    otpVerificationController.startCountdown(context);
  }

  @override
  void dispose() {
    _otpController.dispose();
    otpVerificationController.timer.cancel();
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
                  'assets/images/otp.png',
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                            side: const BorderSide(
                              color: Color.fromARGB(255, 211, 49, 58),
                              width: 2, // Set border
                            ),
                          ),
                          backgroundColor:
                              const Color.fromARGB(255, 211, 49, 58),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8), // Set background color
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(bottom: 3, top: 3),
                          child: Text(
                            'Verify',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                    child: Obx(
                  () => Text(
                    _formatTime(
                        otpVerificationController.remainingSeconds.value),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
