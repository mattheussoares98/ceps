import 'package:flutter/material.dart';

class ShowAlertDialog {
  static showAlertDialog({
    required BuildContext context,
    required String title,
    required Function() function,
    String? subtitle,
    double? titleSize = 30,
    double? subtitleSize = 20,
    String? confirmMessage = "SIM",
    String? cancelMessage = "NÃO",
    double? confirmMessageSize = 40,
    double? cancelMessageSize = 40,
    bool? showConfirmAndCancelMessage = true,
    bool? showCloseAlertDialogButton = false,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: titleSize,
            ),
          ),
          content: subtitle == null
              ? null
              : Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: subtitleSize,
                  ),
                  textAlign: TextAlign.center,
                ),
          actionsPadding: const EdgeInsets.all(10),
          actions: [
            if (showConfirmAndCancelMessage == true)
              FittedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        function();
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 30,
                          horizontal: 30,
                        ),
                        child: Text(
                          confirmMessage!,
                          style: TextStyle(
                            fontSize: confirmMessageSize,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 50),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          )),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 30,
                          horizontal: 30,
                        ),
                        child: Text(
                          cancelMessage!,
                          style: TextStyle(
                            fontSize: cancelMessageSize,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (showCloseAlertDialogButton == true)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Fechar"),
              ),
          ],
        );
      },
    );
  }
}
