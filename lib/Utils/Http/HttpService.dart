import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tadakir/Controller/ControllerSharedPrefrances.dart';
import 'package:tadakir/Exceptions/NotAuthenticatedException.dart';

class HttpService {
  static var sdfsfresponse = http.Response;

  Future<http.Response> get(String uri) async {
    http.Response response = await http.get(_parseUri(uri), headers: {
      "Accept": "application/json",
      "Authorization": "Bearer ${await _getAuthToken()}"
    });
    _checkStatusCode(response);
    return response;
  }

  Future<http.Response> delete(String uri) async {
    http.Response response = await http.delete(_parseUri(uri), headers: {
      "Accept": "application/json",
      "Authorization": "Bearer ${await _getAuthToken()}",
    });
    _checkStatusCode(response);
    return response;
  }

  Future<http.Response> post(String uri, dynamic data) async {
    http.Response response =
        await http.post(_parseUri(uri), body: jsonEncode(data), headers: {
      "Accept": "application/json",
      "Authorization": "Bearer ${await _getAuthToken()}",
    });
    _checkStatusCode(response);
    return response;
  }

  Future<http.Response> put(String uri, dynamic data) async {
    http.Response response =
        await http.put(_parseUri(uri), body: jsonEncode(data), headers: {
      "Accept": "application/json",
      "Authorization": "Bearer ${await _getAuthToken()}",
    });
    _checkStatusCode(response);
    return response;
  }

// helper
  Uri _parseUri(String uri) {
    if (!uri.startsWith("/")) throw Exception();
    return Uri.parse("https://preprod.tadakir.net/api/mobile$uri");
  }

  Future<String> _getAuthToken() async {
    String? token = await (ControllerSharedPreferences()).getToken();
    return token ?? "";
  }

  void _checkStatusCode(http.Response response) {
    if (response.statusCode == 401) throw NotAuthenticatedException;
  }
}
