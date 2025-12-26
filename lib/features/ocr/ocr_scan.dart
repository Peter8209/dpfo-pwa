import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class OcrResult {
  final String rawText;
  final String? firstName;
  final String? lastName;
  final String? dic;
  final String? ico;
  final String? rc;

  const OcrResult({
    required this.rawText,
    this.firstName,
    this.lastName,
    this.dic,
    this.ico,
    this.rc,
  });
}

class OcrScanScreen extends StatefulWidget {
  const OcrScanScreen({super.key});

  @override
  State<OcrScanScreen> createState() => _OcrScanScreenState();
}

class _OcrScanScreenState extends State<OcrScanScreen> {
  final _picker = ImagePicker();
  bool _busy = false;
  OcrResult? _result;

  Future<void> _scan() async {
    final x = await _picker.pickImage(source: ImageSource.camera);
    if (x == null) return;

    setState(() => _busy = true);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final inputImage = InputImage.fromFile(File(x.path));
      final recognized = await recognizer.processImage(inputImage);
      final raw = recognized.text;

      // Very simple heuristics/regex. Adjust for your document formats.
      String? pickIco(String t) {
        final m = RegExp(r'\b\d{8}\b').firstMatch(t);
        return m?.group(0);
      }

      String? pickDic(String t) {
        final m = RegExp(r'\b\d{10}\b').firstMatch(t);
        return m?.group(0);
      }

      String? pickRc(String t) {
        final m = RegExp(r'\b\d{6}/?\d{3,4}\b').firstMatch(t);
        return m?.group(0);
      }

      // Name parsing is hard; keep as null for MVP and let user fill manually.
      _result = OcrResult(
        rawText: raw,
        ico: pickIco(raw),
        dic: pickDic(raw),
        rc: pickRc(raw),
      );
    } finally {
      await recognizer.close();
      setState(() => _busy = false);
    }
  }

  void _useResult() {
    Navigator.of(context).pop(_result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OCR')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FilledButton.icon(
              onPressed: _busy ? null : _scan,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Quét'),
            ),
            const SizedBox(height: 12),
            if (_busy) const LinearProgressIndicator(),
            const SizedBox(height: 12),
            if (_result != null) Expanded(
              child: SingleChildScrollView(
                child: SelectableText(_result!.rawText),
              ),
            ),
            const SizedBox(height: 12),
            if (_result != null)
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: _useResult, child: const Text('Dùng kết quả'))),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
