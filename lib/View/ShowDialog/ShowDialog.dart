import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tadakir/Controller/API.dart';
import 'package:tadakir/Controller/ControllerSharedPrefrances.dart';
import 'package:tadakir/View/Screens/SingInAndSingOut.dart';

// ignore: non_constant_identifier_names
void ShowDialogQt(
  BuildContext context,
  String categoryColor,
  String category,
  String price,
  String event,
  int idCategory,
) {
  Color color;
  try {
    color = Color(int.parse(categoryColor.replaceAll('#', '0xFF')));
  } catch (e) {
    color = Colors.grey; // Default color if parsing fails
  }

  int quantity = 1;
  double unitPrice;
  try {
    unitPrice = double.parse(price);
  } catch (e) {
    unitPrice = 0.0; // Default price if parsing fails
  }

  final cntSharedPrefs = ControllerSharedPreferences();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          category,
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "$price DH",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (quantity > 1) quantity--;
                          });
                        },
                        child: const Text("-"),
                      ),
                      Text(
                        "$quantity",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                        child: const Text("+"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Price:",
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        "${(quantity * unitPrice).toStringAsFixed(2)} DH",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            String? token = await cntSharedPrefs.getToken();
                            if (token == null || token.isEmpty) {
                              throw Exception(
                                  "Authentication token is missing.");
                            }
                            await sendQtOfCommand(
                              // ignore: use_build_context_synchronously
                              context,
                              event,
                              category,
                              token,
                              idCategory.toString(),
                              quantity,
                              price,
                            );
                            if (kDebugMode) {
                              print("The event name is: $event");
                            }
                          } catch (e) {
                            debugPrint("Error during API call: $e");
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text("Failed to send the command: $e"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text(
                          "Confirm",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
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

void showNotificationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Notification',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Icon(
                Icons.notifications,
                size: 65,
                color: Colors.black,
              ),
              const SizedBox(height: 10), // Space between icon and title
              const Text(
                'Stay updated! Allow notifications to receive important updates, reminders, and alerts tailored just for you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                  height: 20), // Space between description and buttons
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, // Align buttons evenly
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor:
                          Colors.grey[300], // Cancel button background
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () async {
                      final controller = ControllerSharedPreferences();
                      await controller.saveAuthNotification("no");
                      Get.off(
                        const SinginandSingout(),
                      );
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 211, 49, 58),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () async {
                      final controller = ControllerSharedPreferences();
                      await controller.saveAuthNotification("ok");
                      Get.off(
                        const SinginandSingout(),
                      );
                    },
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showDialogOtpVerification(
    BuildContext context, String title, String content) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(content),
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

void showDialogForResponse(BuildContext context, String title, String content) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(content),
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

void showDialogForCancelOrder(BuildContext context, String token) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white, // Background color for the alert dialog
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      title: const Text(
        "Confirm Order Deletion",
        style: TextStyle(
          fontSize: 18, // Title font size
          fontWeight: FontWeight.bold,
          color: Colors.redAccent, // Color for the title
        ),
      ),
      content: const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text(
          "Are you sure you want to delete this order? This action cannot be undone.",
          style: TextStyle(
            fontSize: 16, // Content font size
            color: Colors.black87, // Content text color
          ),
        ),
      ),
      actions: [
        // Wrap buttons in a Row to ensure equal spacing
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Cancel button (NO)
            SizedBox(
              width: 120, // Set a fixed width for the buttons
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.white, // White background for the "No" button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                  minimumSize: const Size(
                      double.infinity, 40), // Ensure buttons have same height
                ),
                child: const Text(
                  'No',
                  style: TextStyle(
                    color: Color.fromARGB(
                        255, 155, 150, 150), // Gray text for "No"
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Confirm button (Yes)
            SizedBox(
              width: 120, // Set a fixed width for the buttons
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    // Call the deletOrder function and wait for it to finish
                    await deletOrder(context, token);

                    // After successful deletion, pop the current screen
                    Get.back();
                  } catch (e) {
                    // Handle the error, if any, that occurred during the deletion process
                    print("Error: $e");
                    // Optionally, you can show a dialog or Snackbar for the error
                    if (context.mounted) {
                      showDialogForResponse(
                          context, 'Error', 'An error occurred: $e');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.redAccent, // Red background for the "Yes" button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                  minimumSize: const Size(
                      double.infinity, 40), // Ensure buttons have same height
                ),
                child: const Text(
                  'Yes, Delete',
                  style: TextStyle(
                    color: Colors.white, // White text for "Yes"
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    ),
  );
}
