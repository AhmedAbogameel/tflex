import 'dart:async';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'subscription_manager.dart';

const String kMonthSKU = "month";
const String kYearSKU = "year";
const String kAppPackageName = "com.tflex.tflex";

class SubscriptionManagerImpl implements SubscriptionManager {

  final FlutterInappPurchase flutterInappPurchase;

  SubscriptionManagerImpl({required this.flutterInappPurchase});

  List<IAPItem> products = [];
  List<PurchasedItem> purchaseHistory = [];

  late StreamSubscription _successStreamSubscription;
  late StreamSubscription _failureStreamSubscription;

  /// Initialize Store Connection and get Products and PurchasesHistory
  @override
  Future<void> initStore() async {
    await flutterInappPurchase.initialize();
    await getProducts();
    await getPurchasedHistory();
  }

  /// Should call this function when you don't need subscription anymore
  @override
  Future<void> closeStore() async {
    await flutterInappPurchase.finalize();
    _successStreamSubscription.cancel();
    _failureStreamSubscription.cancel();
  }

  /// Called when you need current subscription details
  /// it returns null if user is free
  @override
  Future<IAPItem?> getCurrentSubscription(String productID) async {
    try {
      return products.firstWhere((element) => element.productId == productID);
    } catch (e) {
      return null;
    }
  }

  /// Get Available Subscriptions on Store
  /// You don't need to call this function it called auto when initStore called
  @override
  Future<List<IAPItem>> getProducts() async {
    if (products.isNotEmpty) {
      return products;
    }
    final month = await _getProduct(kMonthSKU);
    final year = await _getProduct(kYearSKU);
    products.add(month);
    products.add(year);
    return products;
  }

  /// We call one single item due to calling more than one returning empty List
  Future<IAPItem> _getProduct(String id) async {
    return (await flutterInappPurchase.getSubscriptions([id])).first;
  }

  /// Getting History Purchases return Un Empty List if there is available Purchase
  /// You don't need to call this function it called auto when initStore called
  @override
  Future<List<PurchasedItem>> getPurchasedHistory() async {
    purchaseHistory = await FlutterInappPurchase.instance.getAvailablePurchases() ?? [];
    return purchaseHistory;
  }

  /// Return true if user is has subscription
  @override
  Future<bool> checkSubscription(String productID) async {
    final result = await flutterInappPurchase.checkSubscribed(sku: productID);
    return result;
  }

  /// Subscribe to Plan
  @override
  Future<void> subscribe(String productID) async {
    await flutterInappPurchase.requestSubscription(productID);
  }

  /// Upgrade plan to year if you were on month and downgrade if year User must be subscribed to one plan
  @override
  Future<void> upgradeOrDowngrade(PurchasedItem lastPurchasedItem) async {
    await flutterInappPurchase.requestSubscription(
        lastPurchasedItem.productId == 'month' ? 'year' : 'month',
        purchaseTokenAndroid: lastPurchasedItem.purchaseToken,
        prorationModeAndroid: AndroidProrationMode.DEFERRED,
    );
  }

  /// Should trigger onPurchased Function when the purchase is Successful
  /// you can inject your Alert / Snack Bar or any Specific action
  @override
  void onPurchasedSuccess({required Function(PurchasedItem) onPurchased}) {
    _successStreamSubscription = FlutterInappPurchase.purchaseUpdated.listen((event) async {
      await FlutterInappPurchase.instance.finishTransaction(event!);
      await getPurchasedHistory();
      onPurchased(event);
    });
  }

  /// Should trigger onPurchased Function when the purchase has error
  /// you can inject your Alert / Snack Bar or any Specific action
  @override
  void onPurchasedError({required Function(PurchaseResult) onError}) {
    _failureStreamSubscription = FlutterInappPurchase.purchaseError.listen((event) {
      onError(event!);
    });
  }

  /// Trigger a deep link to google play manage subscription
  /// so users can cancel there subscriptions
  @override
  Future<void> cancelSubscription(String currentProductID) async {
    await flutterInappPurchase.manageSubscription(currentProductID, kAppPackageName);
  }

}