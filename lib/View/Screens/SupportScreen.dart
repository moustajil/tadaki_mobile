import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreens extends StatefulWidget {
  const SupportScreens({super.key});

  @override
  State<SupportScreens> createState() => _SupportScreensState();
}

class _SupportScreensState extends State<SupportScreens> {
  // Define the support phone number
  final String supportPhoneNumber = '0676663557'; // Replace with actual number

  // Method to launch the phone dialer
  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: supportPhoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $supportPhoneNumber')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true, // Center the title
        title: const Text(
          'Support',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Icon(
              Icons.support_agent_outlined,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 15),
            const Text(
              "Support en ligne 24H/24, 7J/7",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 211, 49, 58),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 211, 49, 58),
                      width: 2,
                    ),
                  ),
                ),
                onPressed: _launchPhone,
                child: const Text(
                  'Call',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
