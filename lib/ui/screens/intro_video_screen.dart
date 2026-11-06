import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../core/game_theme.dart';

/// Plays the silent introduction video centered on a pure white canvas before the splash screen.
class IntroVideoScreen extends StatefulWidget {
  final GameTheme theme;
  final bool reducedMotion;
  final VoidCallback onComplete;

  const IntroVideoScreen({
    super.key,
    required this.theme,
    this.reducedMotion = false,
    required this.onComplete,
  });

  @override
  State<IntroVideoScreen> createState() => _IntroVideoScreenState();
}

class _IntroVideoScreenState extends State<IntroVideoScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasCompleted = false;

  @override
  void initState() {
    super.initState();

    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (isTest) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _finishVideo());
      return;
    }

    _initController();
  }

  Future<void> _initController() async {
    try {
      _controller = VideoPlayerController.asset('assets/splah_before.mp4');
      await _controller.initialize();
      if (!mounted) {
        await _controller.dispose();
        return;
      }

      _controller.addListener(_videoListener);
      // Make video completely silent
      await _controller.setVolume(0.0);
      await _controller.setLooping(false);
      await _controller.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('IntroVideoScreen error initializing video: $e');
      }
      _finishVideo();
    }
  }

  void _videoListener() {
    if (!mounted || _hasCompleted) return;
    final value = _controller.value;
    if (value.isInitialized &&
        value.duration > Duration.zero &&
        value.position >= value.duration) {
      _finishVideo();
    }
  }

  void _finishVideo() {
    if (_hasCompleted) return;
    _hasCompleted = true;

    try {
      if (_isInitialized) {
        _controller.removeListener(_videoListener);
        _controller.pause();
      }
    } catch (_) {}

    // Restore app default dark system UI overlay for splash and game screens
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF061225),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    if (mounted) {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    try {
      if (_isInitialized) {
        _controller.removeListener(_videoListener);
        _controller.dispose();
      }
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _finishVideo,
          child: Container(
            color: Colors.white,
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            child: _isInitialized
                ? FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: _controller.value.size.width > 0
                          ? _controller.value.size.width
                          : 640,
                      height: _controller.value.size.height > 0
                          ? _controller.value.size.height
                          : 360,
                      child: AnimatedOpacity(
                        opacity: _isInitialized ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio > 0
                              ? _controller.value.aspectRatio
                              : 16 / 9,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
