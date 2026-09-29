import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FreshnessResult {
  final String label;
  final String food;
  final bool fresh;
  final double confidence;
  final int estimatedDays;

  const FreshnessResult({
    required this.label,
    required this.food,
    required this.fresh,
    required this.confidence,
    required this.estimatedDays,
  });
}

/// On-device freshness inference using the open-source TFLite model fetched by
/// the GitHub Actions build workflow. If the model is unavailable, callers can
/// safely fall back to the existing local rules.
class FreshnessAIService {
  static const modelAsset = 'assets/models/freshness_model.tflite';
  static const labels = <String>[
    'fresh_apple',
    'fresh_banana',
    'fresh_bitter_gourd',
    'fresh_capsicum',
    'fresh_orange',
    'fresh_tomato',
    'stale_apple',
    'stale_banana',
    'stale_bitter_gourd',
    'stale_capsicum',
    'stale_orange',
    'stale_tomato',
  ];

  Interpreter? _interpreter;

  Future<void> _ensureLoaded() async {
    if (_interpreter != null) return;
    _interpreter = await Interpreter.fromAsset(modelAsset);
  }

  Future<FreshnessResult?> analyze(File file) async {
    try {
      await _ensureLoaded();
      final interpreter = _interpreter!;
      final inputTensor = interpreter.getInputTensor(0);
      final outputTensor = interpreter.getOutputTensor(0);
      final inputShape = inputTensor.shape;
      if (inputShape.length < 4) return null;

      final height = inputShape[inputShape.length - 3];
      final width = inputShape[inputShape.length - 2];
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;
      final resized = img.copyResize(decoded, width: width, height: height);

      final isUint8 = inputTensor.type == TensorType.uint8;
      final input = _makeInput(resized, isUint8);
      final output = _zeroTensor(outputTensor.shape);
      interpreter.run(input, output);
      final scores = _flattenNumbers(output);
      if (scores.isEmpty) return null;

      var best = 0;
      for (var i = 1; i < scores.length; i++) {
        if (scores[i] > scores[best]) best = i;
      }
      final confidence = (scores[best] * 100).clamp(0, 100).toDouble();
      final label = best < labels.length ? labels[best] : 'unknown';
      final normalized = label.replaceAll('_', ' ');
      final fresh = label.startsWith('fresh_');
      final food = label.replaceFirst(RegExp(r'^(fresh|stale)_'), '').replaceAll('_', ' ');

      return FreshnessResult(
        label: normalized,
        food: food,
        fresh: fresh,
        confidence: confidence,
        estimatedDays: _daysFor(food, fresh),
      );
    } catch (_) {
      return null;
    }
  }

  Object _makeInput(img.Image image, bool uint8) {
    final rows = List.generate(image.height, (y) {
      return List.generate(image.width, (x) {
        final p = image.getPixel(x, y);
        final r = p.r.toDouble();
        final g = p.g.toDouble();
        final b = p.b.toDouble();
        if (uint8) return [r.round(), g.round(), b.round()];
        return [r / 255.0, g / 255.0, b / 255.0];
      });
    });
    return [rows];
  }

  Object _zeroTensor(List<int> shape) {
    if (shape.isEmpty) return 0.0;
    if (shape.length == 1) return List<double>.filled(shape.first, 0.0);
    return List.generate(shape.first, (_) => _zeroTensor(shape.sublist(1)));
  }

  List<double> _flattenNumbers(Object value) {
    if (value is num) return [value.toDouble()];
    if (value is List) {
      return value.expand<double>((e) => _flattenNumbers(e)).toList();
    }
    return const [];
  }

  int _daysFor(String food, bool fresh) {
    if (!fresh) return 0;
    switch (food) {
      case 'banana': return 4;
      case 'apple': return 7;
      case 'orange': return 7;
      case 'tomato': return 5;
      case 'capsicum': return 5;
      case 'bitter gourd': return 3;
      default: return 3;
    }
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
