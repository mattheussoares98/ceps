import 'package:flutter/material.dart';

class CepModel {
  int? cep;
  String? logradouro;
  String? complemento;
  String? bairro;
  String? cidade;
  int? numero;
  String? objectId;
  String? referencia;
  String? estado;

  CepModel({
    required this.cep,
    required this.logradouro,
    required this.complemento,
    required this.bairro,
    required this.cidade,
    required this.estado,
    required this.numero,
    this.referencia,
    this.objectId,
  });

  static updateControllers({
    required Map data,
    required TextEditingController logradouroController,
    required TextEditingController cidadeController,
    required TextEditingController complementoController,
    required TextEditingController bairroController,
    required TextEditingController referenciaController,
    required ValueNotifier<String?> selectedStateDropDown,
    required Map<String, String> states,
  }) {
    logradouroController.text = data["logradouro"];
    complementoController.text = data["complemento"];
    referenciaController.text = data["referencia"] ?? "";
    cidadeController.text = data["localidade"];
    bairroController.text = data["bairro"];
    selectedStateDropDown.value = states[data["uf"]];
  }

  fromJson(Map<String, dynamic> json) {
    CepModel(
      estado: json['uf'],
      numero: 0,
      cep: json['cep'],
      logradouro: json['logradouro'],
      complemento: json['complemento'],
      referencia: json['referencia'] ?? "",
      bairro: json['bairro'],
      cidade: json['localidade'],
      objectId: json['objectId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['cep'] = cep;
    data['logradouro'] = logradouro;
    data['complemento'] = complemento;
    data['referencia'] = referencia ?? "";
    data['bairro'] = bairro;
    data['localidade'] = cidade;
    data["numero"] = numero;
    data["estado"] = estado;

    return data;
  }
}
