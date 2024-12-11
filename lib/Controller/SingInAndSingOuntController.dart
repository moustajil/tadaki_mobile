import 'package:get/get.dart';

class SignInAndSignOutController extends GetxController {
  // Observable variable for the selected language
  var selectedLanguage = "English".obs;

  // Method to change the language
  void changeLanguage(String language) {
    selectedLanguage.value = language;
  }
}
