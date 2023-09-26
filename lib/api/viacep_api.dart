import "package:flutter/material.dart";
import "package:http/http.dart" as http;

class ViacepAPI {
  static Future<void> getAdressFromCep({required int cep}) async {
    var request =
        http.Request('POST', Uri.parse("https://viacep.com.br/ws/$cep/json/"));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String repsonseInString = await response.stream.bytesToString();

      debugPrint(repsonseInString);

      // CepModel(
      //   cep: cep,
      //   logradouro: logradouro,
      //   complemento: complemento,
      //   bairro: bairro,
      //   localidade: localidade,
      // );
    } else {
      debugPrint(response.reasonPhrase);
    }
  }
}
