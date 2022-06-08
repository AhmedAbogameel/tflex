import 'dart:async';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

abstract class SubscriptionManager {

  static List<IAPItem> products = [];
  static List<PurchasedItem> purchaseHistory = [];

  static Future<void> initStore() async {
    await closeStore();
    await FlutterInappPurchase.instance.initialize();
  }

  static Future<void> closeStore() async {
    await FlutterInappPurchase.instance.finalize();
  }

  static Future<List<IAPItem>> getProducts() async {
    if (products.isNotEmpty) {
      return products;
    }
    final month = await _getProduct('month');
    final year = await _getProduct('year');
    products.add(month);
    products.add(year);
    return products;
  }

  static Future<IAPItem> _getProduct(String id) async {
    return (await FlutterInappPurchase.instance.getSubscriptions([id])).first;
  }

  static void subscribe(String productID) {
    FlutterInappPurchase.instance.requestSubscription(productID);
  }

  static void upgradeOrDowngrade() async {
    final lastPurchase = (await SubscriptionManager.getPurchasedHistory())!.first;
    FlutterInappPurchase.instance.requestSubscription(
      lastPurchase.productId == 'month' ? 'year' : 'month',
      purchaseTokenAndroid: lastPurchase.purchaseToken,
      prorationModeAndroid: AndroidProrationMode.DEFERRED,
    );
  }

  static void cancelSubscription() async {
    final lastPurchase = (await getPurchasedHistory())!.first;
    FlutterInappPurchase.instance.manageSubscription(lastPurchase.productId!, 'com.tflex.tflex');
  }

  static Future<List<PurchasedItem>?> getPurchasedHistory() async {
    if (purchaseHistory.isNotEmpty) {
      return purchaseHistory;
    }
    purchaseHistory = await FlutterInappPurchase.instance.getAvailablePurchases() ?? [];
    return purchaseHistory;
  }

  static void listenForPurchases({required Function(PurchasedItem) onPurchased}) {
    FlutterInappPurchase.purchaseUpdated.listen((event) async {
      await FlutterInappPurchase.instance.finishTransaction(event!);
      await getPurchasedHistory();
      onPurchased(event);
    });
  }

  static void listenForPurchasesError({required Function(PurchaseResult) onError}) {
    FlutterInappPurchase.purchaseError.listen((event) {
      onError(event!);
    });
  }

}