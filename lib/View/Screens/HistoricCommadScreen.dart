import 'package:flutter/material.dart';

class HistoricCommadScreen extends StatefulWidget {
  const HistoricCommadScreen({super.key});

  @override
  State<HistoricCommadScreen> createState() => _HistoriccommadscreenState();
}

class _HistoriccommadscreenState extends State<HistoricCommadScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Historic Screen",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: const Column(
        children: [],
      ),
    );
  }
}
