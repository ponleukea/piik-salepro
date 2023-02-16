import 'model/subscription_model.dart';
import 'model/subscription_plan_model.dart';

class Subscription {
  static List<SubscriptionPlanModel> subscriptionPlan = [];
  static SubscriptionPlanModel customersActivePlan = SubscriptionPlanModel(
    subscriptionName: 'Free',
    saleNumber: 0,
    purchaseNumber: 0,
    products: 0,
    partiesNumber: 0,
    duration: 0,
    dueNumber: 0,
    offerPrice: 0,
    subscriptionPrice: 0,
  );
  static const String currency = 'USD';
  static SubscriptionModel freeSubscriptionModel = SubscriptionModel(
    dueNumber: 0,
    duration: 0,
    partiesNumber: 0,
    products: 0,
    purchaseNumber: 0,
    saleNumber: 0,
    subscriptionDate: DateTime.now().toString(),
    subscriptionName: 'Free',
  );
}
