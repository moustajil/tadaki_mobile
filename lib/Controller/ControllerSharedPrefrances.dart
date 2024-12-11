import 'package:shared_preferences/shared_preferences.dart';

class ControllerSharedPreferences {
  // Save user data in SharedPreferences
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', 'Aimad');
    await prefs.setInt('age', 25);
    await prefs.setBool('isLoggedIn', true);
  }

  // Load user data from SharedPreferences
  Future<Map<String, dynamic>> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    int? age = prefs.getInt('age');
    bool? isLoggedIn = prefs.getBool('isLoggedIn');

    return {
      'username': username,
      'age': age,
      'isLoggedIn': isLoggedIn,
    };
  }

  // Save notification authentication response in SharedPreferences
  Future<void> saveAuthNotification(String response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authNotification', response);
  }

  // Get notification authentication response from SharedPreferences
  Future<String?> getResponseOfNotification() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authNotification');
  }

  // save Langauge
  Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("langauge", language);
  }

  //get language
  Future<String?> getLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("langauge");
  }

  //save email
  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("email", email);
  }

  //get email
  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("email");
  }

  //save token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  //get token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  //save otp
  Future<void> saveOtp(String myOpt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('otp', myOpt);
  }

  //get otp
  Future<String?> getOtp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('otp');
  }

  //save id Evenemenet v
  Future<void> saveIdEvenemetn(int idEvenement) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("evenementId", idEvenement);
  }

  //get id Evenement
  Future<int?> getIdEvenement() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("evenementId");
  }
}
