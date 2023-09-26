import 'package:ceps/components/loading_component.dart';
import 'package:ceps/components/show_alert_dialog.dart';
import 'package:ceps/models/cep_model.dart';
import 'package:ceps/providers/cep_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllCepsPage extends StatefulWidget {
  const AllCepsPage({super.key});

  @override
  State<AllCepsPage> createState() => _AllCepsPageState();
}

class _AllCepsPageState extends State<AllCepsPage> {
  Future<void> getCeps({
    required CepProvider cepProvider,
  }) async {
    await cepProvider.getAllRegisteredCeps();
  }

  Widget titleAndSubtitle({
    Color? titleColor = Colors.black,
    Color? subtitleColor = Colors.black,
    Widget? otherWidget,
    String? title,
    double? fontSize = 17,
    String? subtitle,
  }) {
    return Row(
      children: <Widget>[
        Expanded(
          child: RichText(
            text: TextSpan(
              // style: _fontStyle(color: titleColor, fontSize: fontSize),
              children: <TextSpan>[
                TextSpan(
                  text: title == null ? "" : "$title: ",
                  style: TextStyle(
                    fontSize: fontSize,
                    color: titleColor,
                    fontFamily: 'OpenSans',
                  ),
                ),
                TextSpan(
                  text: subtitle ?? "",
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (otherWidget != null) otherWidget,
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
                          return ShowAlertDialog.showAlertDialog(
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (cepModel.cep != null)
                                  titleAndSubtitle(
                                    title: "CEP",
                                    subtitle: cepModel.cep.toString(),
                                    otherWidget: InkWell(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                          "addOrUpdatePage",
                                          arguments: {
                                            "cepModel": cepModel,
                                          },
                                        );
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.only(right: 8.0),
                                        child: Icon(
                                          Icons.edit,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (cepModel.numero != null)
                                  titleAndSubtitle(
                                    title: "Número",
                                    subtitle: cepModel.numero.toString(),
                                  ),
                                if (cepModel.estado != null)
                                  titleAndSubtitle(
                                    title: "Estado",
                                    subtitle: cepModel.estado.toString(),
                                  ),
                                if (cepModel.bairro != null)
                                  titleAndSubtitle(
                                    title: "Bairro",
                                    subtitle: cepModel.bairro.toString(),
                                  ),
                                if (cepModel.cidade != null)
                                  titleAndSubtitle(
                                    title: "Cidade",
                                    subtitle: cepModel.cidade.toString(),
                                  ),
                                if (cepModel.logradouro != null)
                                  titleAndSubtitle(
                                    title: "Logradouro",
                                    subtitle: cepModel.logradouro.toString(),
                                  ),
                                if (cepModel.complemento != "")
                                  titleAndSubtitle(
                                    title: "Complemento",
                                    subtitle: cepModel.complemento.toString(),
                                  ),
                                if (cepModel.referencia != "")
                                  titleAndSubtitle(
                                    title: "Referência",
                                    subtitle: cepModel.referencia.toString(),
                                    otherWidget: InkWell(
                                      onTap: () async {
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
                                      child: const Padding(
                                        padding: EdgeInsets.only(right: 8.0),
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
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
