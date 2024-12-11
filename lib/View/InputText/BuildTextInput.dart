import 'package:flutter/material.dart';

class BuildTextInput {
  Widget buildInputField(
      String label, String hintText, TextEditingController txe,
      {VoidCallback? onIconTap}) {
    // Common decoration
    InputDecoration inputDecoration = InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      border: const UnderlineInputBorder(),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color.fromARGB(255, 146, 23, 23)),
      ),
    );

    // Label Text Style
    TextStyle labelStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );

    // Conditional widget logic
    if (label == "Date of birth") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: 5),
          Row(
            children: [
              GestureDetector(
                onTap: onIconTap,
                child: const Icon(
                  Icons.cake, // Birthday icon
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 10), // Spacing between icon and text field
              Expanded(
                child: TextField(
                  controller: txe,
                  readOnly: true, // Makes the field non-editable
                  decoration: inputDecoration,
                  onTap: onIconTap, // Opens date picker on text field tap
                ),
              ),
            ],
          ),
        ],
      );
    } else if (label == "Phone") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: 5),
          TextField(
            keyboardType: TextInputType.phone,
            controller: txe,
            decoration: inputDecoration,
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: 5),
          TextField(
            controller: txe,
            decoration: inputDecoration,
          ),
        ],
      );
    }
  }
}
