
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class IapService extends ChangeNotifier {
  IapService._();
  static final IapService instance = IapService._();

  final _iap = InAppPurchase.instance;
  bool available = false;

  // Product IDs (replace with your real IDs in stores)
  static const String kProductRemoveAds = 'remove_ads';
  static const String kProductPremiumMonthly = 'premium_monthly';
  static const String kProductPremiumYearly = 'premium_yearly';

  // State
  bool removeAds = false;
  bool isPremium = false;
  List<ProductDetails> products = [];
  StreamSubscription<List<PurchaseDetails>>? _sub;

  Future<void> init() async {
    available = await _iap.isAvailable();
    if (!available) return;

    // Query products
    final resp = await _iap.queryProductDetails({
      kProductRemoveAds,
      kProductPremiumMonthly,
      kProductPremiumYearly,
    });
    products = resp.productDetails;

    // Listen purchases
    _sub?.cancel();
    _sub = _iap.purchaseStream.listen(_onPurchaseUpdate, onDone: () {
      _sub?.cancel();
    }, onError: (e) {
      // handle error
    });

    notifyListeners();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> list) {
    for (final p in list) {
      if (p.status == PurchaseStatus.purchased || p.status == PurchaseStatus.restored) {
        if (p.productID == kProductRemoveAds) removeAds = true;
        if (p.productID == kProductPremiumMonthly || p.productID == kProductPremiumYearly) {
          isPremium = true;
        }
      }
      if (p.pendingCompletePurchase) {
        _iap.completePurchase(p);
      }
    }
    notifyListeners();
  }

  Future<void> buy(ProductDetails pd) async {
    final param = PurchaseParam(productDetails: pd);
    await _iap.buyNonConsumable(purchaseParam=param);
  }

  ProductDetails? find(String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}


Future<void> restore() async {
  if (!available) return;
  await _iap.restorePurchases();
}
