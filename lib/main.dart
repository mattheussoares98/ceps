import 'package:ceps/pages/add_or_update_cep_page.dart';
import 'package:ceps/pages/all_ceps_page.dart';
import 'package:ceps/providers/cep_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CepProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.purple[200],
          ),
        ),
        home: const AllCepsPage(),
        routes: {
          "addOrUpdatePage": (ctx) => const AddOrUpdateCepPage(),
        },
      ),
    );
  }
}
