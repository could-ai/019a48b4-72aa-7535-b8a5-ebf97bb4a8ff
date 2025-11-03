import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../widgets/loopless_logo.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Mock data for subscriptions
  final List<Subscription> _subscriptions = [
    Subscription(
        name: 'Netflix',
        amount: 15.99,
        renewalDate: DateTime.now().add(const Duration(days: 5)),
        category: SubscriptionCategory.entertainment,
        iconUrl: 'https://via.placeholder.com/50/FF0000/FFFFFF?Text=N'),
    Subscription(
        name: 'Spotify',
        amount: 9.99,
        renewalDate: DateTime.now().add(const Duration(days: 12)),
        category: SubscriptionCategory.entertainment,
        iconUrl: 'https://via.placeholder.com/50/1DB954/FFFFFF?Text=S'),
    Subscription(
        name: 'AWS',
        amount: 45.50,
        renewalDate: DateTime.now().add(const Duration(days: 2)),
        category: SubscriptionCategory.work,
        iconUrl: 'https://via.placeholder.com/50/FF9900/FFFFFF?Text=A'),
    Subscription(
        name: 'Electricity',
        amount: 75.00,
        renewalDate: DateTime.now().add(const Duration(days: 20)),
        category: SubscriptionCategory.utilities,
        iconUrl: 'https://via.placeholder.com/50/FFFF00/000000?Text=E'),
    Subscription(
        name: 'Gym Membership',
        amount: 30.00,
        renewalDate: DateTime.now().add(const Duration(days: 1)),
        category: SubscriptionCategory.other,
        iconUrl: 'https://via.placeholder.com/50/0000FF/FFFFFF?Text=G'),
  ];

  double _calculateTotalMonthlySpend() {
    return _subscriptions.fold(0.0, (sum, item) => sum + item.amount);
  }

  List<Subscription> _getUpcomingRenewals() {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    return _subscriptions
        .where((s) =>
            s.renewalDate.isAfter(now) && s.renewalDate.isBefore(nextWeek))
        .toList();
  }

  Subscription _getHighestSubscription() {
    return _subscriptions.reduce((a, b) => a.amount > b.amount ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final totalSpend = _calculateTotalMonthlySpend();
    final upcomingRenewals = _getUpcomingRenewals();
    final highestSubscription = _getHighestSubscription();
    final currencyFormat =
        NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const LooplessLogo(),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // TODO: Implement add subscription
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSummaryCard(
                totalSpend, _subscriptions.length, highestSubscription, currencyFormat),
            const TabBar(
              tabs: [
                Tab(text: 'All Subscriptions'),
                Tab(text: 'Upcoming'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  SubscriptionList(
                      subscriptions: _subscriptions,
                      currencyFormat: currencyFormat),
                  SubscriptionList(
                      subscriptions: upcomingRenewals,
                      currencyFormat: currencyFormat),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Implement add subscription
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double totalSpend, int activeSubs,
      Subscription highestSub, NumberFormat currencyFormat) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Total Monthly Spend',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(totalSpend),
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem('Active Subs', activeSubs.toString()),
                _buildSummaryItem(
                    'Highest Sub', currencyFormat.format(highestSub.amount)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class SubscriptionList extends StatelessWidget {
  final List<Subscription> subscriptions;
  final NumberFormat currencyFormat;

  const SubscriptionList({
    super.key,
    required this.subscriptions,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    if (subscriptions.isEmpty) {
      return const Center(
        child: Text('No subscriptions to show.'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: subscriptions.length,
      itemBuilder: (context, index) {
        final sub = subscriptions[index];
        return SubscriptionListItem(
            subscription: sub, currencyFormat: currencyFormat);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 12),
    );
  }
}

class SubscriptionListItem extends StatelessWidget {
  final Subscription subscription;
  final NumberFormat currencyFormat;

  const SubscriptionListItem({
    super.key,
    required this.subscription,
    required this.currencyFormat,
  });

  Color _getCategoryColor(SubscriptionCategory category) {
    switch (category) {
      case SubscriptionCategory.entertainment:
        return Colors.redAccent;
      case SubscriptionCategory.utilities:
        return Colors.blueAccent;
      case SubscriptionCategory.work:
        return Colors.greenAccent;
      case SubscriptionCategory.other:
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysUntilRenewal =
        subscription.renewalDate.difference(DateTime.now()).inDays;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(subscription.category),
          child: ClipOval(
            child: Image.network(
              subscription.iconUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, color: Colors.white),
            ),
          ),
        ),
        title: Text(subscription.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          'Renews in $daysUntilRenewal day${daysUntilRenewal == 1 ? '' : 's'}',
          style: TextStyle(
              color: daysUntilRenewal < 7 ? Colors.orangeAccent : Colors.white70),
        ),
        trailing: Text(
          currencyFormat.format(subscription.amount),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
