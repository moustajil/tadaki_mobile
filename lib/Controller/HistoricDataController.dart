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
}
