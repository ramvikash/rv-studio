import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';

import '../data/sd_runner.dart';
import '../models/gen_params.dart';
import 'models_viewmodel.dart';

class CreateViewModel extends ChangeNotifier {
  CreateViewModel(this._models, this._runner);
  final ModelsViewModel _models;
  final SdRunner _runner;

  final GenParams p = GenParams();
  bool running = false;
  int step = 0;
  String? error;
  List<File> latest = [];

  void set(VoidCallback change) {
    change();
    notifyListeners();
  }

  Future<void> generate() async {
    final model = _models.active;
    if (running) return;
    if (model == null) {
      error = 'Download or select a model in the Models tab first.';
      notifyListeners();
      return;
    }
    if (p.prompt.trim().isEmpty) {
      error = 'Write a prompt first.';
      notifyListeners();
      return;
    }
    running = true;
    error = null;
    step = 0;
    latest = [];
    if (!(p.lockSeed && p.seed >= 0)) p.seed = Random().nextInt(1 << 31);
    notifyListeners();
    try {
      latest = await _runner.run(p, model.path, onProgress: (s, _) {
        step = s;
        notifyListeners();
      });
      if (latest.isEmpty) error = 'No image was produced.';
    } catch (e) {
      error = '$e';
    }
    running = false;
    notifyListeners();
  }

  void stop() => _runner.stop();
}
