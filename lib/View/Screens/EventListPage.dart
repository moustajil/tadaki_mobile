import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:tadakir/Controller/API.dart';
import 'package:tadakir/Controller/ControllerSharedPrefrances.dart';
import 'package:tadakir/Controller/EventListPageController.dart';
import 'package:tadakir/View/Screens/HistoricCommadScreen.dart';
import 'package:tadakir/View/Screens/InformationOfCommand.dart';
import 'package:tadakir/View/Screens/ProfileInformation.dart';
import 'package:tadakir/View/Screens/SettingScreen.dart';
import 'package:tadakir/View/Screens/SingInWithEmail.dart';
import 'package:tadakir/View/Screens/SupportScreen.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final sharedPrefs = ControllerSharedPreferences();
  final eventListController = Eventlistpagecontroller();

  // Add a GlobalKey for ScaffoldState
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic> infoUser = {};
  bool isLoading = true; // Flag to check if user info is still loading
  bool ifCartExists = false;
  Map<String, dynamic>? myCart;

  @override
  void initState() {
    super.initState();
    checkCartIfExists();
    print("My carts is $myCart");
    _initializeData();
    eventListController.fetchEvents(context);
  }

  Future<void> _initializeData() async {
    try {
      String? token = await sharedPrefs.getToken();
      if (token == null || token.isEmpty) {
        throw Exception("User token is null or empty.");
      }

      // ignore: use_build_context_synchronously
      infoUser = await getInformationUser(context, token);
      setState(() {
        isLoading = false; // Set loading to false after data is fetched
      });

      // ignore: use_build_context_synchronously
      eventListController.fetchEvents(context);
    } catch (e) {
      // Handle errors or show a message
      print("Error initializing data: $e");
      setState(() {
        isLoading = false; // Set loading to false in case of error
      });
    }
  }

  Future<void> checkCartIfExists() async {
    String? token = await sharedPrefs.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("User token is missing.");
    }

    // ignore: use_build_context_synchronously
    final responseBody = await getCartIfExists(context, token);

    if (responseBody.isNotEmpty) {
      myCart = responseBody;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the GlobalKey to Scaffold
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.menu, // Sandwich menu icon
            color: Colors.black,
          ),
          onPressed: () {
            // Use the key to open the drawer
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Container(
          margin: const EdgeInsets.only(bottom: 15, top: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: "Search...",
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.black),
                onPressed: () {
                  Get.to(const Informationofcommand());
                },
              ),
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(
                        10), // Rounded corners for the counter
                  ),
                  child: const Text(
                    '10:00', // Replace with your dynamic counter value
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 211, 49, 58),
              ),
              child: isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator()) // Show loading indicator while data is being fetched
                  : infoUser.isEmpty
                      ? const Center(
                          child: Text(
                              "User Info not available")) // Show a message if infoUser is empty
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 40.0,

                              backgroundColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                              child: Text(
                                "${infoUser["nom"][0].substring(0, 1).toUpperCase() + infoUser["prenom"][0].substring(0, 1).toUpperCase() ?? 'User'}",
                                style: const TextStyle(
                                    fontSize: 30,
                                    color: Color.fromARGB(255, 211, 49, 58),
                                    fontWeight: FontWeight.bold),
                              ), // Show default text if "nom" is null
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "${infoUser["nom"] ?? 'No Name'} ${infoUser["prenom"] ?? ''}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${infoUser["email"] ?? 'No Email'}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
            ),
            //
            const SizedBox(
              height: 10,
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Ionicons.person),
              title: const Text('Profile'),
              onTap: () {
                Get.to(const Profileinformation());
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Historic'),
              onTap: () {
                Get.to(const HistoricCommadScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent_sharp),
              title: const Text('Support'),
              onTap: () {
                Get.to(const SupportScreens());
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Get.to(const Settingscreen());
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                sharedPrefs.saveToken("");
                Get.offAll(const SignInWithEmail());
              },
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF6F6F6),
      body: Obx(
        () => eventListController.events.isEmpty
            ? const Center(
                child: Text(
                  "No events available",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: eventListController.events.length,
                itemBuilder: (context, index) {
                  return eventListController.eventCard(
                    context: context,
                    clubLogo:
                        eventListController.events[index]['clubLogo'] ?? '',
                    clubVistoreLogo: eventListController.events[index]
                            ['clubVisitorLogo'] ??
                        '',
                    clubNomAr:
                        eventListController.events[index]['clubNomAr'] ?? '',
                    clubVisitoreNom: eventListController.events[index]
                            ['clubVisitorNomAr'] ??
                        '',
                    evenementPrix: eventListController.events[index]
                            ['evenementMinPrix'] ??
                        '',
                    dateOfEvenement: eventListController.events[index]
                            ['evenementDateEvent'] ??
                        '',
                    localisationEvenement: eventListController.events[index]
                            ['locationNomAr'] ??
                        '',
                    evenementId: eventListController.events[index]
                        ['evenementId'],
                    evenementName: eventListController.events[index]
                            ['evenementNomFr'] ??
                        '',
                  );
                },
              ),
      ),
    );
  }
}
