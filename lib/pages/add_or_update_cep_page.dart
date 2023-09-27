import 'package:ceps/components/loading_component.dart';
import 'package:ceps/components/personalized_formfield.dart';
import 'package:ceps/components/show_alert_dialog.dart';
import 'package:ceps/components/show_snackbar_message.dart';
import 'package:ceps/models/cep_model.dart';
import 'package:ceps/providers/cep_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddOrUpdateCepPage extends StatefulWidget {
  const AddOrUpdateCepPage({
    Key? key,
  }) : super(key: key);

  @override
  State<AddOrUpdateCepPage> createState() => _AddOrUpdateCepPageState();
}

class _AddOrUpdateCepPageState extends State<AddOrUpdateCepPage> {
  final GlobalKey<FormState> _adressFormKey = GlobalKey<FormState>();
  bool validate() {
    return _adressFormKey.currentState!.validate();
  }

  final FocusNode _cepFocusNode = FocusNode();
  final FocusNode _adressFocusNode = FocusNode();
  final FocusNode _districtFocusNode = FocusNode();
  final FocusNode _stateFocusNode = FocusNode();
  final FocusNode _cityFocusNode = FocusNode();
  final FocusNode _numberFocusNode = FocusNode();
  final FocusNode _complementFocusNode = FocusNode();
  final FocusNode _referenceFocusNode = FocusNode();
  String teste = "São Paulo";

  _getAdressByCep({
    required CepProvider cepProvider,
  }) async {
    if (cepProvider.cepController.text.length < 8) {
      ShowSnackbarMessage.showMessage(
        message: "O CEP deve conter 8 dígitos!",
        context: context,
      );

      FocusScope.of(context).requestFocus(_cepFocusNode);
      return;
    }

    await cepProvider.getAddressByCep(context: context);

    if (cepProvider.errorMessageGetAdressByCep == "") {
      Future.delayed(const Duration(milliseconds: 100), () {
        FocusScope.of(context).requestFocus(_numberFocusNode);
      });
    } else {
      // ignore: use_build_context_synchronously
      ShowSnackbarMessage.showMessage(
        message: "Erro para obter os dados. Insira os dados manualmente",
        context: context,
      );
    }
  }

  bool isLoaded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    CepProvider cepProvider = Provider.of(context, listen: true);

    if (!isLoaded) {
      updateControllers(cepProvider: cepProvider);

      isLoaded = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _cepFocusNode.dispose();
    _adressFocusNode.dispose();
    _districtFocusNode.dispose();
    _stateFocusNode.dispose();
    _cityFocusNode.dispose();
    _numberFocusNode.dispose();
    _complementFocusNode.dispose();
    _referenceFocusNode.dispose();
  }

  showSnackBar({
    required CepProvider cepProvider,
    required String errorMessage,
    Color? backgroundColor = Colors.red,
  }) {
    ShowSnackbarMessage.showMessage(
      message: errorMessage,
      context: context,
      backgroundColor: backgroundColor!,
    );
  }

  unfocus() {
    FocusScope.of(context).unfocus();
  }

  CepModel? cepModelFromArgumentsForUpdateData;
  updateControllers({
    required CepProvider cepProvider,
  }) {
    if (ModalRoute.of(context)?.settings.arguments != null) {
      Map data = ModalRoute.of(context)?.settings.arguments as Map;

      cepModelFromArgumentsForUpdateData = data["cepModel"];
      cepProvider.loadCepInformations(
          cepModel: cepModelFromArgumentsForUpdateData!);

      // objectId:
      // cepModel.objectId.toString();
      // referencia:
      // cepProvider.cepController.text = "";
    }
  }

  _addAdress({required CepProvider cepProvider}) async {
    bool cepIsAdded = await cepProvider.addCep();
    if (cepProvider.errorMessageAddAddres != "" && !cepIsAdded) {
      showSnackBar(
        cepProvider: cepProvider,
        errorMessage: cepProvider.errorMessageAddAddres,
      );
    } else {
      showSnackBar(
        cepProvider: cepProvider,
        errorMessage: "O CEP foi adicionado com sucesso",
        backgroundColor: Colors.green,
      );
      _closePage();
    }
    unfocus();
  }

  _closePage() {
    Navigator.of(context).pop();
  }

  _updateAdress({
    required CepProvider cepProvider,
  }) async {
    bool updatedCep = await cepProvider.updateCep(
      objectId: cepModelFromArgumentsForUpdateData!.objectId!,
    );
    if (cepProvider.errorMessageUpdateCep != "" && !updatedCep) {
      showSnackBar(
        cepProvider: cepProvider,
        errorMessage: cepProvider.errorMessageUpdateCep,
      );
    } else {
      _closePage();
      showSnackBar(
        cepProvider: cepProvider,
        errorMessage: "O endereço foi alterado com sucesso",
        backgroundColor: Colors.green,
      );
    }

    unfocus();
  }

