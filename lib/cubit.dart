import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tflex/subscription_manager.dart';

class HomeCubit extends Cubit<HomeStates> {
  HomeCubit() : super(HomeInit());

  bool isPremium = false;

  Future<void> init(context) async {
    await SubscriptionManager.initStore();
    final history = await SubscriptionManager.getPurchasedHistory();
    if (history != null && history.isNotEmpty) {
      isPremium = true;
      emit(HomeInit());
    }
    await SubscriptionManager.getProducts();
    SubscriptionManager.listenForPurchases(
      onPurchased: (purchasedItem) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(purchasedItem.purchaseToken!),
            backgroundColor: Colors.green,
          ),
        );
        isPremium = true;
        emit(HomeInit());
      }
    );
    SubscriptionManager.listenForPurchasesError(
      onError: (event) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(event.message!),
            backgroundColor: Colors.red,
          ),
        );
      }
    );
  }

  @override
  Future<void> close() async {
    SubscriptionManager.closeStore();
    super.close();
  }

}

abstract class HomeStates {}

class HomeInit extends HomeStates {}

class HomeLoading extends HomeStates {}