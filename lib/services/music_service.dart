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
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(_volume);

      if (_isMusicEnabled && _isAppInForeground) {
        await _start();
      }
    } catch (e) {
      if (kDebugMode) {
        print('MusicService initialize error: $e');
      }
    }
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    try {
      await _player.setVolume(_volume);
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
        if (_isAppInForeground) {
          if (_player.state == PlayerState.paused) {
            await _player.setVolume(_volume);
            await _player.resume();
          } else if (_player.state != PlayerState.playing) {
            await _start();
          }
        }
      } else {
        if (_player.state == PlayerState.playing) {
          await _player.pause();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('MusicService setMusicEnabled error: $e');
      }
    }
  }

  Future<void> onAppLifecycleStateChanged(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        _isAppInForeground = true;
        if (_isMusicEnabled) {
          try {
            if (_player.state == PlayerState.paused) {
              await _player.setVolume(_volume);
              await _player.resume();
            } else if (_player.state != PlayerState.playing) {
              await _start();
            }
          } catch (e) {
            if (kDebugMode) {
              print('MusicService resume error: $e');
            }
          }
        }
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
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
    }
  }

  Future<void> dispose() async {
    try {
      await _player.stop();
      await _player.dispose();
    } catch (_) {}
  }
}
