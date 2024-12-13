import 'package:flutter/material.dart';

class SnackBarViewr {
  void showSnackBar(BuildContext context, String message, bool isError) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor:
          isError ? const Color.fromARGB(255, 211, 49, 58) : Colors.green,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.white,
        onPressed: () {},
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
