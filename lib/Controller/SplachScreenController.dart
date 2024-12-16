import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tadakir/View/Screens/EventListPage.dart';
import 'package:tadakir/View/Screens/SingInAndSingOut.dart';
import 'package:tadakir/View/ShowDialog/ShowDialog.dart';

class Splachscreencontroller extends GetxController {
  String baseUrl = "https://preprod.tadakir.net";

  // Function To check if tocken is exists or note
  Future<void> checkTokenIfValidOrNot(
      BuildContext context, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/mobile/profile'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token"
        },
      );
      if (!context.mounted) return;
      final dynamic responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.off(const EventListPage());
      } else if (response.statusCode == 401) {
        Get.off(const SinginandSingout());
      } else {
        showDialogForResponse(context, 'Error',
            'Unexpected response 1: ${responseBody["message"]}');
      }
    } catch (e) {
      if (context.mounted) {
        Get.off(const SinginandSingout());
      }
    }
  }
}
