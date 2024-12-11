import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:tadakir/Controller/ControllerSharedPrefrances.dart';
import 'package:tadakir/Controller/EventListPageController.dart';
import 'package:tadakir/View/Screens/CommandList.dart';
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

  @override
  void initState() {
    super.initState();
    eventListController.fetchEvents(context);
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
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(
              height: 50,
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
                Get.to(const CommandList());
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
