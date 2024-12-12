import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tadakir/Controller/API.dart';
import 'package:tadakir/Controller/ControllerSharedPrefrances.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tadakir/View/ShowDialog/ShowDialog.dart';

class Informationusercontroller extends GetxController {
  RxMap<String, dynamic> infoUser = <String, dynamic>{}.obs;
  RxList<Map<String, dynamic>> villes = <Map<String, dynamic>>[].obs;
  final sharedPrefers = ControllerSharedPreferences();

  Future<void> fetchInfoUser(BuildContext context) async {
    try {
      // Retrieve the token
      String? token = await sharedPrefers.getToken();
      if (token == null || token.isEmpty) {
        throw Exception("User token is null or empty.");
      }

      // Fetch user information
      // ignore: use_build_context_synchronously
      final responseBody = await getInformationUser(context, token);
      infoUser.value = responseBody;
    
      // Fetch cities and update the state
      // ignore: use_build_context_synchronously
      List<Map<String, dynamic>> cityList = await getAllCities(context, token);
      villes.value = cityList; // Update villes after fetching cities
    } catch (e) {
      debugPrint("Error fetching user info or cities: $e");
      if (context.mounted) {
        showDialogForResponse(context, "Error", "An error occurred: $e");
      }
    }
  }

  // API to fetch all cities
  Future<List<Map<String, dynamic>>> getAllCities(
      BuildContext context, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/mobile/ville'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Parse the response body and return the list of cities
        final List<dynamic> responseBody = jsonDecode(response.body);
        return responseBody
            .map((city) => city as Map<String, dynamic>)
            .toList();
      } else {
        // Handle HTTP error response
        if (context.mounted) {
          showDialogForResponse(context, 'Error',
              'Failed to fetch cities: ${response.statusCode}');
        }
        debugPrint(
            'Failed to fetch cities: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error in getAllCities: $e');
      return [];
    }
  }

  Future<void> updateInformation(
    BuildContext context,
    String token,
    String nom,
    String prenom,
    String sex,
    String birthdate,
    String telephone,
    String cin,
    String ville,
    String email,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/mobile/profile/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nom': nom,
          'prenom': prenom,
          'sex': sex,
          'birthdate': birthdate,
          'telephone': telephone,
          'cin': cin,
          'ville': ville,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        // Parse the response body and handle success
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print("Response message: ${responseBody['message']}");

        // Show success dialog
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible:
                false, // Prevent closing the dialog by tapping outside
            builder: (BuildContext context) {
              return AlertDialog(
                contentPadding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 40,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Update Successful!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${responseBody['message']}',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );

          // Optionally, you can dismiss the dialog after 1 second
          Future.delayed(const Duration(seconds: 1), () {
            // ignore: use_build_context_synchronously
            Navigator.of(context).pop();
          });
        }
      } else {
        // Handle HTTP error response
        if (context.mounted) {
          showDialogForResponse(
            context,
            'Error',
            'Failed to fetch: ${response.statusCode} - ${jsonDecode(response.body)}',
          );
        }
        print('Failed to fetch: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in updateInformation: $e');
    }
  }
}
