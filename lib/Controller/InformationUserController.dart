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
      final responseBody = await getInformationUser(context, token);
      if (responseBody != null) {
        infoUser.value = responseBody;
      } else {
        throw Exception("Failed to fetch user info.");
      }

      // Fetch cities and update the state
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
}
