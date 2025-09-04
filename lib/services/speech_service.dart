import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechService extends ChangeNotifier {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;
  String _transcribedText = '';
  double _confidence = 0.0;
  
  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;
  String get transcribedText => _transcribedText;
  double get confidence => _confidence;

  SpeechService() {
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      _isAvailable = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
            notifyListeners();
          }
        },
        onError: (error) {
          debugPrint('Speech error: $error');
          _isListening = false;
          notifyListeners();
        },
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Speech initialization error: $e');
      _isAvailable = false;
      notifyListeners();
    }
  }

  Future<bool> _checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isDenied) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }
    return status.isGranted;
  }

  Future<void> startListening({
    Function(String)? onResult,
    Function(double)? onSoundLevel,
  }) async {
    if (!_isAvailable) {
      await _initSpeech();
    }

    if (!_isAvailable) {
      debugPrint('Speech recognition not available');
      return;
    }

    final hasPermission = await _checkMicrophonePermission();
    if (!hasPermission) {
      debugPrint('Microphone permission denied');
      return;
    }

    if (_isListening) {
      await stopListening();
    }

    _transcribedText = '';
    _confidence = 0.0;
    _isListening = true;
    notifyListeners();

    await _speech.listen(
      onResult: (result) {
        _transcribedText = result.recognizedWords;
        _confidence = result.confidence;
        onResult?.call(_transcribedText);
        notifyListeners();
      },
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
      onSoundLevelChange: onSoundLevel,
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      notifyListeners();
    }
  }

  void clearTranscription() {
    _transcribedText = '';
    _confidence = 0.0;
    notifyListeners();
  }

  Future<void> cancel() async {
    await _speech.cancel();
    _isListening = false;
    _transcribedText = '';
    _confidence = 0.0;
    notifyListeners();
  }

  Future<List<LocaleName>> get availableLocales async => await _speech.locales();

  bool get hasError => !_isAvailable && !_isListening;
}