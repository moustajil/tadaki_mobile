import 'dart:convert';
import 'package:tadakir/Repository/AbstractRepository.dart';
import 'package:http/http.dart' as http;

class CartRepository extends AbstractRepository {
  // delete cart
  void deleteCart() async {
    await httpService.delete("/order/cart");
  }

// get cart
  Future<Map<String, dynamic>> getCart() async {
    http.Response response = await httpService.get("/order/cart");
    return jsonDecode(response.body);
  }

  // create order
  Future<Map<String, dynamic>> createCart(int ect, int qte) async {
    http.Response response = await httpService.post("/order", {
      ect: ect,
      qte: qte,
    });

    return jsonDecode(response.body);
  }
}
