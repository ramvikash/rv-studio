import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../models/gen_params.dart';

/// Runs the stable-diffusion.cpp command-line tool that is packaged inside the
/// APK as libsdcli.so. Only this file knows about the CLI flags.
class SdRunner {
  static const _channel = MethodChannel('sd/native');
  Process? _proc;

  Future<List<File>> run(GenParams p, String modelPath,
      {required void Function(int step, int total) onProgress}) async {
    final lib = await _channel.invokeMethod<String>('libDir');
    final out = Directory(
        '${(await getApplicationDocumentsDirectory()).path}/images/${DateTime.now().millisecondsSinceEpoch}');
    await out.create(recursive: true);
    final args = [
      '-m', modelPath,
      '-p', p.prompt,
      '-n', p.negative,
      '--steps', '${p.steps}',
      '--cfg-scale', '${p.cfg}',
      '-s', '${p.seed}',
      '-W', '${p.width}',
      '-H', '${p.height}',
      '--sampling-method', p.sampler,
      '--scheduler', p.scheduler,
      '--clip-skip', '${p.clipSkip}',
      '-b', '${p.batch}',
      '--type', p.weightType,
      '-t', '${p.threads}',
      if (p.vaeTiling) '--vae-tiling',
      '-o', '${out.path}/image.png',
    ];
    _proc = await Process.start('$lib/libsdcli.so', args);
    var tail = '';
    final re = RegExp(r'(\d+)/(\d+)');
    void onData(List<int> d) {
      final s = utf8.decode(d, allowMalformed: true);
      tail = (tail + s);
      if (tail.length > 1200) tail = tail.substring(tail.length - 1200);
      Match? last;
      for (final m in re.allMatches(s)) {
        if (int.parse(m[2]!) == p.steps) last = m;
      }
      if (last != null) onProgress(int.parse(last[1]!), p.steps);
    }

    _proc!.stdout.listen(onData);
    _proc!.stderr.listen(onData);
    final code = await _proc!.exitCode;
    _proc = null;
    if (code != 0) throw 'Generator exited with code $code.\n$tail';
    return out.listSync().whereType<File>().where((f) => f.path.endsWith('.png')).toList()
      ..sort((a, b) => a.path.compareTo(b.path));
  }

  void stop() => _proc?.kill();

  static Future<List<File>> allImages() async {
    final d = Directory('${(await getApplicationDocumentsDirectory()).path}/images');
    if (!await d.exists()) return [];
    final files = d.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.png')).toList();
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return files;
  }
}
