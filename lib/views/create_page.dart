import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:provider/provider.dart';

import '../models/gen_params.dart';
import '../viewmodels/create_viewmodel.dart';

class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateViewModel>();
    final p = vm.p;
    final cs = Theme.of(context).colorScheme;
    return ListView(padding: const EdgeInsets.all(16), children: [
      TextFormField(
        initialValue: p.prompt,
        minLines: 3,
        maxLines: 6,
        onChanged: (v) => p.prompt = v,
        decoration: const InputDecoration(labelText: 'Describe the image', border: OutlineInputBorder()),
      ),
      const SizedBox(height: 12),
      TextFormField(
        initialValue: p.negative,
        maxLines: 2,
        onChanged: (v) => p.negative = v,
        decoration: const InputDecoration(labelText: 'Negative prompt (what to avoid)', border: OutlineInputBorder()),
      ),
      const SizedBox(height: 12),
      Wrap(spacing: 8, children: [
        for (final (w, h) in sizes)
          ChoiceChip(
            label: Text('$w×$h'),
            selected: p.width == w && p.height == h,
            onSelected: (_) => vm.set(() {
              p.width = w;
              p.height = h;
            }),
          ),
      ]),
      _slider('Steps', p.steps.toDouble(), 1, 50, 49, '${p.steps}',
          (v) => vm.set(() => p.steps = v.round())),
      _slider('Guidance (CFG)', p.cfg, 1, 15, 28, p.cfg.toStringAsFixed(1),
          (v) => vm.set(() => p.cfg = v)),
      _slider('Images', p.batch.toDouble(), 1, 4, 3, '${p.batch}',
          (v) => vm.set(() => p.batch = v.round())),
      ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: const Text('Advanced'),
        children: [
          _dd('Sampler', p.sampler, samplers, (v) => vm.set(() => p.sampler = v)),
          _dd('Scheduler', p.scheduler, schedulers, (v) => vm.set(() => p.scheduler = v)),
          _dd('Weight precision', p.weightType, weightTypes, (v) => vm.set(() => p.weightType = v)),
          _slider('Clip skip', p.clipSkip.toDouble(), 1, 2, 1, '${p.clipSkip}',
              (v) => vm.set(() => p.clipSkip = v.round())),
          _slider('CPU threads', p.threads.toDouble(), 1, 8, 7, '${p.threads}',
              (v) => vm.set(() => p.threads = v.round())),
          Row(children: [
            Expanded(
              child: TextFormField(
                key: ValueKey(p.seed),
                initialValue: '${p.seed}',
                keyboardType: TextInputType.number,
                onChanged: (v) => p.seed = int.tryParse(v) ?? -1,
                decoration: const InputDecoration(labelText: 'Seed'),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Lock'),
            Switch(value: p.lockSeed, onChanged: (v) => vm.set(() => p.lockSeed = v)),
          ]),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Tiled VAE (saves memory)'),
            value: p.vaeTiling,
            onChanged: (v) => vm.set(() => p.vaeTiling = v),
          ),
        ],
      ),
      const SizedBox(height: 8),
      FilledButton.icon(
        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
        icon: Icon(vm.running ? Icons.stop_rounded : Icons.auto_awesome),
        label: Text(vm.running ? 'Stop' : 'Generate'),
        onPressed: vm.running ? vm.stop : vm.generate,
      ),
      if (vm.running) ...[
        const SizedBox(height: 12),
        LinearProgressIndicator(value: vm.step == 0 ? null : vm.step / p.steps),
        const SizedBox(height: 6),
        Text(vm.step == 0 ? 'Loading the model, then sampling…' : 'Step ${vm.step} of ${p.steps}'),
      ],
      if (vm.error != null)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(vm.error!, style: TextStyle(color: cs.error), maxLines: 12),
        ),
      for (final f in vm.latest) _Result(file: f),
    ]);
  }

  Widget _slider(String label, double v, double min, double max, int div, String shown,
          ValueChanged<double> on) =>
      Row(children: [
        SizedBox(width: 110, child: Text(label)),
        Expanded(child: Slider(value: v, min: min, max: max, divisions: div, label: shown, onChanged: on)),
        SizedBox(width: 32, child: Text(shown)),
      ]);

  Widget _dd(String label, String v, List<String> items, ValueChanged<String> on) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: DropdownButtonFormField<String>(
          value: v,
          decoration: InputDecoration(labelText: label),
          items: [for (final s in items) DropdownMenuItem(value: s, child: Text(s))],
          onChanged: (s) => on(s!),
        ),
      );
}

class _Result extends StatelessWidget {
  const _Result({required this.file});
  final File file;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(file)),
        TextButton.icon(
          icon: const Icon(Icons.save_alt),
          label: const Text('Save to Photos'),
          onPressed: () async {
            final m = ScaffoldMessenger.of(context);
            try {
              await Gal.putImage(file.path);
              m.showSnackBar(const SnackBar(content: Text('Saved to Photos')));
            } catch (e) {
              m.showSnackBar(SnackBar(content: Text('Could not save: $e')));
            }
          },
        ),
      ]),
    );
  }
}
