import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundSynthesizer {
  static final SoundSynthesizer instance = SoundSynthesizer._();

  SoundSynthesizer._() {
    _initAudio();
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
  final Map<int, Uint8List> _streakSoundCache = {};
  Uint8List? _gameOverSound;
  Uint8List? _buttonSound;

  final List<AudioPlayer> _players = [];
  int _playerIndex = 0;
  bool _initialized = false;

  void _initAudio() {
    if (_initialized) return;
    _initialized = true;

    try {
      // Round robin pool of 4 players for overlapping polyphonic effects
      for (int i = 0; i < 4; i++) {
        final player = AudioPlayer();
        player.setPlayerMode(PlayerMode.lowLatency);
        _players.add(player);
      }

      // Pre-synthesize normal notes
      for (int i = 0; i < _pentatonicFrequencies.length; i++) {
        _normalSoundCache[i] = _generateWav(
          frequency: _pentatonicFrequencies[i],
          durationSeconds: 0.18,
          decay: 14.0,
          volume: 0.28,
        );
      }

      // Pre-synthesize streak notes with rich harmonic overtones
      for (int i = 0; i < _streakScale.length; i++) {
        final baseFreq = _streakScale[i];
        final harmonicFreq = i >= 4 ? baseFreq * 2.0 : baseFreq * 1.5;
        _streakSoundCache[i] = _generateWav(
          frequency: baseFreq,
          durationSeconds: 0.35,
          decay: 9.0,
          volume: 0.32,
          harmonicFrequency: harmonicFreq,
          harmonicVolume: 0.16,
        );
      }

      // Game over thud (120Hz down to 60Hz)
      _gameOverSound = _generateGameOverWav();

      // UI button click
      _buttonSound = _generateWav(
        frequency: 800.0,
        durationSeconds: 0.05,
        decay: 35.0,
        volume: 0.2,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error pre-rendering synthesized audio: $e');
      }
    }
  }

  void playNormalPlacement(int score) {
    final idx = score % _pentatonicFrequencies.length;
    final bytes = _normalSoundCache[idx];
    if (bytes != null) {
      _playBytes(bytes);
    }
  }

  void playPerfectPlacement(int streak) {
    final streakIndex = (streak - 1).clamp(0, _streakScale.length - 1);
    final bytes = _streakSoundCache[streakIndex];
    if (bytes != null) {
      _playBytes(bytes);
    }
  }

  void playGameOver() {
    if (_gameOverSound != null) {
      _playBytes(_gameOverSound!);
    }
  }

  void playButton() {
    if (_buttonSound != null) {
      _playBytes(_buttonSound!);
    }
  }

  void _playBytes(Uint8List bytes) {
    if (_players.isEmpty) return;
    try {
      final player = _players[_playerIndex];
      _playerIndex = (_playerIndex + 1) % _players.length;
      player.play(BytesSource(bytes));
    } catch (_) {}
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
      // Pitch drops from 140Hz down to 55Hz
      final double freq = 140.0 - 85.0 * (t / durationSeconds);
      final double sample = sin(2 * pi * freq * t) * envelope * 0.4;

      final int intSample = (sample.clamp(-1.0, 1.0) * 32767).toInt();
      byteData.setInt16(byteOffset, intSample, Endian.little);
      byteOffset += 2;
    }

    return byteData.buffer.asUint8List();
  }
}
