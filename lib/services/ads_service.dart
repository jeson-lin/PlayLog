
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import 'iap_service.dart';

class AdsService {
  AdsService._();
  static final AdsService instance = AdsService._();
  InterstitialAd? _interstitial;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
  }

  bool get adsDisabled => IapService.instance.removeAds || IapService.instance.isPremium;

  String get _testBannerId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  String get _testInterstitialId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  void ensureInterstitialLoaded() {
    if (adsDisabled) return;
    if (_interstitial != null) return;
    InterstitialAd.load(
      adUnitId: _testInterstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (e) => _interstitial = null,
      ),
    );
  }

  void showInterstitialIfReady() {
    if (adsDisabled) return;
    final ad = _interstitial;
    if (ad == null) return;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) => ad.dispose(),
      onAdFailedToShowFullScreenContent: (ad, e) => ad.dispose(),
    );
    ad.show();
    _interstitial = null;
  }

  BannerAd? createBanner() {
    if (adsDisabled) return null;
    return BannerAd(
      adUnitId: _testBannerId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: const BannerAdListener(),
    )..load();
  }
}
