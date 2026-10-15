import 'dart:io';
import 'package:flutter/foundation.dart';
import '../data/model_store.dart';
import '../models/gen_params.dart';

class ModelsViewModel extends ChangeNotifier {
  ModelsViewModel(this._store);
  final ModelStore _store;

  List<File> files = [];
  File? active;
  String? downloading;
  double progress = 0;
  String? error;

  Future<void> refresh() async {
    files = await _store.installed();
    if (active == null || !files.any((f) => f.path == active!.path)) {
      active = files.isEmpty ? null : files.first;
    }
    notifyListeners();
  }

  Future<void> download(String name, String url, {String token = ''}) async {
    if (downloading != null) return;
    downloading = name;
    progress = 0;
    error = null;
    notifyListeners();
    try {
      await _store.download(url, name, token.trim(), (p) {
        progress = p;
        notifyListeners();
      });
    } catch (e) {
      error = 'Download failed: $e';
    }
    downloading = null;
    await refresh();
  }

  Future<void> downloadEntry(CatalogEntry e) => download(e.file, e.url);

  void select(File f) {
    active = f;
    notifyListeners();
  }

  Future<void> delete(File f) async {
    await f.delete();
    await refresh();
  }
}
