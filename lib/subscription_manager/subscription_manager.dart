import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

abstract class SubscriptionManager {

  Future<void> initStore();
  Future<void> closeStore();

  Future<IAPItem?> getCurrentSubscription(String productID);
  Future<bool> checkSubscription(String productID);

  Future<List<IAPItem>> getProducts();
  Future<List<PurchasedItem>?> getPurchasedHistory();

  void onPurchasedSuccess({required Function(PurchasedItem) onPurchased});
  void onPurchasedError({required Function(PurchaseResult) onError});

  Future<void> subscribe(String productID);
  Future<void> upgradeOrDowngrade(PurchasedItem lastPurchasedItem);
  Future<void> cancelSubscription(String currentProductID);

}