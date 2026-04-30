import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/scanner_provider.dart';

class ScannerScreen extends ConsumerWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scannerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('فحص الطعام'),
        actions: [
          if (state.image != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => ref.read(scannerProvider.notifier).reset(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildImageDisplay(state),
            const SizedBox(height: 32),
            if (state.isScanning)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري تحليل الوجبة... يرجى الانتظار'),
                ],
              )
            else if (state.result != null)
              _buildResultCard(state.result!)
            else
              _buildInitialView(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildImageDisplay(ScannerState state) {
    return AspectRatio(
      aspectRatio: 1,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: state.image != null
            ? (kIsWeb
                ? Image.network(state.image!.path, fit: BoxFit.cover)
                : Image.file(File(state.image!.path), fit: BoxFit.cover))
            : Container(
                color: Colors.grey.shade100,
                child: const Icon(Icons.restaurant_rounded, size: 80, color: Colors.grey),
              ),
      ),
    );
  }

  Widget _buildResultCard(String result) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  'تحليل رفيق الذكي',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              result,
              style: const TextStyle(fontSize: 15, height: 1.6),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialView(WidgetRef ref) {
    return Column(
      children: [
        const Text(
          'صور وجبتك الآن وسيقوم رفيق بإخبارك بمحتواها من السكريات والكربوهيدرات.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () => ref.read(scannerProvider.notifier).pickAndAnalyze(),
          icon: const Icon(Icons.camera_alt_rounded),
          label: const Text('ابدأ الفحص بالكاميرا'),
        ),
      ],
    );
  }
}
