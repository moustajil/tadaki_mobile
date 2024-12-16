// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:http/http.dart' as http;
import 'package:tadakir/Controller/ControllerSharedPrefrances.dart';
import 'package:tadakir/View/Screens/EventListPage.dart';
import 'package:tadakir/View/Screens/InformationOfCommand.dart';
import 'package:tadakir/View/Screens/SingInAndSingOut.dart';
import 'package:tadakir/View/Screens/SingInWithEmail.dart';
import 'package:tadakir/View/ShowDialog/ShowDialog.dart';

const String baseUrl = "https://preprod.tadakir.net";
final ctrEmail = ControllerSharedPreferences();


Future<List<Map<String, dynamic>>> getAllElementInformation(
    BuildContext context, String token) async {
  try {
    // Make the HTTP GET request
    final response = await http.get(
      Uri.parse('$baseUrl/api/mobile/evenement'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // Check the response status code
    if (response.statusCode == 200) {
      // Decode the response body
      final List<dynamic> responseBody = jsonDecode(response.body);
      debugPrint('Response Body: $responseBody');
      // Return the parsed response as a list of maps
      return List<Map<String, dynamic>>.from(responseBody);
    } else if (response.statusCode == 401) {
      // Unauthorized, show error and navigate to login
      if (context.mounted) {
        showDialogForResponse(context, 'Unauthorized', 'Please log in again.');
        Get.offAll(() => const SinginandSingout());
      }
    } else {
      // Handle other errors
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
    // Handle any exceptions
    if (context.mounted) {
      showDialogForResponse(context, 'Error', 'An error occurred: $e');
    }
    debugPrint('Error: $e');
  }

  // Return an empty list in case of an error or failure
  return [];
}

Future<List<Map<String, dynamic>>> getCategoryOfEvenement(
    BuildContext context, String token, String id) async {
  try {
    // Make the HTTP GET request
    final response = await http.get(
      Uri.parse('$baseUrl/api/mobile/evenement/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // Check the response status code
    if (response.statusCode == 200) {
      // Decode the response body
      final decodedBody = jsonDecode(response.body);

      // Handle both Map and List responses
      if (decodedBody is List) {
        return decodedBody
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      } else if (decodedBody is Map) {
        return [Map<String, dynamic>.from(decodedBody)];
      } else {
        throw Exception("Unexpected response format: Expected Map or List.");
      }
    } else {
      // Handle HTTP errors based on status code
      final errorBody = jsonDecode(response.body);
      String errorMessage = errorBody['message'] ?? 'Unknown error';

      // Handle 401 Unauthorized
      if (response.statusCode == 401 && context.mounted) {
        showDialogForResponse(context, 'Unauthorized', 'Please log in again.');
      } else if (context.mounted) {
        // Show other HTTP error responses
        showDialogForResponse(
          context,
          'Category of Evenement Error',
          'Failed: $errorMessage',
        );
      }

      // Log the error for debugging
      debugPrint('HTTP Error: ${response.statusCode}, $errorMessage');
    }
  } catch (e) {
    // Handle exceptions like network errors or JSON parsing errors
    if (context.mounted) {
      showDialogForResponse(context, 'Error', 'An error occurred: $e');
    }
    // Log the error for debugging
    debugPrint('Error: $e');
  }

  // Return an empty list in case of failure or error
  return [];
}

void showDialogForCommand(
    BuildContext context, String? title, String? content) {
  // Ensure that neither title nor content is null.
  if (title == null || content == null) {
    debugPrint('Error: Title or content is null.');
    return;
  }

  // Ensure context is mounted before showing the dialog.
  if (!context.mounted) return;

  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissal by tapping outside.
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(
          title,
          style:
              const TextStyle(fontWeight: FontWeight.bold), // Optional styling.
        ),
        content: Text(
          content,
          style: const TextStyle(fontSize: 16), // Optional content styling.
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Get.off(
                  const Informationofcommand()); // Ensure proper navigation.
            },
            icon: const Icon(Icons.shopping_cart), // Icon for the "panier".
            label: const Text('Panier'), // Label for the button.
          ),
        ],
      );
    },
  );
}

Future<void> sendQtOfCommand(
  BuildContext context,
  String event,
  String category,
  String token,
  String idCategory,
  int? qt,
  String price,
) async {
  if (!context.mounted) return; // Early return if context is not mounted.

  // Check for null values.
  if ([event, category, token, idCategory, price].contains(null) ||
      qt == null) {
    debugPrint('One or more required parameters are null.');
    if (context.mounted) {
      showDialogForResponse(
        context,
        'Error',
        'Invalid input: Please ensure all fields are filled.',
      );
    }
    return;
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/mobile/order'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'ect': idCategory,
        'qte': qt,
      }),
    );

    switch (response.statusCode) {
      case 200:
        //print("Request successful: ${response.body}");
        Get.to(const Informationofcommand());
        break;

      case 401:
        print("Unauthorized: ${response.body}");
        Get.offAll(() => const SignInWithEmail());
        break;

      default:
        showDialogForCommand(
          context,
          "You have already command",
          "Please go to the command",
        );
    }
  } catch (e) {
    if (context.mounted) {
      showDialogForResponse(
        context,
        'Error',
        'An unexpected error occurred. Please try again.\nDetails: $e',
      );
    }
    debugPrint('Error in sendQtOfCommand: $e');
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
        showDialogForResponse(context, 'Unauthorized', 'Please log in again.');
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

Future<Map<String, dynamic>> getInformationUser(
    BuildContext context, String token) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/mobile/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // Handle response
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      debugPrint('Response Body: $responseBody');
      print(
          "this is informarion of user : -----------------------------------------------$responseBody");

      return responseBody;
    } else if (response.statusCode == 401) {
      if (context.mounted) {
        showDialogForResponse(context, 'Unauthorized', 'Please log in again.');
        Get.offAll(() => const SinginandSingout());
      }
    } else {
      // Handle other error responses
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
    // Handle exceptions
    if (context.mounted) {
      showDialogForResponse(context, 'Error', 'An error occurred: $e');
    }
    debugPrint('Error: $e');
  }

  // Return an empty map in case of error
  return {};
}

Future<void> sendEmailForRegistration(
    BuildContext context, String email) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/mobile/auth/register/sendotp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (!context.mounted) return; // Ensure context is valid after await.

    final dynamic responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (responseBody is Map<String, dynamic>) {
        final message = responseBody["message"] ?? "OTP sent successfully.";
        print(message);
      } else {
        showDialogForResponse(context, 'Success', "OTP sent successfully.");
      }
    } else {
      if (responseBody is Map<String, dynamic>) {
        final error = responseBody["message"] ?? "Email not found.";
        showDialogForResponse(context, 'Error', error);
      } else {
        showDialogForResponse(
            context, 'Error', "An unexpected error occurred.");
      }
    }
  } catch (e) {
    if (context.mounted) {
      showDialogForResponse(context, 'Error', 'An error occurred: $e');
    }
    debugPrint('Error in sendEmailForRegistration: $e');
  }
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

    Navigator.pop(context);

    // Handle response
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      print(
          'Response Body: ---------------------------------------------------  $responseBody');
      if (context.mounted) {
        Get.back();
      }
    } else if (response.statusCode == 401) {
      if (context.mounted) {
        showDialogForResponse(context, 'Unauthorized', 'Please log in again.');
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
