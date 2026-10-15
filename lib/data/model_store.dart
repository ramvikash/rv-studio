import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ModelStore {
  Future<Directory> dir() async {
    final d = Directory('${(await getApplicationSupportDirectory()).path}/models');
    await d.create(recursive: true);
    return d;
  }

  Future<List<File>> installed() async => (await dir())
      .listSync()
      .whereType<File>()
      .where((f) => RegExp(r'\.(safetensors|ckpt|gguf)$').hasMatch(f.path))
      .toList();

  Future<void> download(String url, String name, String token,
      void Function(double) onProgress) async {
    final d = await dir();
    final client = http.Client();
    try {
      final req = http.Request('GET', Uri.parse(url));
      if (token.isNotEmpty) req.headers['Authorization'] = 'Bearer $token';
      final res = await client.send(req);
      if (res.statusCode != 200) throw 'HTTP ${res.statusCode} (check the link, or the token for gated models)';
      final part = File('${d.path}/$name.part');
      final sink = part.openWrite();
      var got = 0;
      final total = res.contentLength ?? 0;
      await for (final c in res.stream) {
        sink.add(c);
        got += c.length;
        if (total > 0) onProgress(got / total);
      }
      await sink.close();
      await part.rename('${d.path}/$name');
    } finally {
      client.close();
    }
  }
}
