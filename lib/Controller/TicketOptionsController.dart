import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tadakir/Controller/ControllerSharedPrefrances.dart';
import 'package:tadakir/Controller/EventListPageController.dart';

class Ticketoptionscontroller extends GetxController {
  final sharedPrefs = ControllerSharedPreferences();

  // Make the `myEvenet` reactive
  RxMap<String, dynamic> myEvenet = <String, dynamic>{}.obs;
  final eventController = Get.put(Eventlistpagecontroller());

  Future<void> fetchEventSelected(BuildContext context, int idEvenement) async {
    try {
      String? token = await sharedPrefs.getToken();
      // ignore: use_build_context_synchronously
      await eventController.getAllElementInformation(context, token!).then((responseBody) {
        print("Response Body: $responseBody");

        // Set the `myEvenet` with the fetched event data
        for (var event in responseBody) {
          if (event['evenementId'] != null &&
              event['evenementId'] == idEvenement) {
            myEvenet.value = event; // Update the reactive state
            if (kDebugMode) {
              // ignore: invalid_use_of_protected_member
              print("Found event: ${myEvenet.value}");
            }
            break;
          }
        }
      });
    } catch (e) {
      print("Error fetching events: $e");
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
    return Card(
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
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
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
    );
  }
}
