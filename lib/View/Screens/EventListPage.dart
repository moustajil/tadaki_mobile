import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:tadakir/Controller/ControllerSharedPrefrances.dart';
import 'package:tadakir/Controller/EventListPageController.dart';
import 'package:tadakir/Controller/InformationofCommandController.dart';
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
  final eventListController = Get.put(Eventlistpagecontroller());
  final infoController = Get.put(InformationofCommandController());

  Map<String, dynamic>? commandDetail;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Timer _timer;
  int _remainingSeconds = 0;
  String _formattedTime = "";
  DateTime currentTime = DateTime.now();
  DateTime? expiredAt;

  @override
  void initState() {
    super.initState();
    _fetchDetailCommand();
    eventListController.initializeData(context);
    eventListController.fetchEvents(context);
  }

  Future<void> _fetchDetailCommand() async {
    try {
      String? token = await sharedPrefs.getToken();

      if (token == null || token.isEmpty) {
        print("Token is null or empty");
        return;
      }

      final responseBody = await infoController.getCartIfExists(context, token);

      if (mounted) {
        setState(() {
          commandDetail = responseBody;
          if (commandDetail != null && commandDetail!["expiredAt"] != null) {
            expiredAt = DateTime.parse(commandDetail!["expiredAt"]);
            final difference = expiredAt!.difference(currentTime);
            _remainingSeconds = difference.inSeconds;
            _formattedTime = _formatTime(_remainingSeconds);
            _startTimer();
          }
        });
      }
    } catch (e) {
      print("Error fetching command details: $e");
    }
  }

  void _startTimer() {
    const oneSecond = Duration(seconds: 1);

    _timer = Timer.periodic(oneSecond, (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
          _formattedTime = _formatTime(_remainingSeconds);
        });
      } else {
        timer.cancel();
        print("Timer ended");
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.black,
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.black),
                onPressed: () {
                  Get.to(() => const Informationofcommand());
                },
              ),
              if (_remainingSeconds > 0)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Obx(
                        () => Text(
                          _formattedTime,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Obx(
              () => DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 211, 49, 58),
                ),
                child: eventListController.isLoading.value
                    ? const Center(
                        child:
                            CircularProgressIndicator()) // Show loading indicator while data is being fetched
                    : eventListController.infoUser.isEmpty
                        ? const Center(
                            child: Text(
                                "User Info not available")) // Show a message if infoUser is empty
                        : Obx(
                            () => Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 40.0,

                                  backgroundColor:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  child: Text(
                                    "${eventListController.infoUser["nom"][0].substring(0, 1).toUpperCase() + eventListController.infoUser["prenom"][0].substring(0, 1).toUpperCase() ?? 'User'}",
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
                                  "${eventListController.infoUser["nom"] ?? 'No Name'} ${eventListController.infoUser["prenom"] ?? ''}",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${eventListController.infoUser["email"] ?? 'No Email'}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
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
      body: Container(
        color: Colors.white,
        child: Obx(
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
      ),
    );
  }
}
