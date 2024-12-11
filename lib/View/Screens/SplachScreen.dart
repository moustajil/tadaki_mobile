import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:tadakir/Controller/API.dart';
import 'package:tadakir/Controller/ControllerSharedPrefrances.dart';
import 'package:tadakir/Controller/InformationUserController.dart';
import 'package:tadakir/View/Screens/SingInAndSingOut.dart';

class SplachScreen extends StatefulWidget {
  const SplachScreen({super.key});

  @override
  State<SplachScreen> createState() => _SplachScreenState();
}

class _SplachScreenState extends State<SplachScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  var sharedPrefers = ControllerSharedPreferences();
  final infoUserController = Informationusercontroller();
  String? mytk;

  @override
  void initState() {
    super.initState();

    // Initialize AnimationController
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Define the animation
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Check token validity after a delay
    _initiateNavigation();
  }

  void _initiateNavigation() {
    Future.delayed(const Duration(seconds: 2), () async {
      final token = await sharedPrefers.getToken();

      if (token == null) {
        Get.to(const SinginandSingout());
      } else {
        // ignore: use_build_context_synchronously
        checkTokenIfValidOrNot(context, token);
        //getInformationUser(context, token);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 211, 49, 58),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(flex: 1),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _animation.value,
                  child: child,
                );
              },
              child: const Image(
                image: AssetImage('assets/images/logo-modern.webp'),
                width: 200,
              ),
            ),
            const Spacer(flex: 1),
            const Image(
              image: AssetImage('assets/images/sonarges.png'),
              width: 150,
            ),
            const Text(
              "Welcome to our ticket mobile app",
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}
