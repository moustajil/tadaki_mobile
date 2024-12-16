import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tadakir/Controller/API.dart';
import 'package:tadakir/Controller/ControllerSharedPrefrances.dart';
import 'package:tadakir/View/Screens/SingInAndSingOut.dart';
import 'package:tadakir/View/Screens/TicketOptions.dart';
import 'package:http/http.dart' as http;
import 'package:tadakir/View/ShowDialog/ShowDialog.dart';

class Eventlistpagecontroller extends GetxController {
  final sharedPrefs = ControllerSharedPreferences();
  RxList<Map<String, dynamic>> events = <Map<String, dynamic>>[].obs;
  RxMap infoUser = {}.obs;
  RxBool isLoading = true.obs;
  RxBool ifCartExists = false.obs;
  RxMap? myCart;

  //fetching data from api
  Future<void> fetchEvents(BuildContext context) async {
    try {
      String? token = await sharedPrefs.getToken();
      // ignore: use_build_context_synchronously
      await getAllElementInformation(context, token!).then((responseBody) {
        events.value = responseBody;
      });
    } catch (e) {
      print("Error fetching events: $e");
    }
  }

  // ui of event cart
  Widget eventCard({
    required BuildContext context,
    required String clubLogo,
    required String clubVistoreLogo,
    required String clubNomAr,
    required String clubVisitoreNom,
    required String evenementPrix,
    required String dateOfEvenement,
    required String localisationEvenement,
    required int evenementId,
    required String evenementName,
  }) {
    return GestureDetector(
      onTap: () {
        sharedPrefs.saveIdEvenemetn(evenementId);
        Get.to(TicketOptions(
          evenementId: evenementId,
        ));
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Image.network(
                        clubLogo,
                        width: 70,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        clubNomAr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Column(
                    children: [
                      Image.network(
                        clubVistoreLogo,
                        width: 70,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        clubVisitoreNom,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Event Date
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dateOfEvenement,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Event Location
              Row(
                children: [
                  const Icon(Icons.location_on, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      localisationEvenement,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Event Price
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'À partir de $evenementPrix MAD',
                      style: const TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // get all currantly event
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

  Future<void> initializeData(BuildContext context) async {
    try {
      String? token = await sharedPrefs.getToken();
      if (token == null || token.isEmpty) {
        throw Exception("User token is null or empty.");
      }

      // ignore: use_build_context_synchronously
      infoUser.value = await getInformationUser(context, token);

      isLoading.value = false; // Set loading to false after data is fetched

      // ignore: use_build_context_synchronously
      fetchEvents(context);
    } catch (e) {
      // Handle errors or show a message
      print("Error initializing data: $e");

      isLoading.value = false; // Set loading to false in case of error
    }
  }

  // Future<void> checkCartIfExists(BuildContext context) async {
  //   String? token = await sharedPrefs.getToken();
  //   if (token == null || token.isEmpty) {
  //     throw Exception("User token is missing.");
  //   }

  //   // ignore: use_build_context_synchronously
  //   final responseBody = await getCartIfExists(context, token);

  //   if (responseBody.isNotEmpty) {
  //     myCart!.value = responseBody;
  //   }
  // }
}
