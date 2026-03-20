import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'package:flutter_tts/flutter_tts.dart';

class FeaturePage extends StatefulWidget {
  final String selectedFont;
  final Function(String) onFontChanged;

  const FeaturePage({
    super.key,
    required this.selectedFont,
    required this.onFontChanged,
  });

  @override
  State<FeaturePage> createState() => _FeaturePageState();
}

class _FeaturePageState extends State<FeaturePage> {
  String? _scannedText;
  bool _isLoading = false;

  // TTS
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });

    _flutterTts.setCancelHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  // ---------------- Font getter ----------------
  String? _getFontFamily() {
    if (widget.selectedFont == "Normal") return null;
    if (widget.selectedFont == "OpenDyslexic") return "OpenDyslexic";
    if (widget.selectedFont == "Lexend") return "Lexend";
    return null;
  }

  // ---------------- IMAGE PICK + OCR ----------------
  Future<void> _pickImageAndScan() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      setState(() {
        _isLoading = true;
        _scannedText = null;
      });

      final inputImage = InputImage.fromFile(File(image.path));
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

      final RecognizedText recognizedText =
      await textRecognizer.processImage(inputImage);

      await textRecognizer.close();

      setState(() {
        _scannedText = recognizedText.text.trim();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error scanning image: $e")),
      );
    }
  }

  // ---------------- CAMERA CAPTURE + OCR ----------------
  Future<void> _captureImageAndScan() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image == null) return;

      setState(() {
        _isLoading = true;
        _scannedText = null;
      });

      final inputImage = InputImage.fromFile(File(image.path));
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

      final RecognizedText recognizedText =
      await textRecognizer.processImage(inputImage);

      await textRecognizer.close();

      setState(() {
        _scannedText = recognizedText.text.trim();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error scanning camera image: $e")),
      );
    }
  }

  // ---------------- PDF PICK + TEXT EXTRACTION ----------------
  Future<void> _pickPdfAndExtractText() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null) return;

      File pdfFile = File(result.files.single.path!);

      setState(() {
        _isLoading = true;
        _scannedText = null;
      });

      final List<int> bytes = await pdfFile.readAsBytes();

      PdfDocument document = PdfDocument(inputBytes: bytes);

      String extractedText = PdfTextExtractor(document).extractText();

      document.dispose();

      setState(() {
        _scannedText = extractedText.trim();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error reading PDF: $e")),
      );
    }
  }

  // ---------------- TTS SPEAK ----------------
  Future<void> _speakText() async {
    if (_scannedText == null || _scannedText!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No text available to speak!")),
      );
      return;
    }

    setState(() {
      _isSpeaking = true;
    });

    await _flutterTts.speak(_scannedText!);
  }

  // ---------------- TTS STOP ----------------
  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();

    setState(() {
      _isSpeaking = false;
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LexiLift Features"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // FONT DROPDOWN
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Font: ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: widget.selectedFont,
                  items: const [
                    DropdownMenuItem(value: "Normal", child: Text("Normal")),
                    DropdownMenuItem(
                        value: "OpenDyslexic", child: Text("OpenDyslexic")),
                    DropdownMenuItem(value: "Lexend", child: Text("Lexend")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      widget.onFontChanged(value);
                      setState(() {});
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // IMAGE BUTTON
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 30.0, vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isLoading ? null : _pickImageAndScan,
              icon: const Icon(Icons.image),
              label: const Text(
                "Upload Image & Scan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 15),

            // CAMERA BUTTON
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 30.0, vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isLoading ? null : _captureImageAndScan,
              icon: const Icon(Icons.camera_alt),
              label: const Text(
                "Open Camera & Scan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 15),

            // PDF BUTTON
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 30.0, vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isLoading ? null : _pickPdfAndExtractText,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text(
                "Upload PDF & Extract Text",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 25),

            if (_isLoading) const CircularProgressIndicator(),

            // TEXT OUTPUT
            if (_scannedText != null && !_isLoading)
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.indigo, width: 1),
                    ),
                    child: Text(
                      _scannedText!,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.6,
                        fontFamily: _getFontFamily(),
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              )
            else if (!_isLoading)
              const Text(
                "No text scanned yet.\nUpload an image or PDF to begin!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),

            const SizedBox(height: 20),

            // TTS BUTTONS
            if (_scannedText != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isSpeaking ? null : _speakText,
                    icon: const Icon(Icons.volume_up),
                    label: const Text(
                      "Speak",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isSpeaking ? _stopSpeaking : null,
                    icon: const Icon(Icons.stop),
                    label: const Text(
                      "Stop",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
