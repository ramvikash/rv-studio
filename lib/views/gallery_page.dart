import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:provider/provider.dart';

import '../data/sd_runner.dart';
import '../viewmodels/create_viewmodel.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<CreateViewModel>(); // rebuild after each generation
    return FutureBuilder<List<File>>(
      future: SdRunner.allImages(),
      builder: (context, snap) {
        final files = snap.data ?? [];
        if (files.isEmpty) return const Center(child: Text('No images yet'));
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8),
          itemCount: files.length,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => _open(context, files[i]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(files[i], fit: BoxFit.cover, cacheWidth: 400),
            ),
          ),
        );
      },
    );
  }

  void _open(BuildContext context, File f) => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          contentPadding: const EdgeInsets.all(8),
          content: InteractiveViewer(child: Image.file(f)),
          actions: [
            TextButton(
              onPressed: () async {
                await f.delete();
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) (context as Element).markNeedsBuild();
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await Gal.putImage(f.path);
                } catch (_) {}
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save to Photos'),
            ),
          ],
        ),
      );
}
