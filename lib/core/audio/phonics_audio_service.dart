import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Plays bundled phonics clips first, then the on-device TTS engine.
class PhonicsAudioService {
  PhonicsAudioService({
    AudioPlayer? sfx,
    AudioPlayer? voice,
    FlutterTts? tts,
  })  : _sfx = sfx ?? AudioPlayer(),
        _voice = voice ?? AudioPlayer(),
        _tts = tts ?? FlutterTts();

  final AudioPlayer _sfx;
  final AudioPlayer _voice;
  final FlutterTts _tts;
  final Map<String, bool> _assetCache = {};

  Future<void> init() async {
    await _sfx.setReleaseMode(ReleaseMode.stop);
    await _voice.setReleaseMode(ReleaseMode.stop);
    await _tts.setSpeechRate(0.38);
    await _tts.setPitch(1.12);
    await _tts.setVolume(1);
  }

  Future<void> playPhoneme(String id) async {
    final key = id.toLowerCase();
    if (await _playAsset('audio/phonics/$key.wav')) return;
    await _tts.speak(_phonemePrompt(key));
  }

  Future<void> playWord(String word) async {
    final key = word.toLowerCase();
    if (await _playAsset('audio/words/$key.wav')) return;
    await _tts.speak(key);
  }

  Future<void> playSuccess() => _playSfx('audio/sfx/success.wav');

  Future<void> playError() => _playSfx('audio/sfx/error.wav');

  Future<void> playStar() => _playSfx('audio/sfx/star.wav');

  Future<void> playTap() => _playSfx('audio/sfx/tap.wav');

  Future<void> playSnap() => _playSfx('audio/sfx/snap.wav');

  Future<void> stop() async {
    await _voice.stop();
    await _sfx.stop();
    await _tts.stop();
  }

  Future<void> dispose() async {
    await stop();
    await _voice.dispose();
    await _sfx.dispose();
  }

  Future<bool> _playAsset(String relativePath) async {
    if (!await _exists(relativePath)) return false;
    await _voice.stop();
    await _voice.play(AssetSource(relativePath));
    return true;
  }

  Future<void> _playSfx(String relativePath) async {
    if (!await _exists(relativePath)) return;
    await _sfx.stop();
    await _sfx.play(AssetSource(relativePath));
  }

  Future<bool> _exists(String relativePath) async {
    final cached = _assetCache[relativePath];
    if (cached != null) return cached;
    try {
      await rootBundle.load('assets/$relativePath');
      _assetCache[relativePath] = true;
      return true;
    } catch (_) {
      _assetCache[relativePath] = false;
      return false;
    }
  }

  String _phonemePrompt(String id) {
    const sounds = {
      'a': 'a',
      'e': 'e',
      'i': 'i',
      'o': 'o',
      'u': 'u',
      's': 'sss',
      'sh': 'sh',
      'ch': 'ch',
      'th': 'th',
      'ng': 'ing',
    };
    return sounds[id] ?? id;
  }
}
