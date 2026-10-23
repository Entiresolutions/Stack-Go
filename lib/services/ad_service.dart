import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'music_service.dart';

class AdService {
  static final AdService instance = AdService._();

  AdService._();

  /// User's AdMob Ad Unit IDs from dashboard
  static const String adUnitId = 'ca-app-pub-3794659976212193/3368291483';
  static const String rewardedAdUnitId =
      'ca-app-pub-3794659976212193/9929744688';

  /// Standard Google Test Ad Unit IDs (used as backup if new ad unit is still propagating)
  static const String testAppOpenAdUnitId =
      'ca-app-pub-3940256099942544/9257395921';
  static const String testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isLoadingRewarded = false;
  bool _isShowingAd = false;
  AppOpenAd? _appOpenAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  bool get isAdReady => _appOpenAd != null || _interstitialAd != null;
  bool get isRewardedAdReady => _rewardedAd != null;

  /// Initializes the Google Mobile Ads SDK on supported platforms
  Future<void> initialize() async {
    if (!isMobile || _isInitialized) return;
    _isInitialized = true;

    try {
      await MobileAds.instance.initialize();
      preloadAd();
      preloadRewardedAd();
    } catch (e) {
      if (kDebugMode) {
        print('AdService initialization error: $e');
      }
    }
  }

  /// Preloads a full-screen ad (App Open / Interstitial) in the background
  void preloadAd() {
    if (!isMobile || isAdReady || _isLoading) return;
    _isLoading = true;

    // First attempt to load with the user's configured Ad Unit ID
    _loadAppOpenAd(
      unitId: adUnitId,
      onSuccess: (ad) {
        _appOpenAd = ad;
        _isLoading = false;
      },
      onFailure: () {
        // Fallback 1: Try Interstitial with the user's unit ID
        _loadInterstitialAd(
          unitId: adUnitId,
          onSuccess: (ad) {
            _interstitialAd = ad;
            _isLoading = false;
          },
          onFailure: () {
            // Fallback 2 (Debug only): Test ad unit while production unit propagates (takes up to 1 hr)
            if (kDebugMode) {
              _loadAppOpenAd(
                unitId: testAppOpenAdUnitId,
                onSuccess: (ad) {
                  _appOpenAd = ad;
                  _isLoading = false;
                },
                onFailure: () {
                  _isLoading = false;
                },
              );
            } else {
              _isLoading = false;
            }
          },
        );
      },
    );
  }

  /// Preloads a rewarded ad in the background for "Watch and get a chance"
  void preloadRewardedAd() {
    if (!isMobile || isRewardedAdReady || _isLoadingRewarded) return;
    _isLoadingRewarded = true;

    _loadRewardedAd(
      unitId: rewardedAdUnitId,
      onSuccess: (ad) {
        _rewardedAd = ad;
        _isLoadingRewarded = false;
      },
      onFailure: () {
        if (kDebugMode) {
          // Fallback to Google test rewarded unit while production unit propagates
          _loadRewardedAd(
            unitId: testRewardedAdUnitId,
            onSuccess: (ad) {
              _rewardedAd = ad;
              _isLoadingRewarded = false;
            },
            onFailure: () {
              _isLoadingRewarded = false;
            },
          );
        } else {
          _isLoadingRewarded = false;
        }
      },
    );
  }

