import 'package:shared_preferences/shared_preferences.dart';

class Autheticationtoken {
  String getToken() {
    return "";
  }

  void setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  void deleteToken() {}
}
