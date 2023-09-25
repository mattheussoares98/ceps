import 'package:ceps/api/back4app_database_api.dart';
import 'package:ceps/components/loading_component.dart';
import 'package:ceps/components/show_alert_dialog.dart';
import 'package:ceps/models/cep_model.dart';
import 'package:ceps/providers/cep_provider.dart';
import 'package:ceps/pages/add_or_update_cep_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllCepsPage extends StatefulWidget {
  const AllCepsPage({super.key});

  @override
  State<AllCepsPage> createState() => _AllCepsPageState();
}

TextStyle _titleStyle = const TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 15,
  fontStyle: FontStyle.italic,
);

TextStyle _subtitleStyle = const TextStyle(
  fontSize: 14,
);

class _AllCepsPageState extends State<AllCepsPage> {
  Future<void> getCeps({
    required CepProvider cepProvider,
  }) async {
    await cepProvider.getAllRegisteredCeps();
  }

  Widget titleAndSubtitule({
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Text("$title: ", style: _titleStyle),
        Text(subtitle, style: _subtitleStyle),
      ],
    );
  }

  bool _isLoaded = false;
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    CepProvider cepProvider = Provider.of(context, listen: false);
    if (!_isLoaded) {
      await getCeps(cepProvider: cepProvider);
      _isLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    CepProvider cepProvider = Provider.of(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "CEPs cadastrados",
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cepProvider.cepsList.length,
                  itemBuilder: (context, index) {
                    CepModel cepModel = cepProvider.cepsList[index];
                    return Padding(
                      padding: EdgeInsets.only(top: index == 0 ? 0 : 8.0),
                      child: Dismissible(
                        direction: DismissDirection.endToStart,
                        key: UniqueKey(),
                        confirmDismiss: (direction) async {
                          ShowAlertDialog.showAlertDialog(
                            context: context,
                            title: "Excluir CEP?",
                            function: () async {
                              await cepProvider.deleteCep(
                                  objectId: cepModel.objectId.toString());
                            },
                          );
                        },
                        background: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ],
                        ),
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(
                              color: Colors.black12,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (cepModel.cep != null)
                                      titleAndSubtitule(
                                        title: "CEP",
                                        subtitle: cepModel.cep.toString(),
                                      ),
                                    if (cepModel.numero != null)
                                      titleAndSubtitule(
                                        title: "Número",
                                        subtitle: cepModel.numero.toString(),
                                      ),
                                    if (cepModel.estado != null)
                                      titleAndSubtitule(
                                        title: "Estado",
                                        subtitle: cepModel.estado.toString(),
                                      ),
                                    if (cepModel.bairro != null)
                                      titleAndSubtitule(
                                        title: "Bairro",
                                        subtitle: cepModel.bairro.toString(),
                                      ),
                                    if (cepModel.complemento != null)
                                      titleAndSubtitule(
                                        title: "Complemento",
                                        subtitle:
                                            cepModel.complemento.toString(),
                                      ),
                                    if (cepModel.localidade != null)
                                      titleAndSubtitule(
                                        title: "Localidade",
                                        subtitle:
                                            cepModel.localidade.toString(),
                                      ),
                                    if (cepModel.logradouro != null)
                                      titleAndSubtitule(
                                        title: "Logradouro",
                                        subtitle:
                                            cepModel.logradouro.toString(),
                                      ),
                                    if (cepModel.complemento != "")
                                      titleAndSubtitule(
                                        title: "Complemento",
                                        subtitle:
                                            cepModel.complemento.toString(),
                                      ),
                                    if (cepModel.referencia != "")
                                      titleAndSubtitule(
                                        title: "Referência",
                                        subtitle:
                                            cepModel.referencia.toString(),
                                      ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.of(context).pushNamed(
                                          "addOrUpdatePage",
                                          arguments: {
                                            "cepModel": cepModel,
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.green,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        ShowAlertDialog.showAlertDialog(
                                          context: context,
                                          title: "Excluir CEP?",
                                          function: () async {
                                            await cepProvider.deleteCep(
                                                objectId: cepModel.objectId
                                                    .toString());
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (cepProvider.isDeletingCep)
            const LoadingComponent(message: "Excluindo CEP"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: FittedBox(
            child: Column(
              children: [
                Text("CEP"),
                Icon(Icons.add),
              ],
            ),
          ),
        ),
        onPressed: () {
          Navigator.of(context).pushNamed(
            "addOrUpdatePage",
          );
        },
      ),
    );
  }
}