  void _loadAppOpenAd({
    required String unitId,
    required Function(AppOpenAd) onSuccess,
    required VoidCallback onFailure,
  }) {
    AppOpenAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('AppOpenAd successfully loaded ($unitId)');
          }
          onSuccess(ad);
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('AppOpenAd failed to load ($unitId): ${error.message}');
          }
          onFailure();
        },
      ),
    );
  }

  void _loadInterstitialAd({
    required String unitId,
    required Function(InterstitialAd) onSuccess,
    required VoidCallback onFailure,
  }) {
    InterstitialAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('InterstitialAd successfully loaded ($unitId)');
          }
          onSuccess(ad);
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('InterstitialAd failed to load ($unitId): ${error.message}');
          }
          onFailure();
        },
      ),
    );
  }

  void _loadRewardedAd({
    required String unitId,
    required Function(RewardedAd) onSuccess,
    required VoidCallback onFailure,
  }) {
    RewardedAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('RewardedAd successfully loaded ($unitId)');
          }
          onSuccess(ad);
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('RewardedAd failed to load ($unitId): ${error.message}');
          }
          onFailure();
        },
      ),
    );
  }

  /// Shows full-screen ad (e.g. before starting the game or when returning Home from Game Over).
  /// Calls [onComplete] once the ad is closed, dismissed, or if no ad is available.
  Future<void> showAd({required VoidCallback onComplete}) async {
    // If on Desktop / Web or not mobile, immediately proceed
    if (!isMobile) {
      onComplete();
      return;
    }

    if (_isShowingAd) {
      return;
    }

    // If ad is ready, display it
    if (_appOpenAd != null) {
      _showAppOpenAd(onComplete);
      return;
    }

    if (_interstitialAd != null) {
      _showInterstitialAd(onComplete);
      return;
    }

    // If ad is not ready yet, attempt quick load with timeout
    final completer = Completer<void>();
    bool handled = false;

    void finish() {
      if (!handled) {
        handled = true;
        completer.complete();
        onComplete();
      }
    }

    // Max 2.5s wait so user doesn't get stuck on slow network
    final timer = Timer(const Duration(milliseconds: 2500), finish);

    _loadAppOpenAd(
      unitId: adUnitId,
      onSuccess: (ad) {
        timer.cancel();
        _appOpenAd = ad;
        if (!handled) {
          _showAppOpenAd(finish);
        }
      },
      onFailure: () {
        timer.cancel();
        finish();
      },
    );

    await completer.future;
  }

  /// Shows the rewarded ad for "Watch and get a chance".
  /// Returns `true` ONLY if the user watched the ad and earned the reward.
  /// Returns `false` if the ad is not available, fails to load, or is dismissed without reward.
  /// Strictly grants NO reward unless the ad is successfully watched.
  Future<bool> showRewardedAd({
    required VoidCallback onRewardEarned,
    Function(String reason)? onAdUnavailable,
  }) async {
    // 1. If not on mobile device (e.g. Windows desktop/web test), notify
    if (!isMobile) {
      onAdUnavailable?.call(
          "Rewarded ads are only available on Android and iOS devices.");
      return false;
    }

    if (_isShowingAd) {
      return false;
    }

    // 2. If a preloaded rewarded ad is ready in memory, show it immediately
    if (_rewardedAd != null) {
      return await _displayRewardedAd(
        onRewardEarned: onRewardEarned,
        onAdUnavailable: onAdUnavailable,
      );
    }

    // 3. If no ad is preloaded, attempt a live fetch with a 4.0-second timeout
    final completer = Completer<bool>();
    bool handled = false;

    void finish(bool success, [String? reason]) {
      if (!handled) {
        handled = true;
        if (!success && reason != null) {
          onAdUnavailable?.call(reason);
        }
        if (!completer.isCompleted) {
          completer.complete(success);
        }
      }
    }

    final timer = Timer(const Duration(milliseconds: 4000), () {
      finish(false,
          "Ad not available. Please check your internet connection and try again.");
    });

    _loadRewardedAd(
      unitId: rewardedAdUnitId,
      onSuccess: (ad) async {
        timer.cancel();
        _rewardedAd = ad;
        if (!handled) {
          final res = await _displayRewardedAd(
            onRewardEarned: onRewardEarned,
            onAdUnavailable: onAdUnavailable,
          );
          finish(res);
        }
      },
      onFailure: () {
        if (kDebugMode) {
          _loadRewardedAd(
            unitId: testRewardedAdUnitId,
            onSuccess: (ad) async {
              timer.cancel();
              _rewardedAd = ad;
              if (!handled) {
                final res = await _displayRewardedAd(
                  onRewardEarned: onRewardEarned,
                  onAdUnavailable: onAdUnavailable,
                );
                finish(res);
              }
            },
            onFailure: () {
              timer.cancel();
              finish(false,
                  "Ad not available. Please check your internet connection and try again.");
            },
          );
        } else {
          timer.cancel();
          finish(false,
              "Ad not available. Please check your internet connection and try again.");
        }
      },
    );

    return await completer.future;
  }

  /// Backward-compatible alias for showPlayAd
  Future<void> showPlayAd({required VoidCallback onComplete}) =>
      showAd(onComplete: onComplete);

  void _showAppOpenAd(VoidCallback onDismissed) {
    final ad = _appOpenAd;
    _appOpenAd = null;

    if (ad == null) {
      onDismissed();
      return;
    }

    _isShowingAd = true;

    // Pause game music while ad is playing
    MusicService.instance.onAppLifecycleStateChanged(AppLifecycleState.paused);

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        MusicService.instance
            .onAppLifecycleStateChanged(AppLifecycleState.resumed);
        onDismissed();
        preloadAd(); // preload for next time
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        ad.dispose();
        MusicService.instance
            .onAppLifecycleStateChanged(AppLifecycleState.resumed);
        onDismissed();
        preloadAd();
      },
    );

    ad.show();
  }

  void _showInterstitialAd(VoidCallback onDismissed) {
    final ad = _interstitialAd;
    _interstitialAd = null;

    if (ad == null) {
      onDismissed();
      return;
    }

    _isShowingAd = true;

    // Pause game music while ad is playing
    MusicService.instance.onAppLifecycleStateChanged(AppLifecycleState.paused);

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        MusicService.instance
            .onAppLifecycleStateChanged(AppLifecycleState.resumed);
        onDismissed();
        preloadAd(); // preload for next time
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        ad.dispose();
        MusicService.instance
            .onAppLifecycleStateChanged(AppLifecycleState.resumed);
        onDismissed();
        preloadAd();
      },
    );

    ad.show();
  }

  Future<bool> _displayRewardedAd({
    required VoidCallback onRewardEarned,
    Function(String reason)? onAdUnavailable,
  }) async {
    final ad = _rewardedAd;
    _rewardedAd = null;

    if (ad == null) {
      onAdUnavailable?.call(
          "Ad not available. Please check your internet connection and try again.");
      return false;
    }

    final completer = Completer<bool>();
    _isShowingAd = true;
    bool rewardEarned = false;

    // Pause music during ad
    MusicService.instance.onAppLifecycleStateChanged(AppLifecycleState.paused);

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        MusicService.instance
            .onAppLifecycleStateChanged(AppLifecycleState.resumed);

        if (rewardEarned) {
          onRewardEarned();
          if (!completer.isCompleted) completer.complete(true);
        } else {
          // Closed before earning reward
          onAdUnavailable?.call(
              "You closed the ad before earning the chance. Watch the full ad to continue.");
          if (!completer.isCompleted) completer.complete(false);
        }
        preloadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        ad.dispose();
        MusicService.instance
            .onAppLifecycleStateChanged(AppLifecycleState.resumed);

        // Strict: failed to show -> NO chance awarded!
        onAdUnavailable?.call(
            "Ad not available. Please check your internet connection and try again.");
        if (!completer.isCompleted) completer.complete(false);
        preloadRewardedAd();
      },
    );

    ad.show(
      onUserEarnedReward: (adWithoutView, reward) {
        rewardEarned = true;
      },
    );

    return await completer.future;
  }
}