  addOrUpdateCep({
    required CepProvider cepProvider,
  }) async {
    bool isValid = validate();

    if (isValid && cepProvider.cepController.text.isNotEmpty) {
      if (cepModelFromArgumentsForUpdateData == null) {
        await _addAdress(cepProvider: cepProvider);
      } else {
        await _updateAdress(cepProvider: cepProvider);
      }
    } else {
      ShowSnackbarMessage.showMessage(
        message: "Insira os dados corretamente para salvar o endereço",
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    CepProvider cepProvider = Provider.of(context, listen: true);

    return WillPopScope(
      onWillPop: () async {
        cepProvider.clearCepControllers();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            cepModelFromArgumentsForUpdateData == null
                ? "Adicionar endereço"
                : "Alterar endereço",
          ),
          leading: IconButton(
            onPressed: () {
              cepProvider.clearCepControllers();
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_outlined,
            ),
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Form(
                key: _adressFormKey,
                child: Column(
                  children: [
                    PersonalizedFormField(
                      keyboardType: TextInputType.number,
                      enabled: cepProvider.isAddingCep ? false : true,
                      focusNode: _cepFocusNode,
                      autoFocus: true,
                      onFieldSubmitted: cepProvider.isAddingCep
                          ? null
                          : (String? value) async {
                              await _getAdressByCep(
                                cepProvider: cepProvider,
                              );
                            },
                      labelText: "CEP",
                      textEditingController: cepProvider.cepController,
                      limitOfCaracters: 8,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return null;
                        } else if (value.length < 8) {
                          return "Quantidade de números inválido!";
                        } else if (value.contains(".") ||
                            value.contains(",") ||
                            value.contains("-") ||
                            value.contains(" ")) {
                          return "Digite somente números";
                        }
                        return null;
                      },
                      suffixWidget: TextButton(
                        onPressed: cepProvider.isAddingCep
                            ? null
                            : () async {
                                await _getAdressByCep(
                                  cepProvider: cepProvider,
                                );
                              },
                        child: cepProvider.isLoadingCeps
                            ? const FittedBox(
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 8.0),
                                      child: Text(
                                        "Pesquisando CEP",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: CircularProgressIndicator(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const Text("Pesquisar CEP"),
                      ),
                    ),
                    if (cepProvider.triedGetCep)
                      Column(
                        children: [
                          PersonalizedFormField(
                            enabled: cepProvider.isAddingCep ? false : true,
                            focusNode: _adressFocusNode,
                            labelText: "Logradouro",
                            textEditingController:
                                cepProvider.logradouroController,
                            limitOfCaracters: 40,
                            onFieldSubmitted: (value) {
                              FocusScope.of(context)
                                  .requestFocus(_districtFocusNode);
                            },
                            validator: (String? value) {
                              if ((value == null ||
                                      value.isEmpty ||
                                      value.length < 5) &&
                                  cepProvider.cepController.text.length == 8) {
                                return "Logradouro muito curto";
                              }
                              return null;
                            },
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: PersonalizedFormField(
                                  enabled:
                                      cepProvider.isAddingCep ? false : true,
                                  focusNode: _districtFocusNode,
                                  onFieldSubmitted: cepProvider.isAddingCep
                                      ? null
                                      : (String? value) {
                                          FocusScope.of(context)
                                              .requestFocus(_cityFocusNode);
                                        },
                                  labelText: "Bairro",
                                  textEditingController:
                                      cepProvider.bairroController,
                                  limitOfCaracters: 30,
                                  validator: (String? value) {
                                    if ((value == null ||
                                            value.isEmpty ||
                                            value.length < 2) &&
                                        cepProvider.cepController.text.length ==
                                            8) {
                                      return "Bairro muito curto";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Expanded(
                                child: PersonalizedFormField(
                                  enabled:
                                      cepProvider.isAddingCep ? false : true,
                                  focusNode: _cityFocusNode,
                                  labelText: "Cidade",
                                  textEditingController:
                                      cepProvider.cidadeController,
                                  limitOfCaracters: 30,
                                  onFieldSubmitted: (value) {
                                    FocusScope.of(context)
                                        .requestFocus(_stateFocusNode);
                                  },
                                  validator: (String? value) {
                                    if ((value == null ||
                                            value.isEmpty ||
                                            value.length < 2) &&
                                        cepProvider.cepController.text.length ==
                                            8) {
                                      return "Cidade muito curta";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: DropdownButtonFormField<dynamic>(
                                  focusNode: _stateFocusNode,
                                  value:
                                      cepProvider.selectedStateDropDown.value,
                                  isExpanded: true,
                                  hint: Center(
                                    child: Text(
                                      'Estado',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null &&
                                        cepProvider.cepController.text.length ==
                                            8) {
                                      return 'Selecione um estado!';
                                    }
                                    return null;
                                  },
                                  onChanged: cepProvider.isAddingCep
                                      ? null
                                      : (value) {
                                          cepProvider.selectedStateDropDown
                                              .value = value;
                                        },
                                  items: cepProvider.states
                                      .map(
                                        (value) => DropdownMenuItem(
                                          alignment: Alignment.center,
                                          onTap: () {},
                                          value: value,
                                          child: FittedBox(
                                            child: Column(
                                              children: [
                                                Center(
                                                  child: Text(
                                                    value,
                                                  ),
                                                ),
                                                const Divider(
                                                  color: Colors.black,
                                                  height: 4,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: PersonalizedFormField(
                                  keyboardType: TextInputType.number,
                                  enabled:
                                      cepProvider.isAddingCep ? false : true,
                                  focusNode: _numberFocusNode,
                                  onFieldSubmitted: cepProvider.isAddingCep
                                      ? null
                                      : (String? value) async {
                                          FocusScope.of(context).requestFocus(
                                              _complementFocusNode);
                                        },
                                  labelText: "Número",
                                  textEditingController:
                                      cepProvider.numeroController,
                                  limitOfCaracters: 6,
                                  validator: (String? value) {
                                    if ((value == null || value.isEmpty) &&
                                        cepProvider.cepController.text.length ==
                                            8) {
                                      return "Digite o número!";
                                    } else if (value!.contains(".") ||
                                        value.contains(",") ||
                                        value.contains("-") ||
                                        value.contains(" ")) {
                                      return "Digite somente números";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: PersonalizedFormField(
                                  enabled:
                                      cepProvider.isAddingCep ? false : true,
                                  focusNode: _complementFocusNode,
                                  onFieldSubmitted: cepProvider.isAddingCep
                                      ? null
                                      : (String? value) {
                                          FocusScope.of(context).requestFocus(
                                              _referenceFocusNode);
                                        },
                                  labelText: "Complemento",
                                  textEditingController:
                                      cepProvider.complementoController,
                                  limitOfCaracters: 30,
                                  validator: (String? value) {
                                    return null;
                                  },
                                ),
                              ),
                              Expanded(
                                child: PersonalizedFormField(
                                  enabled:
                                      cepProvider.isAddingCep ? false : true,
                                  focusNode: _referenceFocusNode,
                                  labelText: "Referência",
                                  textEditingController:
                                      cepProvider.referenciaController,
                                  limitOfCaracters: 40,
                                  validator: (String? value) {
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 8.0, left: 8, right: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  onPressed: () {
                                    ShowAlertDialog.showAlertDialog(
                                      context: context,
                                      title: "Apagar dados digitados",
                                      subtitle:
                                          "Deseja apagar todos os dados preenchidos?",
                                      function: () {
                                        cepProvider.clearCepControllers(
                                          clearCep: false,
                                          alreadyInAddOrUpdatePage: true,
                                        );
                                      },
                                    );
                                  },
                                  child: const Text(
                                    "Apagar dados",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  onPressed: cepProvider.isAddingCep
                                      ? null
                                      : () async {
                                          ShowAlertDialog.showAlertDialog(
                                            context: context,
                                            title:
                                                cepModelFromArgumentsForUpdateData ==
                                                        null
                                                    ? "Adicionar endereço"
                                                    : "Alterar endereço",
                                            subtitle: cepModelFromArgumentsForUpdateData ==
                                                    null
                                                ? "Deseja realmente cadastrar esse endereço?"
                                                : "Deseja realmente alterar esse endereço?",
                                            function: () async {
                                              await addOrUpdateCep(
                                                cepProvider: cepProvider,
                                              );
                                            },
                                          );
                                        },
                                  child: Text(
                                    cepModelFromArgumentsForUpdateData == null
                                        ? "Adicionar endereço"
                                        : "Alterar endereço",
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            if (cepProvider.isAddingCep)
              const LoadingComponent(message: "Adicionando CEP"),
            if (cepProvider.isUpdatingCep)
              const LoadingComponent(message: "Alterando CEP"),
          ],
        ),
      ),
    );
  }
}
