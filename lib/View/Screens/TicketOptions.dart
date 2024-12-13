import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:ionicons/ionicons.dart';
import 'package:tadakir/Controller/API.dart';
import 'package:tadakir/Controller/ControllerSharedPrefrances.dart';
import 'package:tadakir/Controller/TicketOptionsController.dart';
import 'package:tadakir/View/ShowDialog/ShowDialog.dart';
import 'package:xml/xml.dart';

class TicketOptions extends StatefulWidget {
  final int evenementId;

  const TicketOptions({super.key, required this.evenementId});

  @override
  State<TicketOptions> createState() => _TicketOptionsState();
}

class _TicketOptionsState extends State<TicketOptions> {
  final ticketOption = Ticketoptionscontroller();
  final sharedPrefs = ControllerSharedPreferences();
  final String svgAssetPath = 'assets/images/STADE.svg';
  XmlDocument? document;
  List<Map<String, String>> tribuneElements = [];

  @override
  void initState() {
    super.initState();

    ticketOption.fetchEventSelected(context, widget.evenementId);
    //printIdEvenement();
    _loadSvgContent();
    _fetchCategory();
  }

  Future<void> _loadSvgContent() async {
    try {
      // Load and parse the SVG file
      final svgString = await rootBundle.loadString(svgAssetPath);
      document = XmlDocument.parse(svgString);

      // Filter elements with the `data-tribune` attribute
      final elements = document?.findAllElements('path').toList() ??
          [] + (document?.findAllElements('rect').toList() ?? []);

      final filteredElements = elements.where((element) {
        return element.getAttribute('data-tribune') != null;
      });

      // Extract the attributes of the filtered elements
      final attributes = filteredElements.map((element) {
        final attributeMap = <String, String>{};
        for (var attribute in element.attributes) {
          attributeMap[attribute.name.toString()] = attribute.value;
        }
        return attributeMap;
      }).toList();

      // Update the state with the filtered elements
      setState(() {
        tribuneElements = attributes;
      });
    } catch (e) {
      debugPrint('Error loading SVG: $e');
    }
  }

  // void printIdEvenement() async {
  //   int? id = await sharedPrefs.getIdEvenement();
  //   print(id);
  // }

  List<Map<String, dynamic>> eventsCategory = [];

  Future<void> _fetchCategory() async {
    try {
      // Get the token
      String? token =
          await sharedPrefs.getToken(); // Make sure getToken is async

      // Print the event ID

      // Fetch event category data
      await getCategoryOfEvenement(
              // ignore: use_build_context_synchronously
              context,
              token!,
              "47")
          .then((responseBody) {
        setState(() {
          eventsCategory = responseBody;
        });
      });
      print(
          "============================================${eventsCategory.length}");
    } catch (e) {
      print("Error fetching events: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Options'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    child: Obx(
                      () {
                        if (ticketOption.myEvenet.isNotEmpty) {
                          return ticketOption.eventCard(
                            clubLogo: ticketOption.myEvenet["clubLogo"] ?? "",
                            clubVistoreLogo:
                                ticketOption.myEvenet["clubVisitorLogo"] ?? "",
                            clubNomAr: ticketOption.myEvenet["clubNomAr"] ?? "",
                            clubVisitoreNom:
                                ticketOption.myEvenet["clubVisitorNomFr"] ?? "",
                            evenementPrix:
                                ticketOption.myEvenet["evenementMinPrix"] ?? "",
                            dateOfEvenement:
                                ticketOption.myEvenet["evenementDateEvent"] ??
                                    "",
                            localisationEvenement:
                                ticketOption.myEvenet["locationNomFr"] ?? "",
                            evenementId: widget.evenementId,
                            evenementName:
                                ticketOption.myEvenet["evenementNomFr"] ?? "",
                            context: context,
                          );
                        } else {
                          return const CircularProgressIndicator(); // Show loading until data is fetched
                        }
                      },
                    ),
                  ),
                  if (document != null)
                    SvgPicture.string(
                      document!.toXmlString(),
                      width: 500,
                      height: 300,
                    )
                  else
                    const CircularProgressIndicator(),
                  ListView.builder(
                    itemCount: eventsCategory.length,
                    shrinkWrap:
                        true, // Important to allow the ListView to be nested
                    itemBuilder: (context, index) {
                      final event = eventsCategory[index];
                      final List<dynamic> categories =
                          event["categories"]; // Access the categories list

                      return ListView.builder(
                        itemCount: categories
                            .length, // Loop over categories for the current event
                        shrinkWrap:
                            true, // Important to allow the nested ListView to be scrollable
                        itemBuilder: (context, categoryIndex) {
                          final category = categories[categoryIndex];

                          final color =
                              category['evenementCategorieTicketColor'] ??
                                  '#FFFFFF';
                          final categoryName =
                              category['categorieTicketNom'] ?? 'Unknown';
                          final price = category['evenementCategorieTicketPrix']
                                  ?.toString() ??
                              '0';
                          final quantity =
                              category['quantity']?.toString() ?? '0';

                          return Category(
                              color,
                              categoryName,
                              price,
                              quantity,
                              "hello word",
                              category['evenementCategorieTicketId']);
                        },
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget Category(String? colorOfCategory, String? category, String? prix,
      String? qt, String? event, int id) {
    if (colorOfCategory == null ||
        category == null ||
        prix == null ||
        qt == null ||
        event == null) {
      return const Center(child: Text("Data missing"));
    }

    // Validate and convert color
    Color categoryColor;
    try {
      categoryColor = Color(int.parse(colorOfCategory.replaceAll('#', '0xFF')));
    } catch (e) {
      return const Center(child: Text("Invalid color format"));
    }

    // Validate price and quantity
    final double? price = double.tryParse(prix);
    final int? quantity = int.tryParse(qt);
    if (price == null || quantity == null) {
      return const Center(child: Text("Invalid price or quantity"));
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    category,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "${price.toStringAsFixed(2)} DH",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                SizedBox(
                    width: 90,
                    height: 30,
                    child: QtCategory(qt, context, colorOfCategory, category,
                        prix, event, id)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names

  // ignore: non_constant_identifier_names
  Widget QtCategory(String qtTickts, BuildContext context, String ColorCategory,
      String category, String price, String event, int id) {
    // Parse quantity with error handling
    final int? myInt = int.tryParse(qtTickts);
    if (myInt == null) {
      return const Center(
        child: Text(
          "Invalid quantity",
          style:
              TextStyle(color: Color.fromARGB(255, 211, 49, 58), fontSize: 12),
        ),
      );
    }

    if (myInt == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 30,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 139, 137, 137),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sold Out',
                    style: TextStyle(
                        color: Color.fromARGB(255, 204, 201, 201),
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Ionicons.ticket,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return GestureDetector(
        onTap: () {
          {
            ShowDialogQt(context, ColorCategory, category, price, event, id);
          }
        },
        child: Container(
          width: 90,
          height: 30,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 211, 49, 58),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Acheter',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
                SizedBox(width: 2),
                Icon(
                  Ionicons.ticket,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
