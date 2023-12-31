import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PersonalizedFormField extends StatelessWidget {
  final int? limitOfCaracters;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final Widget? suffixWidget;
  final bool? isDate;
  final String labelText;
  final TextEditingController textEditingController;
  final bool enabled;
  final bool? autoFocus;
  const PersonalizedFormField({
    this.onChanged,
    this.autoFocus = false,
    this.keyboardType,
    this.isDate,
    this.suffixWidget,
    this.onFieldSubmitted,
    this.focusNode,
    this.validator,
    this.limitOfCaracters,
    required this.enabled,
    required this.textEditingController,
    required this.labelText,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 12, right: 8),
      child: TextFormField(
        autofocus: autoFocus!,
        enabled: enabled,
        controller: textEditingController,
        keyboardType: keyboardType ?? TextInputType.name,
        maxLines: null,
        onChanged: onChanged,
        inputFormatters: limitOfCaracters == null
            ? null
            : isDate != null
                ? [
                    _DateInputFormatter(),
                    LengthLimitingTextInputFormatter(limitOfCaracters),
                  ]
                : [
                    LengthLimitingTextInputFormatter(limitOfCaracters),
                  ],
        focusNode: focusNode,
        onFieldSubmitted: onFieldSubmitted,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontFamily: 'OpenSans',
          decorationColor: Colors.black,
          color: Colors.black,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          suffixIcon: suffixWidget ?? suffixWidget,
          labelStyle: TextStyle(
            color: Theme.of(context)
                .colorScheme
                .primary, // Use a cor primária do tema
          ),
          labelText: labelText,
          counterStyle: TextStyle(
            color: Theme.of(context)
                .colorScheme
                .primary, // Use a cor primária do tema
          ),
        ),
      ),
    );
  }
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    final newText = StringBuffer();
    int selectionIndex = newValue.selection.end;

    if (text.isNotEmpty) {
      // Remove caracteres não numéricos
      final cleanText = text.replaceAll(RegExp(r'[^\d]'), '');

      // Adiciona os números com as barras na posição correta
      for (int i = 0; i < cleanText.length; i++) {
        if (i == 2 || i == 4) {
          // Adiciona barras nas posições 2 e 4
          newText.write('/');
          if (selectionIndex >= i) {
            selectionIndex++;
          }
        }
        newText.write(cleanText[i]);
        if (selectionIndex >= i) {
          selectionIndex++;
        }
      }
    }

    // Mantém o cursor no último índice, mesmo ao digitar
    selectionIndex = newText.length;

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
