
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ads_service.dart';
import '../services/iap_service.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _ad;

  @override
  void initState() {
    super.initState();
    AdsService.instance.init().then((_) {
      if (!AdsService.instance.adsDisabled) {
        final ad = AdsService.instance.createBanner();
        setState(() => _ad = ad);
      }
    });
    IapService.instance.addListener(_onIap);
  }

  void _onIap() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    IapService.instance.removeListener(_onIap);
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AdsService.instance.adsDisabled) return const SizedBox.shrink();
    if (_ad == null) return const SizedBox(height: 50);
    return SizedBox(
      width: _ad!.size.width.toDouble(),
      height: _ad!.size.height.toDouble(),
      child: AdWidget(ad: _ad!),
    );
  }
}
