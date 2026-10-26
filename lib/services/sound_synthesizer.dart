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
    261.63, // C4
    293.66, // D4
    329.63, // E4
    392.00, // G4
    440.00, // A4
    523.25, // C5
    587.33, // D5
    659.25, // E5
    783.99, // G5
    880.00, // A5
    1046.50, // C6
    1174.66, // D6
    1318.51, // E6
    1567.98, // G6
    1760.00, // A6
  ];

  static const List<double> _streakScale = [
    523.25, // C5
    587.33, // D5
    659.25, // E5
    698.46, // F5
    783.99, // G5
    880.00, // A5
    987.77, // B5
    1046.50, // C6
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
    await _initAudio();
  }

  Future<void> _initAudio() async {
    if (_initialized) return;
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

      // Audio context explicitly specifying AndroidAudioFocus.none to prevent pausing BGM
      final sfxContext = AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: const {
            AVAudioSessionOptions.mixWithOthers,
          },
        ),
      );

      // Pool of 6 lowLatency SoundPool players for instant, polyphonic playback
      for (int i = 0; i < 6; i++) {
        final player = AudioPlayer();
        if (!kIsWeb) {
          try {
            await player.setPlayerMode(PlayerMode.lowLatency);
          } catch (_) {}
          try {
            await player.setAudioContext(sfxContext);
          } catch (_) {}
        }
        try {
          await player.setVolume(_volume);
        } catch (_) {}
        _players.add(player);
      }

      // Pre-synthesize normal notes with full, resonant amplitude
      for (int i = 0; i < _pentatonicFrequencies.length; i++) {
        final wav = _generateWav(
          frequency: _pentatonicFrequencies[i],
          durationSeconds: 0.22,
          decay: 11.0,
          volume: 0.85,
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
          decay: 8.0,
          volume: 0.90,
          harmonicFrequency: harmonicFreq,
          harmonicVolume: 0.40,
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

      // Game over thud (140Hz down to 55Hz)
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
        frequency: 880.0,
        durationSeconds: 0.05,
        decay: 30.0,
        volume: 0.80,
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
        print('Error pre-rendering synthesized audio: $e');
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
      fileSource: _normalSourceCache[idx],
      fallbackBytes: _normalSoundCache[idx],
    );
  }

  void playPerfectPlacement(int streak) {
    if (_volume <= 0.0) return;
    final streakIndex = (streak - 1).clamp(0, _streakScale.length - 1);
    _play(
      fileSource: _streakSourceCache[streakIndex],
      fallbackBytes: _streakSoundCache[streakIndex],
    );
  }

  void playGameOver() {
    if (_volume <= 0.0) return;
    _play(
      fileSource: _gameOverSource,
      fallbackBytes: _gameOverSound,
    );
  }

  void playButton() {
    if (_volume <= 0.0) return;
    _play(
      fileSource: _buttonSource,
      fallbackBytes: _buttonSound,
    );
  }

  void _play({required Source? fileSource, required Uint8List? fallbackBytes}) {
    if (_volume <= 0.0 || _players.isEmpty) return;
    try {
      final player = _players[_playerIndex];
      _playerIndex = (_playerIndex + 1) % _players.length;

      if (fileSource != null) {
        player.play(fileSource, volume: _volume);
      } else if (fallbackBytes != null) {
        player.play(BytesSource(fallbackBytes), volume: _volume);
      }
    } catch (e) {
      if (kDebugMode) {
        print('SoundSynthesizer playback error: $e');
      }
    }
  }

  Uint8List _generateWav({
    required double frequency,
    required double durationSeconds,
    required double decay,
    required double volume,
    double? harmonicFrequency,
    double harmonicVolume = 0.0,
  }) {
    const int sampleRate = 22050;
    final int totalSamples = (sampleRate * durationSeconds).round();
    const int numChannels = 1;
    const int bitsPerSample = 16;
    const int byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
    const int blockAlign = numChannels * (bitsPerSample ~/ 8);
    final int subChunk2Size = totalSamples * blockAlign;
    final int chunkSize = 36 + subChunk2Size;

    final ByteData byteData = ByteData(44 + subChunk2Size);

    // RIFF header
    byteData.setUint8(0, 0x52); // 'R'
    byteData.setUint8(1, 0x49); // 'I'
    byteData.setUint8(2, 0x46); // 'F'
    byteData.setUint8(3, 0x46); // 'F'
    byteData.setUint32(4, chunkSize, Endian.little);
    byteData.setUint8(8, 0x57);  // 'W'
    byteData.setUint8(9, 0x41);  // 'A'
    byteData.setUint8(10, 0x56); // 'V'
    byteData.setUint8(11, 0x45); // 'E'

    // fmt subchunk
    byteData.setUint8(12, 0x66); // 'f'
    byteData.setUint8(13, 0x6D); // 'm'
    byteData.setUint8(14, 0x74); // 't'
    byteData.setUint8(15, 0x20); // ' '
    byteData.setUint32(16, 16, Endian.little); // SubChunk1Size (16 for PCM)
    byteData.setUint16(20, 1, Endian.little);  // AudioFormat (1 for PCM)
    byteData.setUint16(22, numChannels, Endian.little);
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, byteRate, Endian.little);
    byteData.setUint16(32, blockAlign, Endian.little);
    byteData.setUint16(34, bitsPerSample, Endian.little);

    // data subchunk
    byteData.setUint8(36, 0x64); // 'd'
    byteData.setUint8(37, 0x61); // 'a'
    byteData.setUint8(38, 0x74); // 't'
    byteData.setUint8(39, 0x61); // 'a'
    byteData.setUint32(40, subChunk2Size, Endian.little);

    // Write samples
    int offset = 44;
    for (int i = 0; i < totalSamples; i++) {
      final double t = i / sampleRate;
      final double envelope = exp(-decay * t);

      double sample = sin(2 * pi * frequency * t) * volume;
      if (harmonicFrequency != null && harmonicVolume > 0.0) {
        sample += sin(2 * pi * harmonicFrequency * t) * harmonicVolume;
      }
      sample *= envelope;

      final int sampleInt16 = (sample.clamp(-1.0, 1.0) * 32767).round();
      byteData.setInt16(offset, sampleInt16, Endian.little);
      offset += 2;
    }

    return byteData.buffer.asUint8List();
  }

  Uint8List _generateGameOverWav() {
    const int sampleRate = 22050;
    const double durationSeconds = 0.40;
    final int totalSamples = (sampleRate * durationSeconds).round();
    const int numChannels = 1;
    const int bitsPerSample = 16;
    const int byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
    const int blockAlign = numChannels * (bitsPerSample ~/ 8);
    final int subChunk2Size = totalSamples * blockAlign;
    final int chunkSize = 36 + subChunk2Size;

    final ByteData byteData = ByteData(44 + subChunk2Size);

    // RIFF header
    byteData.setUint8(0, 0x52); // 'R'
    byteData.setUint8(1, 0x49); // 'I'
    byteData.setUint8(2, 0x46); // 'F'
    byteData.setUint8(3, 0x46); // 'F'
    byteData.setUint32(4, chunkSize, Endian.little);
    byteData.setUint8(8, 0x57);  // 'W'
    byteData.setUint8(9, 0x41);  // 'A'
    byteData.setUint8(10, 0x56); // 'V'
    byteData.setUint8(11, 0x45); // 'E'

    // fmt subchunk
    byteData.setUint8(12, 0x66); // 'f'
    byteData.setUint8(13, 0x6D); // 'm'
    byteData.setUint8(14, 0x74); // 't'
    byteData.setUint8(15, 0x20); // ' '
    byteData.setUint32(16, 16, Endian.little);
    byteData.setUint16(20, 1, Endian.little);
    byteData.setUint16(22, numChannels, Endian.little);
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, byteRate, Endian.little);
    byteData.setUint16(32, blockAlign, Endian.little);
    byteData.setUint16(34, bitsPerSample, Endian.little);

    // data subchunk
    byteData.setUint8(36, 0x64); // 'd'
    byteData.setUint8(37, 0x61); // 'a'
    byteData.setUint8(38, 0x74); // 't'
    byteData.setUint8(39, 0x61); // 'a'
    byteData.setUint32(40, subChunk2Size, Endian.little);

    int offset = 44;
    for (int i = 0; i < totalSamples; i++) {
      final double t = i / sampleRate;
      final double envelope = exp(-6.0 * t);
      // Pitch drops from 140Hz down to 55Hz
      final double freq = 140.0 - 85.0 * (t / durationSeconds);
      final double sample = sin(2 * pi * freq * t) * envelope * 0.75;

      final int sampleInt16 = (sample.clamp(-1.0, 1.0) * 32767).round();
      byteData.setInt16(offset, sampleInt16, Endian.little);
      offset += 2;
    }

    return byteData.buffer.asUint8List();
  }

  void dispose() {
    for (final player in _players) {
      player.dispose();
    }
    _players.clear();
  }
}
