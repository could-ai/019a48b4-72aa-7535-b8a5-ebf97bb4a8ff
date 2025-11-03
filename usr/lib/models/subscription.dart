enum SubscriptionCategory { entertainment, utilities, work, other }

class Subscription {
  final String name;
  final double amount;
  final DateTime renewalDate;
  final SubscriptionCategory category;
  final String iconUrl;

  Subscription({
    required this.name,
    required this.amount,
    required this.renewalDate,
    required this.category,
    required this.iconUrl,
  });
}
