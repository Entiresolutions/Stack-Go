import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundSynthesizer {
  static final SoundSynthesizer instance = SoundSynthesizer._();

  SoundSynthesizer._() {
    initialize();
  }

  static const List<double> _pentatonicFrequencies = [
    261.63, 293.66, 329.63, 392.00, 440.00, // C4, D4, E4, G4, A4
    523.25, 587.33, 659.25, 783.99, 880.00, // C5, D5, E5, G5, A5
    1046.50, 1174.66, 1318.51, 1567.98, 1760.00, // C6, D6, E6, G6, A6
    2093.00, 2349.32, 2637.02, 3135.96, 3520.00, // C7, D7, E7, G7, A7
  ];

  static const List<double> _streakScale = [
    523.25, // Streak 1: C5
    587.33, // Streak 2: D5
    659.25, // Streak 3: E5
    783.99, // Streak 4: G5
    880.00, // Streak 5: A5
    1046.50, // Streak 6: C6
    1174.66, // Streak 7: D6
    1318.51, // Streak 8: E6
    1567.98, // Streak 9: G6
    2093.00, // Streak 10+: C7
  ];

  final Map<int, Uint8List> _normalSoundCache = {};
  final Map<int, Source> _normalSourceCache = {};

  final Map<int, Uint8List> _streakSoundCache = {};
  final Map<int, Source> _streakSourceCache = {};

  Uint8List? _gameOverSound;
  Source? _gameOverSource;

  Uint8List? _buttonSound;
  Source? _buttonSource;

  final List<AudioPlayer> _players = [];
  int _playerIndex = 0;
  bool _initialized = false;
  double _volume = 0.8;

  double get volume => _volume;

  Future<void> initialize({double volume = 0.8}) async {
    _volume = volume.clamp(0.0, 1.0);
    if (_initialized) {
      setVolume(_volume);
      return;
    }
    _initialized = true;

    try {
      Directory? sfxDir;
      if (!kIsWeb) {
        try {
          sfxDir = Directory('${Directory.systemTemp.path}/stack_pulse_sfx');
          if (!sfxDir.existsSync()) {
            sfxDir.createSync(recursive: true);
          }
        } catch (_) {}
      }

      // Round robin pool of 4 players for overlapping polyphonic effects
      for (int i = 0; i < 4; i++) {
        final player = AudioPlayer();
        if (!kIsWeb) {
          try {
            await player.setPlayerMode(PlayerMode.lowLatency);
          } catch (_) {}
        }
        try {
          await player.setVolume(_volume);
        } catch (_) {}
        _players.add(player);
      }

      // Pre-synthesize normal notes
      for (int i = 0; i < _pentatonicFrequencies.length; i++) {
        final wav = _generateWav(
          frequency: _pentatonicFrequencies[i],
          durationSeconds: 0.18,
          decay: 14.0,
          volume: 0.35,
        );
        _normalSoundCache[i] = wav;

        if (sfxDir != null) {
          try {
            final file = File('${sfxDir.path}/normal_$i.wav');
            if (!file.existsSync() || file.lengthSync() != wav.length) {
              file.writeAsBytesSync(wav, flush: true);
            }
            _normalSourceCache[i] = DeviceFileSource(file.path);
          } catch (_) {}
        }
      }

      // Pre-synthesize streak notes with rich harmonic overtones
      for (int i = 0; i < _streakScale.length; i++) {
        final baseFreq = _streakScale[i];
        final harmonicFreq = i >= 4 ? baseFreq * 2.0 : baseFreq * 1.5;
        final wav = _generateWav(
          frequency: baseFreq,
          durationSeconds: 0.35,
          decay: 9.0,
          volume: 0.40,
          harmonicFrequency: harmonicFreq,
          harmonicVolume: 0.20,
        );
        _streakSoundCache[i] = wav;

        if (sfxDir != null) {
          try {
            final file = File('${sfxDir.path}/streak_$i.wav');
            if (!file.existsSync() || file.lengthSync() != wav.length) {
              file.writeAsBytesSync(wav, flush: true);
            }
            _streakSourceCache[i] = DeviceFileSource(file.path);
          } catch (_) {}
        }
      }

      // Game over thud
      _gameOverSound = _generateGameOverWav();
      if (sfxDir != null && _gameOverSound != null) {
        try {
          final file = File('${sfxDir.path}/game_over.wav');
          if (!file.existsSync() || file.lengthSync() != _gameOverSound!.length) {
            file.writeAsBytesSync(_gameOverSound!, flush: true);
          }
          _gameOverSource = DeviceFileSource(file.path);
        } catch (_) {}
      }

      // UI button click
      _buttonSound = _generateWav(
        frequency: 800.0,
        durationSeconds: 0.05,
        decay: 35.0,
        volume: 0.30,
      );
      if (sfxDir != null && _buttonSound != null) {
        try {
          final file = File('${sfxDir.path}/button.wav');
          if (!file.existsSync() || file.lengthSync() != _buttonSound!.length) {
            file.writeAsBytesSync(_buttonSound!, flush: true);
          }
          _buttonSource = DeviceFileSource(file.path);
        } catch (_) {}
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing SoundSynthesizer: $e');
      }
    }
  }

  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    for (final player in _players) {
      try {
        player.setVolume(_volume);
      } catch (_) {}
    }
  }

  void playNormalPlacement(int score) {
    if (_volume <= 0.0) return;
    final idx = score % _pentatonicFrequencies.length;
    _play(
      source: _normalSourceCache[idx],
      fallbackBytes: _normalSoundCache[idx],
    );
  }

  void playPerfectPlacement(int streak) {
    if (_volume <= 0.0) return;
    final streakIndex = (streak - 1).clamp(0, _streakScale.length - 1);
    _play(
      source: _streakSourceCache[streakIndex],
      fallbackBytes: _streakSoundCache[streakIndex],
    );
  }

  void playGameOver() {
    if (_volume <= 0.0) return;
    _play(
      source: _gameOverSource,
      fallbackBytes: _gameOverSound,
    );
  }

  void playButton() {
    if (_volume <= 0.0) return;
    _play(
      source: _buttonSource,
      fallbackBytes: _buttonSound,
    );
  }

  void _play({Source? source, Uint8List? fallbackBytes}) {
    if (_players.isEmpty) return;
    try {
      final player = _players[_playerIndex];
      _playerIndex = (_playerIndex + 1) % _players.length;

      if (source != null) {
        player.play(source, volume: _volume);
      } else if (fallbackBytes != null) {
        player.play(BytesSource(fallbackBytes), volume: _volume);
      }
    } catch (e) {
      if (kDebugMode) {
        print('SoundSynthesizer playback error: $e');
      }
    }
  }

  /// Generates a valid 16-bit mono 22.05kHz PCM WAV audio file in-memory
  static Uint8List _generateWav({
    required double frequency,
    required double durationSeconds,
    required double decay,
    required double volume,
    double? harmonicFrequency,
    double harmonicVolume = 0.0,
  }) {
    const int sampleRate = 22050;
    final int totalSamples = (durationSeconds * sampleRate).toInt();
    const int numChannels = 1;
    const int bitsPerSample = 16;
    const int byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
    const int blockAlign = numChannels * (bitsPerSample ~/ 8);
    final int dataSize = totalSamples * (bitsPerSample ~/ 8);
    final int chunkSize = 36 + dataSize;

    final ByteData byteData = ByteData(44 + dataSize);

    // RIFF Chunk
    byteData.setUint8(0, 0x52); // 'R'
    byteData.setUint8(1, 0x49); // 'I'
    byteData.setUint8(2, 0x46); // 'F'
    byteData.setUint8(3, 0x46); // 'F'
    byteData.setUint32(4, chunkSize, Endian.little);
    byteData.setUint8(8, 0x57); // 'W'
    byteData.setUint8(9, 0x41); // 'A'
    byteData.setUint8(10, 0x56); // 'V'
    byteData.setUint8(11, 0x45); // 'E'

    // fmt Subchunk
    byteData.setUint8(12, 0x66); // 'f'
    byteData.setUint8(13, 0x6D); // 'm'
    byteData.setUint8(14, 0x74); // 't'
    byteData.setUint8(15, 0x20); // ' '
    byteData.setUint32(16, 16, Endian.little); // 16 for PCM
    byteData.setUint16(20, 1, Endian.little); // AudioFormat: 1 = PCM
    byteData.setUint16(22, numChannels, Endian.little);
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, byteRate, Endian.little);
    byteData.setUint16(32, blockAlign, Endian.little);
    byteData.setUint16(34, bitsPerSample, Endian.little);

    // data Subchunk
    byteData.setUint8(36, 0x64); // 'd'
    byteData.setUint8(37, 0x61); // 'a'
    byteData.setUint8(38, 0x74); // 't'
    byteData.setUint8(39, 0x61); // 'a'
    byteData.setUint32(40, dataSize, Endian.little);

    int byteOffset = 44;
    for (int i = 0; i < totalSamples; i++) {
      final double t = i / sampleRate;
      final double envelope = exp(-decay * t);
      double sample = sin(2 * pi * frequency * t) * envelope * volume;

      if (harmonicFrequency != null && harmonicVolume > 0.0) {
        sample +=
            sin(2 * pi * harmonicFrequency * t) * envelope * harmonicVolume;
      }

      final int intSample = (sample.clamp(-1.0, 1.0) * 32767).toInt();
      byteData.setInt16(byteOffset, intSample, Endian.little);
      byteOffset += 2;
    }

    return byteData.buffer.asUint8List();
  }

  static Uint8List _generateGameOverWav() {
    const int sampleRate = 22050;
    const double durationSeconds = 0.45;
    final int totalSamples = (durationSeconds * sampleRate).toInt();
    const int numChannels = 1;
    const int bitsPerSample = 16;
    const int byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
    const int blockAlign = numChannels * (bitsPerSample ~/ 8);
    final int dataSize = totalSamples * (bitsPerSample ~/ 8);
    final int chunkSize = 36 + dataSize;

    final ByteData byteData = ByteData(44 + dataSize);

    // RIFF Chunk
    byteData.setUint8(0, 0x52);
    byteData.setUint8(1, 0x49);
    byteData.setUint8(2, 0x46);
    byteData.setUint8(3, 0x46);
    byteData.setUint32(4, chunkSize, Endian.little);
    byteData.setUint8(8, 0x57);
    byteData.setUint8(9, 0x41);
    byteData.setUint8(10, 0x56);
    byteData.setUint8(11, 0x45);

    // fmt Subchunk
    byteData.setUint8(12, 0x66);
    byteData.setUint8(13, 0x6D);
    byteData.setUint8(14, 0x74);
    byteData.setUint8(15, 0x20);
    byteData.setUint32(16, 16, Endian.little);
    byteData.setUint16(20, 1, Endian.little);
    byteData.setUint16(22, numChannels, Endian.little);
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, byteRate, Endian.little);
    byteData.setUint16(32, blockAlign, Endian.little);
    byteData.setUint16(34, bitsPerSample, Endian.little);

    // data Subchunk
    byteData.setUint8(36, 0x64);
    byteData.setUint8(37, 0x61);
    byteData.setUint8(38, 0x74);
    byteData.setUint8(39, 0x61);
    byteData.setUint32(40, dataSize, Endian.little);

    int byteOffset = 44;
    for (int i = 0; i < totalSamples; i++) {
      final double t = i / sampleRate;
      final double envelope = exp(-6.0 * t);
      final double freq = 140.0 - 85.0 * (t / durationSeconds);
      final double sample = sin(2 * pi * freq * t) * envelope * 0.4;

      final int intSample = (sample.clamp(-1.0, 1.0) * 32767).toInt();
      byteData.setInt16(byteOffset, intSample, Endian.little);
      byteOffset += 2;
    }

    return byteData.buffer.asUint8List();
  }
}
