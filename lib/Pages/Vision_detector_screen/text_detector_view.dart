import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '/Pages/Vision_detector_screen/camera_view.dart';
import '../../Model/Painter/text_detector_painter.dart';
import '/Model/SourceLang.dart';
import '/Model/Translation/Translation.dart';


class TextRecognizerView extends StatefulWidget {
  @override
  State<TextRecognizerView> createState() => _TextRecognizerViewState();
}

class _TextRecognizerViewState extends State<TextRecognizerView> {
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.chinese);
  final _onDeviceTranslator = OnDeviceTranslator(
      sourceLanguage: SourceLang.instance.TranslateLanguageFrom,
      targetLanguage: SourceLang.instance.TranslateLanguageTo);
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  String? _result;
  @override
  void dispose() async {
    _canProcess = false;
    _textRecognizer.close();
    _onDeviceTranslator.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Text Detector',
      customPaint: _customPaint,
      text: _text,
      result: _result,
      onImage: (inputImage) {
        processImage(inputImage);
      },
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final List<String> listText = <String>[];
    final recognizedText = await _textRecognizer.processImage(inputImage);
    _result = recognizedText.text;
    for (final textBlock in recognizedText.blocks)
      {
        /*var textTemp = await Translation.instance.translate(
            textBlock.text, languagefrom: 'en', languageto: 'vi');*/
        var textTemp = await _onDeviceTranslator.translateText(textBlock.text);
        listText.add('$textTemp');
      }
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {

      final painter = TextRecognizerPainter(
          recognizedText,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation,
          listText);
      _customPaint = await CustomPaint(painter: painter);

    } else {
      _text = 'Recognized text:\n\n${recognizedText.text}';
      if(listText.isNotEmpty)
        {
          _text =_text! + "\n\n";
          _text =_text! + await Translation.instance.translate(
              _result!, languagefrom: SourceLang.instance.languageIDFrom, languageto: SourceLang.instance.languageIDTo);
        }
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
      await Future.delayed(Duration(milliseconds: 500));
    }
  }
}
