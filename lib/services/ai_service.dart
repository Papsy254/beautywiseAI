import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';

class AIService {
  late Interpreter _interpreter;

  Future<void> loadModel() async {
    var options = InterpreterOptions()..addDelegate(GpuDelegateV2());
    _interpreter = await Interpreter.fromAsset(
      'assets/face_scan_model.tflite',
      options: options,
    );
  }

  Future<int> analyzeImage(Uint8List imageBytes) async {
    var input = [imageBytes];
    var output = List.filled(1, 0); // Face type classification output

    _interpreter.run(input, output);
    return output[0]; // Returns class index (0 = Oily, 1 = Dry, 2 = Combination, 3 = Normal)
  }

  void close() {
    _interpreter.close();
  }
}
