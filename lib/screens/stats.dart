
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.currentUser?.uid;
    if (uid == null) {
      return const Center(child: Text('Not signed in'));
    }
    final dailyColl = FirebaseFirestore.instance
        .collection('users').doc(uid)
        .collection('aggregates').doc('daily')
        .collection('items')
        .orderBy('updatedAt', descending: true)
        .limit(14);

    final weeklyColl = FirebaseFirestore.instance
        .collection('users').doc(uid)
        .collection('aggregates').doc('weekly')
        .collection('items')
        .orderBy('updatedAt', descending: true)
        .limit(12);

    final monthlyColl = FirebaseFirestore.instance
        .collection('users').doc(uid)
        .collection('aggregates').doc('monthly')
        .collection('items')
        .orderBy('updatedAt', descending: true)
        .limit(12);

    Widget _buildList(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snap, String unit) {
      if (snap.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      final docs = snap.data?.docs ?? [];
      if (docs.isEmpty) return ListTile(title: Text(AppLocalizations.of(context)?.noData ?? 'No data yet'));
      return Column(
        children: docs.map((d) {
          final key = d.id;
          final totalSec = (d.data()['totalSec'] ?? 0).toDouble();
          final mins = (totalSec / 60).toStringAsFixed(1);
          return ListTile(
            title: Text(key),
            subtitle: Text('Total: $mins min'),
          );
        }).toList(),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('📊 ' + (AppLocalizations.of(context)?.statsTitle ?? 'Stats')),
          bottom: TabBar(tabs: [
            Tab(text: AppLocalizations.of(context)?.daily ?? 'Daily'),
            Tab(text: AppLocalizations.of(context)?.weekly ?? 'Weekly'),
            Tab(text: AppLocalizations.of(context)?.monthly ?? 'Monthly'),
          ]),
        ),
        body: TabBarView(children: [
          StreamBuilder(query: dailyColl, builder: (context, snap) => SingleChildScrollView(child: _buildList(snap, 'day'))),
          StreamBuilder(query: weeklyColl, builder: (context, snap) => SingleChildScrollView(child: _buildList(snap, 'week'))),
          StreamBuilder(query: monthlyColl, builder: (context, snap) => SingleChildScrollView(child: _buildList(snap, 'month'))),
        ]),
      ),
    );
  }
}
