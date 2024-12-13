import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tadakir/Controller/ControllerSharedPrefrances.dart';
import 'package:tadakir/Controller/HistoricDataController.dart';
import 'package:tadakir/View/Screens/HistoricCommandDetaile.dart';

class HistoricCommadScreen extends StatefulWidget {
  const HistoricCommadScreen({super.key});

  @override
  State<HistoricCommadScreen> createState() => _HistoricCommadScreenState();
}

class _HistoricCommadScreenState extends State<HistoricCommadScreen> {
  // Observing the controller to reactively update the UI
  final HistoricDataController oldHistoricData =
      Get.put(HistoricDataController());
  final sharedPrefs = ControllerSharedPreferences();

  @override
  void initState() {
    super.initState();
    _getOldCarts(); // Call the method to fetch the data
  }

  Future<void> _getOldCarts() async {
    // Get the token from SharedPreferences
    String? token = await sharedPrefs.getToken();

    // Check if the token is null or not
    if (token != null && token.isNotEmpty) {
      // Token exists, proceed to fetch historical data
      // ignore: use_build_context_synchronously
      await oldHistoricData.getHistoricalData(context, token);
    } else {
      // Token is null or empty, handle accordingly
      print("Token is missing. Please log in.");
      if (context.mounted) {
        Get.snackbar(
          "Authentication Required",
          "Please log in to view historical data.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Widget buildOrderCard(Map<String, dynamic> orderDetails) {
    return GestureDetector(
      onTap: () {
        Get.to(HistoricCommandDetail(idOfOrder: orderDetails['id']));
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order ID: ${orderDetails["id"]}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Order Number: ${orderDetails["numOrer"] ?? "N/A"}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Created At: ${orderDetails["createdAt"] ?? "N/A"}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Expired At: ${orderDetails["expiredAt"] ?? "N/A"}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Category: ${orderDetails["categorieNomFr"] ?? "N/A"}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Amount: ${orderDetails["amount"] ?? "0"} MAD',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Historic Screen",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Obx(
        () {
          final dataList = oldHistoricData.oldHestoricalDataList;
          if (dataList.isEmpty) {
            return const Center(
              child: Text(
                "No events available",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dataList.length,
            itemBuilder: (context, index) {
              final item = dataList[index];
              return buildOrderCard(item);
            },
          );
        },
      ),
    );
  }
}
