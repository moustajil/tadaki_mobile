import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tadakir/Controller/ControllerSharedPrefrances.dart';
import 'package:tadakir/Controller/HistoricDataController.dart';

class HistoricCommadScreen extends StatefulWidget {
  const HistoricCommadScreen({super.key});

  @override
  State<HistoricCommadScreen> createState() => _HistoriccommadscreenState();
}

class _HistoriccommadscreenState extends State<HistoricCommadScreen> {
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
      oldHistoricData.getHistoricalData(context, token);
    } else {
      // Token is null or empty, handle accordingly (e.g., show an error, navigate to login)
      print("Token is missing. Please log in.");
      // Or navigate to login screen
      // Get.to(() => LoginScreen());
    }
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
      body: Column(
        children: [
          // Using Obx to reactively update based on data change
          Obx(
            () => oldHistoricData.oldHestoricalDataList.isEmpty
                ? const Center(
                    child: Text(
                      "No events available",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: oldHistoricData
                        .oldHestoricalDataList.length, // Correct itemCount
                    itemBuilder: (context, index) {
                      return oldHistoricData.eventCard(
                        context: context,
                        clubLogo: oldHistoricData.oldHestoricalDataList[index]
                                ['clubLogo'] ??
                            '',
                        clubVistoreLogo:
                            oldHistoricData.oldHestoricalDataList[index]
                                    ['clubVisitorLogo'] ??
                                '',
                        clubNomAr: oldHistoricData.oldHestoricalDataList[index]
                                ['clubNomAr'] ??
                            '',
                        clubVisitoreNom:
                            oldHistoricData.oldHestoricalDataList[index]
                                    ['clubVisitorNomAr'] ??
                                '',
                        evenementPrix:
                            oldHistoricData.oldHestoricalDataList[index]
                                    ['evenementMinPrix'] ??
                                '',
                        dateOfEvenement:
                            oldHistoricData.oldHestoricalDataList[index]
                                    ['evenementDateEvent'] ??
                                '',
                        localisationEvenement:
                            oldHistoricData.oldHestoricalDataList[index]
                                    ['locationNomAr'] ??
                                '',
                        evenementId: oldHistoricData
                            .oldHestoricalDataList[index]['evenementId'],
                        evenementName:
                            oldHistoricData.oldHestoricalDataList[index]
                                    ['evenementNomFr'] ??
                                '',
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
