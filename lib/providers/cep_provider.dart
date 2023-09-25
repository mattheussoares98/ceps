import 'dart:convert';

import 'package:ceps/api/back4app_database_api.dart';
import 'package:ceps/components/show_snackbar_message.dart';
import 'package:ceps/models/cep_model.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class CepProvider with ChangeNotifier {
  static const Map<String, String> _states = {
    "AC": "Acre",
    "AL": "Alagoas",
    "AP": "Amapá",
    "AM": "Amazonas",
    "BA": "Bahia",
    "CE": "Ceará",
    "DF": "Distrito Federal",
    "ES": "Espírito Santo",
    "GO": "Goiás",
    "MA": "Maranhão",
    "MT": "Mato Grosso",
    "MS": "Mato Grosso do Sul",
    "MG": "Minas Gerais",
    "PA": "Pará",
    "PB": "Paraíba",
    "PR": "Paraná",
    "PE": "Pernambuco",
    "PI": "Piauí",
    "RJ": "Rio de Janeiro",
    "RN": "Rio Grande do Norte",
    "RS": "Rio Grande do Sul",
    "RO": "Rondônia",
    "RR": "Roraima",
    "SC": "Santa Catarina",
    "SP": "São Paulo",
    "SE": "Sergipe",
    "TO": "Tocantins",
  };

  List<String> get states => [..._states.values];

  final TextEditingController cepController = TextEditingController();
  final TextEditingController logradouroController = TextEditingController();
  final TextEditingController localidadeController = TextEditingController();
  final TextEditingController complementoController = TextEditingController();
  final TextEditingController referenciaController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final ValueNotifier<String?> _selectedStateDropDown =
      ValueNotifier<String?>(null);
  ValueNotifier<String?> get selectedStateDropDown => _selectedStateDropDown;
  set selectedStateDropDown(ValueNotifier<String?> newValue) {
    _selectedStateDropDown.value = newValue.value;
  }

  List<CepModel> _cepsList = [];
  List<CepModel> get cepsList => _cepsList;

  bool _isLoadingCeps = false;
  get isLoadingCeps => _isLoadingCeps;

  bool _isAddingCep = false;
  get isAddingCep => _isAddingCep;

  bool _triedGetCep = false;
  get triedGetCep => _triedGetCep;

  bool _isDeletingCep = false;
  get isDeletingCep => _isDeletingCep;

  String _errorMessageAddAddres = "";
  String get errorMessageAddAddres => _errorMessageAddAddres;

  String _errorMessageGetAdressByCep = "";
  String get errorMessageGetAdressByCep => _errorMessageGetAdressByCep;

  String _errorMessageDeleteCep = "";
  String get errorMessageDeleteCep => _errorMessageDeleteCep;

  Future<void> deleteCep({required String objectId}) async {
    _errorMessageDeleteCep = "";
    _isDeletingCep = true;
    notifyListeners();
    bool deleted = await Back4appDatabaseAPI.deleteCep(objectId: objectId);

    if (deleted) {
      _cepsList.removeWhere((element) => element.objectId == objectId);
    } else {
      _errorMessageDeleteCep = "Erro para excluir o CEP!";
    }

    _isDeletingCep = false;
    notifyListeners();
  }

  Future<void> addCep() async {
    _errorMessageAddAddres = "";
    _isAddingCep = true;
    notifyListeners();

    bool cepAlreadyRegistered = await Back4appDatabaseAPI.cepAlreadyRegistered(
        cep: int.parse(cepController.text));

    if (cepAlreadyRegistered) {
      _errorMessageAddAddres =
          "Esse endereço não pode ser cadastrado porque já possui um endereço cadastrado com esse CEP!";

      _isAddingCep = false;
      notifyListeners();
      return;
    }

    CepModel cepModel = CepModel(
      estado: selectedStateDropDown.value!,
      cep: int.parse(cepController.text),
      logradouro: logradouroController.text,
      complemento: complementoController.text,
      bairro: bairroController.text,
      localidade: localidadeController.text,
      numero: int.parse(numeroController.text),
      referencia: referenciaController.text,
    );

    String idInBack4app = await Back4appDatabaseAPI.addCepAndReturnId(
      cepModel: cepModel,
    );

    if (idInBack4app != "") {
      cepModel.objectId = idInBack4app;
      _cepsList.add(cepModel);
      clearCepControllers();
    }

    _triedGetCep = false;
    _isAddingCep = false;

    notifyListeners();
  }

  void updateCeps({required List<CepModel> cepList}) {
    _cepsList = cepsList;
    notifyListeners();
  }

  void loadCepInformations({
    required CepModel cepModel,
  }) {
    cepController.text = cepModel.cep.toString();
    logradouroController.text = cepModel.logradouro.toString();
    complementoController.text = cepModel.complemento.toString();
    localidadeController.text = cepModel.bairro.toString();
    numeroController.text = cepModel.numero.toString();
    referenciaController.text = cepModel.referencia.toString();
    _selectedStateDropDown.value = cepModel.estado.toString();
    bairroController.text = cepModel.bairro.toString();

    _triedGetCep = true;
  }

  Future<void> getAllRegisteredCeps() async {
    _isLoadingCeps = true;
    _cepsList.clear();
    _cepsList = await Back4appDatabaseAPI.getCeps();
    _isLoadingCeps = false;
    notifyListeners();
  }

  void clearCepControllers({bool? clearCep = true}) {
    if (clearCep == true) {
      cepController.text = "";
    }
    logradouroController.text = "";
    bairroController.text = "";
    complementoController.text = "";
    localidadeController.text = "";
    numeroController.text = "";
    referenciaController.text = "";
    _selectedStateDropDown.value = null;
    _triedGetCep = false; //para deixar somente o campo de CEP aberto
  }

  Future<void> getAddressByCep({
    required BuildContext context,
  }) async {
    clearCepControllers(clearCep: false);
    _errorMessageGetAdressByCep = "";
    _isLoadingCeps = true;
    notifyListeners();

    try {
      var request = http.Request(
        'GET',
        Uri.parse("https://viacep.com.br/ws/${cepController.text}/json/"),
      );

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseInString = await response.stream.bytesToString();
        Map responseInMap = json.decode(responseInString);

        CepModel.updateControllers(
          data: responseInMap,
          referenciaController: referenciaController,
          logradouroController: logradouroController,
          localidadeController: localidadeController,
          complementoController: complementoController,
          bairroController: bairroController,
          selectedStateDropDown: selectedStateDropDown,
          states: _states,
        );
        print(responseInMap);
      } else {
        print(response.reasonPhrase);
      }

      notifyListeners();
    } catch (e) {
      print("Erro para consultar o CEP: $e");
      _errorMessageGetAdressByCep =
          "Ocorreu um erro para consultar o CEP. Insira os dados do endereço manualmente";
    }

    _triedGetCep = true;
    _isLoadingCeps = false;
    notifyListeners();
  }
}
