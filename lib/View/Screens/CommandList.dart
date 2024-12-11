import 'package:flutter/material.dart';

class CommandList extends StatefulWidget {
  const CommandList({super.key});

  @override
  State<CommandList> createState() => _TickeslistState();
}

class _TickeslistState extends State<CommandList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "List Of command",
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
    );
  }
}
