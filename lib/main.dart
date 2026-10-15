import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'data/model_store.dart';
import 'data/sd_runner.dart';
import 'viewmodels/create_viewmodel.dart';
import 'viewmodels/models_viewmodel.dart';
import 'views/home_screen.dart';

void main() {
  final models = ModelsViewModel(ModelStore())..refresh();
  final create = CreateViewModel(models, SdRunner());
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: models),
      ChangeNotifierProvider.value(value: create),
    ],
    child: MaterialApp(
      title: 'RV Studio',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: const HomeScreen(),
    ),
  ));
}
