import 'dart:io';

/// Every option the generator exposes. Names match stable-diffusion.cpp flags.
class GenParams {
  String prompt = '';
  String negative = 'low quality, blurry, deformed, extra fingers, watermark, text';
  int steps = 20;
  double cfg = 7.0;
  int seed = -1;
  bool lockSeed = false;
  int width = 512, height = 512;
  String sampler = 'euler_a';
  String scheduler = 'discrete';
  int clipSkip = 1;
  int batch = 1;
  String weightType = 'f16'; // converts the 4 GB checkpoint to 16-bit while loading
  bool vaeTiling = false;
  int threads = (Platform.numberOfProcessors ~/ 2).clamp(2, 6);
}

const samplers = ['euler_a', 'euler', 'heun', 'dpm2', 'dpm++2m', 'dpm++2s_a', 'lcm'];
const schedulers = ['discrete', 'karras', 'exponential', 'ays', 'gits'];
const weightTypes = ['f16', 'q8_0', 'q4_0', 'f32'];
const sizes = [(512, 512), (512, 768), (768, 512), (640, 640), (768, 768)];

class CatalogEntry {
  const CatalogEntry(this.name, this.size, this.file, this.url);
  final String name, size, file, url;
}

/// Verify the URL on Hugging Face if the download returns 404.
const catalog = [
  CatalogEntry(
    'Stable Diffusion 1.5',
    '4.3 GB',
    'sd-v1-5.safetensors',
    'https://huggingface.co/stable-diffusion-v1-5/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors',
  ),
];
