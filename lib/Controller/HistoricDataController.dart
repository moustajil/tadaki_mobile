import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tadakir/View/Screens/SingInAndSingOut.dart';
import 'package:tadakir/View/ShowDialog/ShowDialog.dart';

class HistoricDataController extends GetxController {
  RxList<Map<String, dynamic>> oldHestoricalDataList =
      <Map<String, dynamic>>[].obs;
  String baseUrl = "https://preprod.tadakir.net";

  Future<void> getHistoricalData(BuildContext context, String token) async {
    try {
      // Make the HTTP GET request
      final response = await http.get(
        Uri.parse('$baseUrl/api/mobile/order/history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Check the response status code
      if (response.statusCode == 200) {
        final dynamic responseBody = jsonDecode(response.body);

        // Update the RxList with the new data
        oldHestoricalDataList
            .assignAll(List<Map<String, dynamic>>.from(responseBody));
        print("heoooooooo = $responseBody");
      } else if (response.statusCode == 401) {
        // Unauthorized - show dialog and navigate to sign-in screen
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
  }

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
      onTap: () {},
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
              // Logos and Names
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
}
