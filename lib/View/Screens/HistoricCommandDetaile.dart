import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tadakir/Controller/ControllerSharedPrefrances.dart';
import 'package:tadakir/Controller/HistoricDataController.dart';

class HistoricCommandDetail extends StatefulWidget {
  final int idOfOrder;

  const HistoricCommandDetail({super.key, required this.idOfOrder});

  @override
  State<HistoricCommandDetail> createState() => _HistoricCommandDetailState();
}

class _HistoricCommandDetailState extends State<HistoricCommandDetail> {
  final ControllerSharedPreferences sharedPrefs = ControllerSharedPreferences();
  final HistoricDataController oldHistoricData =
      Get.put(HistoricDataController());

  Map<String, dynamic> commandDetail = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getOldCarts();
    await _getOldDataOfTickets();
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
      if (context.mounted) {
        Get.snackbar(
          "Authentication Required",
          "Please log in to view historical data.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Future<void> _getOldDataOfTickets() async {
    for (dynamic item in oldHistoricData.oldHestoricalDataList) {
      if (item["id"] == widget.idOfOrder) {
        setState(() {
          commandDetail = item;
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Command Info",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              const Text(
                "Order Details",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "Category: ${commandDetail["categorieNomFr"]}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Table(
                      border: TableBorder.all(color: Colors.grey.shade300),
                      children: [
                        const TableRow(children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Price",
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Quantity",
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Total",
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              commandDetail["tickets"] != null &&
                                      commandDetail["tickets"].isNotEmpty
                                  ? "${commandDetail["amount"] / commandDetail["tickets"].length} MAD"
                                  : "N/A",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "${commandDetail["tickets"].length}",
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "${commandDetail["amount"]} MAD",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Table(
                        defaultColumnWidth: const IntrinsicColumnWidth(),
                        border: TableBorder.all(color: Colors.grey.shade300),
                        children: [
                          const TableRow(
                            decoration: BoxDecoration(color: Colors.red),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Secteur",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Range",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Seige",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Porte",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          if (commandDetail["tickets"] != null)
                            ...commandDetail["tickets"].map<TableRow>((ticket) {
                              return TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      ticket["secteur"] ?? "N/A",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      ticket["range"] ?? "N/A",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      ticket["siege"] ?? "N/A",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      ticket["porte"] ?? "N/A",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30)
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildOrderRow({
  required String event,
  required String category,
  required String price,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            event,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            category,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(price),
        ),
      ],
    ),
  );
}
