import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class MusicService {
  static final MusicService instance = MusicService._();

  MusicService._();

  final AudioPlayer _player = AudioPlayer();
  bool _isInitialized = false;
  bool _isMusicEnabled = true;
  bool _isAppInForeground = true;
  bool _pausedForAd = false;
  double _volume = 0.5;

  static const String musicAsset = 'music/stackpulse_background_music.mp3';

  bool get isMusicEnabled => _isMusicEnabled;
  double get volume => _volume;

  Future<void> initialize({
    required bool musicEnabled,
    double musicVolume = 0.5,
  }) async {
    _isMusicEnabled = musicEnabled;
    _volume = musicVolume.clamp(0.0, 1.0);

    if (_isInitialized) {
      await setVolume(_volume);
      await setMusicEnabled(musicEnabled);
      return;
    }
    _isInitialized = true;

    try {
      if (!kIsWeb) {
        try {
          final musicContext = AudioContext(
            android: const AudioContextAndroid(
              isSpeakerphoneOn: false,
              stayAwake: false,
              contentType: AndroidContentType.music,
              usageType: AndroidUsageType.media,
              audioFocus: AndroidAudioFocus.none,
            ),
            iOS: AudioContextIOS(
              category: AVAudioSessionCategory.playback,
              options: const {
                AVAudioSessionOptions.mixWithOthers,
              },
            ),
          );
          await _player.setAudioContext(musicContext);
        } catch (_) {}
      }

      _player.onPlayerStateChanged.listen((state) {
        // Automatically recover if Android pauses BGM unexpectedly while enabled
        if (state == PlayerState.paused &&
            _isMusicEnabled &&
            _isAppInForeground &&
            !_pausedForAd &&
            _volume > 0.0) {
          _player.resume();
        }
      });

      _player.onPlayerComplete.listen((_) {
        if (_isMusicEnabled && _isAppInForeground && !_pausedForAd) {
          _ensurePlaying();
        }
      });

      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(_volume);

      if (_isMusicEnabled && _isAppInForeground && _volume > 0.0) {
        await _ensurePlaying();
      }
    } catch (e) {
      if (kDebugMode) {
        print('MusicService initialize error: $e');
      }
    }
  }

  Future<void> _ensurePlaying() async {
    if (!_isMusicEnabled || !_isAppInForeground || _pausedForAd || _volume <= 0.0) {
      return;
    }
    try {
      await _player.setVolume(_volume);
      if (_player.state == PlayerState.paused) {
        try {
          await _player.resume();
        } catch (_) {
          await _start();
        }
      } else if (_player.state != PlayerState.playing) {
        await _start();
      }
    } catch (_) {
      await _start();
    }
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    try {
      await _player.setVolume(_volume);
      if (_volume > 0.0 && _isMusicEnabled && _isAppInForeground && !_pausedForAd) {
        await _ensurePlaying();
      } else if (_volume <= 0.0 && _player.state == PlayerState.playing) {
        await _player.pause();
      }
    } catch (e) {
      if (kDebugMode) {
        print('MusicService setVolume error: $e');
      }
    }
  }

  Future<void> _start() async {
    try {
      await _player.setVolume(_volume);
      await _player.play(AssetSource(musicAsset));
    } catch (e) {
      if (kDebugMode) {
        print('MusicService start error: $e');
      }
    }
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _isMusicEnabled = enabled;

    if (!_isInitialized) {
      await initialize(musicEnabled: enabled, musicVolume: _volume);
      return;
    }

    try {
      if (_isMusicEnabled) {
        _isAppInForeground = true;
        _pausedForAd = false;
        await _ensurePlaying();
      } else {
        await _player.pause();
      }
    } catch (e) {
      if (kDebugMode) {
        print('MusicService setMusicEnabled error: $e');
      }
    }
  }

  /// Pauses background music specifically for ad playback without corrupting app state
  Future<void> pauseForAd() async {
    if (!_isMusicEnabled) return;
    _pausedForAd = true;
    try {
      if (_player.state == PlayerState.playing) {
        await _player.pause();
      }
    } catch (_) {}
  }

  /// Resumes background music after ad dismissal if previously playing
  Future<void> resumeAfterAd() async {
    _pausedForAd = false;
    if (!_isMusicEnabled || !_isAppInForeground) return;
    await _ensurePlaying();
  }

  Future<void> onAppLifecycleStateChanged(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        _isAppInForeground = true;
        _pausedForAd = false;
        if (_isMusicEnabled) {
          await _ensurePlaying();
        }
        break;

      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        _isAppInForeground = false;
        try {
          if (_player.state == PlayerState.playing) {
            await _player.pause();
          }
        } catch (e) {
          if (kDebugMode) {
            print('MusicService pause error: $e');
          }
        }
        break;

      case AppLifecycleState.detached:
        _isAppInForeground = false;
        try {
          await _player.stop();
        } catch (_) {}
        break;
    }
  }

  void dispose() {
    _player.dispose();
  }
}
