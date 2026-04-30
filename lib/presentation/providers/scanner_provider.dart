import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/datasources/remote/gemini_service.dart';

class ScannerState {
  final bool isScanning;
  final String? result;
  final XFile? image;
  final String? error;

  ScannerState({this.isScanning = false, this.result, this.image, this.error});

  ScannerState copyWith({bool? isScanning, String? result, XFile? image, String? error}) {
    return ScannerState(
      isScanning: isScanning ?? this.isScanning,
      result: result ?? this.result,
      image: image ?? this.image,
      error: error ?? this.error,
    );
  }
}

class ScannerNotifier extends StateNotifier<ScannerState> {
  final GeminiService _geminiService;
  final ImagePicker _picker = ImagePicker();

  ScannerNotifier(this._geminiService) : super(ScannerState());

  Future<void> pickAndAnalyze() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo == null) return;

      state = state.copyWith(isScanning: true, image: photo, result: null, error: null);

      final bytes = await photo.readAsBytes();
      final mimeType = _getMimeType(photo.path);
      
      final result = await _geminiService.analyzeFood(bytes, mimeType);
      state = state.copyWith(isScanning: false, result: result);
    } catch (e) {
      state = state.copyWith(isScanning: false, error: e.toString());
    }
  }

  String _getMimeType(String path) {
    if (path.endsWith('.png')) return 'image/png';
    return 'image/jpeg';
  }

  void reset() {
    state = ScannerState();
  }
}

final scannerProvider = StateNotifierProvider<ScannerNotifier, ScannerState>((ref) {
  return ScannerNotifier(GeminiService());
});
