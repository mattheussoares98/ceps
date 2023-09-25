import 'package:flutter/material.dart';

class LoadingComponent extends StatelessWidget {
  final String message;
  const LoadingComponent({
    required this.message,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(213, 205, 205, 0.7),
      height: double.infinity,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const CircularProgressIndicator(
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
