import "package:ceps/models/cep_model.dart";
import "package:http/http.dart" as http;

class ViacepAPI {
  static Future<void> getAdressFromCep({required int cep}) async {
    var request =
        http.Request('POST', Uri.parse("https://viacep.com.br/ws/$cep/json/"));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());

      // CepModel(
      //   cep: cep,
      //   logradouro: logradouro,
      //   complemento: complemento,
      //   bairro: bairro,
      //   localidade: localidade,
      // );
    } else {
      print(response.reasonPhrase);
    }
  }
}
