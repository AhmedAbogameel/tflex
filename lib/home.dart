import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tflex/cubit.dart';
import 'package:tflex/subscription_manager.dart';

class HomView extends StatelessWidget {
  const HomView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => HomeCubit()..init(context),
        child: BlocBuilder<HomeCubit, HomeStates>(
          builder: (context, state) {
            final cubit = context.watch<HomeCubit>();
            return Scaffold(
              appBar: AppBar(
                title: Text(cubit.isPremium ? "Premium " + (SubscriptionManager.purchaseHistory.isEmpty ? "" : SubscriptionManager.purchaseHistory.first.productId ?? '') : "Free"),
                backgroundColor: cubit.isPremium ? Colors.yellow.shade800 : Colors.green,
                actions: [
                  if (!cubit.isPremium)
                    IconButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: SubscriptionManager.products.map((e) => ListTile(
                              onTap: () {
                                Navigator.pop(context);
                                SubscriptionManager.subscribe(e.productId!);
                              },
                              title: Text(e.productId.toString()),
                              subtitle: Text(e.price.toString()),
                            )).toList(),
                          ),
                        ),
                      ),
                      icon: Icon(Icons.credit_card),
                    ),

                  if (cubit.isPremium)
                    IconButton(
                      onPressed: () {
                        SubscriptionManager.upgradeOrDowngrade();
                      },
                      icon: Icon(Icons.upgrade),
                    ),
                  if (cubit.isPremium)
                    IconButton(
                      onPressed: SubscriptionManager.cancelSubscription,
                      icon: Icon(Icons.cancel_outlined),
                    ),
                ],
              ),
              body: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    _card(
                      title: 'Movies',
                      included: true,
                    ),
                    SizedBox(height: 20),
                    _card(
                      title: 'Series',
                      included: cubit.isPremium,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _card({required String title, required bool included}) {
    return Expanded(
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: included ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        margin: EdgeInsets.all(30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: included ? Colors.green : Colors.red,
            width: 3,
          ),
        ),
      ),
    );
  }

}
