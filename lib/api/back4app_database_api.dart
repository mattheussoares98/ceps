import "dart:convert";
import "package:ceps/models/cep_model.dart";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;

class Back4appDatabaseAPI {
  static const _url = "https://parseapi.back4app.com/classes/CEPs";
  static const _headers = {
    'X-Parse-Application-Id': 'K7xfYZNGnvv63dTQZOaI5faUiGBBkcRi5oyDL8Kl',
    'X-Parse-REST-API-Key': '2OVqgXBoHfIpo3WaiplCLWqoQubsUAiimHlKGpdF',
    'Content-Type': 'application/json'
  };

  static Future<bool> cepAlreadyRegistered({required int cep}) async {
    bool cepAlreadyRegistered = false;
    var request = http.Request(
        'GET',
        Uri.parse(
            'https://parseapi.back4app.com/classes/CEPs/?where={"cep":$cep}'));

    request.headers.addAll(_headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseInString = await response.stream.bytesToString();
      Map responseInMap = json.decode(responseInString);

      List results = responseInMap["results"] as List;
      if (results.isNotEmpty) {
        cepAlreadyRegistered = true;
      }
      debugPrint(responseInMap.toString());
    } else {
      debugPrint(response.reasonPhrase);
    }

    return cepAlreadyRegistered;
  }

  static Future<String> addCepAndReturnId({
    required CepModel cepModel,
  }) async {
    String idInBack4app = "";
    try {
      var request = http.Request('POST', Uri.parse(_url));
      request.body = json.encode(cepModel);
      request.headers.addAll(_headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 201) {
        String responseInString = await response.stream.bytesToString();
        Map responseInMap = json.decode(responseInString);

        idInBack4app = responseInMap["objectId"];
      } else {}
    } catch (e) {
      debugPrint("Erro para adicionar o CEP: $e");
    }

    return idInBack4app;
  }

  static Future<List<CepModel>> getCeps() async {
    List<CepModel> cepModels = [];

    try {
      var headers = {
        'X-Parse-Application-Id': 'K7xfYZNGnvv63dTQZOaI5faUiGBBkcRi5oyDL8Kl',
        'X-Parse-REST-API-Key': '2OVqgXBoHfIpo3WaiplCLWqoQubsUAiimHlKGpdF'
      };
      var request = http.Request(
          'GET', Uri.parse('https://parseapi.back4app.com/classes/CEPs'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseInString = await response.stream.bytesToString();
        Map responseInMap = json.decode(responseInString);

        List results = responseInMap["results"];

        for (var element in results) {
          cepModels.add(
            CepModel(
              estado: element["estado"],
              cep: element["cep"],
              logradouro: element["logradouro"],
              complemento: element["complemento"],
              bairro: element["bairro"],
              cidade: element["localidade"],
              numero: element["numero"],
              objectId: element["objectId"],
              referencia: element["referencia"],
            ),
          );
        }

        debugPrint(responseInString);
      } else {
        debugPrint(response.reasonPhrase);
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return cepModels;
  }

  static Future<bool> deleteCep({
    required String objectId,
  }) async {
    bool deletedCep = false;
    var request = http.Request('DELETE', Uri.parse('$_url/$objectId'));
    request.headers.addAll(_headers);

    try {
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        debugPrint(await response.stream.bytesToString());
        deletedCep = true;
      } else {
        debugPrint(response.reasonPhrase);
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return deletedCep;
  }

  static Future<bool> updateCep({
    required CepModel cepModel,
  }) async {
    bool isUpdated = false;

    try {
      var request = http.Request(
          'PUT',
          Uri.parse(
              'https://parseapi.back4app.com/classes/CEPs/${cepModel.objectId}'));
      request.body = json.encode(cepModel);
      request.headers.addAll(_headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseInString = await response.stream.bytesToString();
        isUpdated = true;
        debugPrint(responseInString);
      } else {
        debugPrint(response.reasonPhrase);
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return isUpdated;
  }
}
