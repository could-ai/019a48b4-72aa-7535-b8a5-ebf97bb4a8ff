import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';

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
        .where((s) => s.renewalDate.isAfter(now) && s.renewalDate.isBefore(nextWeek))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final totalSpend = _calculateTotalMonthlySpend();
    final upcomingRenewals = _getUpcomingRenewals();
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildStats(totalSpend, upcomingRenewals.length, currencyFormat),
          const SizedBox(height: 24),
          _buildSubscriptionList('Upcoming Renewals', upcomingRenewals, currencyFormat),
          const SizedBox(height: 24),
          _buildSubscriptionList('All Subscriptions', _subscriptions, currencyFormat),
        ],
      ),
    );
  }

  Widget _buildStats(double totalSpend, int upcomingCount, NumberFormat currencyFormat) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: StatCard(
            title: 'Monthly Spend',
            value: currencyFormat.format(totalSpend),
            icon: Icons.attach_money,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Active Subs',
            value: _subscriptions.length.toString(),
            icon: Icons.subscriptions,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Upcoming',
            value: upcomingCount.toString(),
            icon: Icons.notifications,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionList(String title, List<Subscription> subs, NumberFormat currencyFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (subs.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(child: Text('No subscriptions to show.')),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: subs.length,
            itemBuilder: (context, index) {
              final sub = subs[index];
              return SubscriptionListItem(subscription: sub, currencyFormat: currencyFormat);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    final daysUntilRenewal = subscription.renewalDate.difference(DateTime.now()).inDays;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: ClipOval(
            child: Image.network(
              subscription.iconUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(subscription.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          'Renews in $daysUntilRenewal day${daysUntilRenewal == 1 ? '' : 's'}',
          style: TextStyle(color: daysUntilRenewal < 7 ? Colors.orangeAccent : Colors.white70),
        ),
        trailing: Text(
          currencyFormat.format(subscription.amount),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
