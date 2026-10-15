import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/gen_params.dart';
import '../viewmodels/models_viewmodel.dart';

class ModelsPage extends StatelessWidget {
  const ModelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ModelsViewModel>();
    final cs = Theme.of(context).colorScheme;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Models', style: TextStyle(fontFamily: 'serif', fontSize: 28, color: cs.onSurface)),
      const SizedBox(height: 4),
      const Text('Download once over Wi-Fi. Models stay on this phone and run offline.'),
      if (vm.error != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(vm.error!, style: TextStyle(color: cs.error)),
        ),
      const SizedBox(height: 12),
      for (final e in catalog)
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(e.name),
          subtitle: vm.downloading == e.file
              ? Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: LinearProgressIndicator(value: vm.progress == 0 ? null : vm.progress))
              : Text(e.size),
          trailing: vm.files.any((f) => f.path.endsWith(e.file))
              ? const Icon(Icons.check_circle)
              : TextButton(
                  onPressed: vm.downloading == null ? () => vm.downloadEntry(e) : null,
                  child: const Text('Download'),
                ),
        ),
      TextButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Add model by URL'),
        onPressed: () => _add(context, vm),
      ),
      const Divider(),
      const Text('On this device'),
      if (vm.files.isEmpty) const Padding(padding: EdgeInsets.all(8), child: Text('Nothing downloaded yet')),
      for (final f in vm.files)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(vm.active?.path == f.path ? Icons.radio_button_checked : Icons.radio_button_off,
              color: cs.primary),
          title: Text(f.path.split('/').last),
          subtitle: Text('${(f.lengthSync() / 1e9).toStringAsFixed(2)} GB'),
          onTap: () => vm.select(f),
          trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => vm.delete(f)),
        ),
    ]);
  }

  void _add(BuildContext context, ModelsViewModel vm) {
    final url = TextEditingController(), token = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add model'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: url,
              decoration: const InputDecoration(labelText: 'Direct link (.safetensors, .ckpt or .gguf)')),
          TextField(
              controller: token,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Hugging Face token (only if gated)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final u = url.text.trim();
              if (u.isNotEmpty) vm.download(u.split('?').first.split('/').last, u, token: token.text);
              Navigator.pop(ctx);
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }
}
