import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tadakir/Controller/API.dart';
import 'package:tadakir/Controller/ControllerSharedPrefrances.dart';
import 'package:tadakir/Controller/OtpVerificationController.dart';
import 'package:tadakir/View/ShowDialog/ShowDialog.dart';

class Informationofcommand extends StatefulWidget {
  const Informationofcommand({super.key});

  @override
  State<Informationofcommand> createState() => _InformationofcommandState();
}

class _InformationofcommandState extends State<Informationofcommand> {
  final sharedPrefs = ControllerSharedPreferences();
  final otpVerificationController = Get.put(Otpverificationcontroller());

  Map<String, dynamic>? commandDetail = {
    "id": 0,
    "createdAt": "",
    "expiredAt": "",
    "categorieNomFr": "",
    "amount": 0,
    "tickets": []
  };
  late Timer _timer;
  int _remainingSeconds = 0; // Start with 0, will be updated later.
  bool _isEmailSent = false;
  DateTime currentTime = DateTime.now();
  DateTime? expiredAt;

  @override
  void initState() {
    super.initState();
    _fetchDetailCommand();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else if (_remainingSeconds == 0 && !_isEmailSent) {
        setState(() {
          _isEmailSent = true;
        });
        // Avoid blocking the UI thread with await in countdown
        otpVerificationController
            .sendEmail(context, sharedPrefs.getEmail() as String)
            .then((_) {
          _startCountdown(); // Restart the countdown after sending the email.
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _fetchDetailCommand() async {
    try {
      String? token = await sharedPrefs.getToken();

      if (token == null || token.isEmpty) {
        print("Token is null or empty");
        return;
      }

      // ignore: use_build_context_synchronously
      final responseBody = await getCartIfExists(context, token);

      if (mounted) {
        setState(() {
          commandDetail = responseBody;
          expiredAt = DateTime.parse(commandDetail!["expiredAt"]);
          final difference = expiredAt?.difference(currentTime);
          print("Current time: $currentTime");
          print("Expired At: $expiredAt");
          print(
              "Difference: ${difference?.inHours} hours and ${difference!.inMinutes % 60} minutes");

          // Calculate the remaining seconds directly
          _remainingSeconds = difference.inSeconds;
        });
      }
    } catch (e) {
      print("Error fetching command details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    print("-------------------- build --------------------$commandDetail");

    int total = commandDetail!["amount"];
    double priceOfTicket = total / commandDetail!["tickets"].length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Command Info",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Timer",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    _formatTime(_remainingSeconds),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color.fromARGB(255, 211, 49, 58),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Order Details",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   "Event:  ${commandDetail[""]}",
                    //   style: const TextStyle(fontWeight: FontWeight.bold),
                    // ),
                    const SizedBox(height: 10),
                    Text(
                      "Category: ${commandDetail!["categorieNomFr"]}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Table(
                      border: TableBorder.all(color: Colors.grey.shade300),
                      children: [
                        const TableRow(children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Price",
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Quantity",
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Total",
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "$priceOfTicket MAD",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "${commandDetail!["tickets"].length}",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "$total MAD",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Table(
                        defaultColumnWidth: const IntrinsicColumnWidth(),
                        border: TableBorder.all(color: Colors.grey.shade300),
                        children: [
                          const TableRow(
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 211, 49, 58)),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Porte",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Secteur",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Range",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Seige",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          if (commandDetail!["tickets"] != null)
                            ...commandDetail!["tickets"]
                                .map<TableRow>((ticket) {
                              return TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      ticket["secteur"] ?? "N/A",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      ticket["range"] ?? "N/A",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      ticket["siege"] ?? "N/A",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      ticket["porte"] ?? "N/A",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 211, 49, 58),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  onPressed: () {
                    showDialogWithPaymentOptions(context);
                  },
                  child: const Text(
                    "Proceed to Payment",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  onPressed: () async {
                    String? token = await sharedPrefs.getToken();

                    // Ensure token is valid
                    if (token == null || token.isEmpty) {
                      print("Token is null or empty");
                      return;
                    }
                    // ignore: use_build_context_synchronously
                    //deletOrder(context, token);
                    // ignore: use_build_context_synchronously
                    showDialogForCancelOrder(context, token);
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 211, 49, 58),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: non_constant_identifier_names
void showDialogWithPaymentOptions(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Ensures dialog fits its content
                crossAxisAlignment: CrossAxisAlignment
                    .stretch, // Stretch buttons to match parent width
                children: [
                  const Text(
                    "Choose Payment Method",
                    textAlign: TextAlign.center, // Center-align the title
                    style: TextStyle(
                      fontSize:
                          20, // Slightly larger text for better visibility
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      // Add CMI functionality here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 211, 49,
                          58), // Updated color for better contrast
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Rounded button
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12), // Adjusted for vertical stacking
                    ),
                    child: const Text(
                      "CMI",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 211, 49, 58), // Highlighted red button
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Rounded button
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12), // Adjusted for vertical stacking
                    ),
                    child: const Text(
                      "M2T",
                      style: TextStyle(
                        color: Colors.white, // White text for visibility
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget buildOrderRow({
  required String event,
  required String category,
  required String price,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            event,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            category,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(price),
        ),
      ],
    ),
  );
}
