
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatefulWidget {

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {


  Query<Map<String, dynamic>> _query(String period) {
    final now = DateTime.now();
    String key;
    if (period == 'daily') {
      key = now.toIso8601String().substring(0,10);
    } else if (period == 'weekly') {
      final thursday = now.add(Duration(days: 3 - ((now.weekday + 6) % 7)));
      final firstThu = DateTime(thursday.year, 1, 4);
      final week = 1 + ((thursday.difference(firstThu).inDays) / 7).floor();
      key = '${thursday.year}-W${week.toString().padLeft(2,'0')}';
    } else {
      key = '${now.year}-${now.month.toString().padLeft(2,'0')}';
    }
    return FirebaseFirestore.instance
      .collection('leaderboards').doc(period)
      .collection('items').doc(key)
      .collection('users')
      .where('countryCode', whereIn: _country == 'All' ? null : [_country])
      .orderBy('totalSec', descending: true)
      .limit(50);
  }

  Widget _buildList(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snap) {
    if (snap.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    final docs = snap.data?.docs ?? [];
    if (docs.isEmpty) return Center(child: Text(AppLocalizations.of(context)?.noData ?? 'No data yet'));

    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, i) {
        final d = docs[i].data();
        final mins = ((d['totalSec'] ?? 0).toDouble() / 60).toStringAsFixed(1);
        final uid = d['uid'] ?? '—';
        final name = d['nickname'] ?? uid.substring(0, 6);
        final cc = (d['countryCode'] ?? '').toString();
        String ccLabel = cc.isNotEmpty ? '[$cc] ' : '';
        return ListTile(
          leading: CircleAvatar(child: Text('${i+1}')),
          title: Text('$ccLabel$name'),
          trailing: Text('$mins min'),
        );
      },
    );
  }

  String? _country = 'All';
  String? _school = 'All';
  String? _classId = 'All';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('🏆 ' + (AppLocalizations.of(context)?.leaderboard ?? 'Leaderboard')),
          bottom: TabBar(tabs: [
            Tab(text: AppLocalizations.of(context)?.daily ?? 'Daily'),
            Tab(text: AppLocalizations.of(context)?.weekly ?? 'Weekly'),
            Tab(text: AppLocalizations.of(context)?.monthly ?? 'Monthly'),
          ]),
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(children: [
              Text(AppLocalizations.of(context)?.filters ?? 'Filters'), const SizedBox(width: 8),
              DropdownButton<String>(
                value: _country,
                items: ['All','TW','JP','US','CN'].map((e)=>DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v){ setState(()=>_country=v); },
              ),
              const SizedBox(width: 8),
              SizedBox(width: 120, child: TextField(decoration: InputDecoration(hintText: AppLocalizations.of(context)?.filterSchool ?? 'School'), onChanged: (v){ _school = (v.isEmpty?'All':v); })),
              const SizedBox(width: 8),
              SizedBox(width: 100, child: TextField(decoration: InputDecoration(hintText: AppLocalizations.of(context)?.filterClass ?? 'Class'), onChanged: (v){ _classId = (v.isEmpty?'All':v); })),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: (){ setState((){}); }, child: Text(AppLocalizations.of(context)?.applyFilters ?? 'Apply Filters')),
              const SizedBox(width: 8),
              SizedBox(width: 120, child: TextField(decoration: InputDecoration(hintText: AppLocalizations.of(context)?.schoolFilter ?? 'School'), onChanged: (v){ _school = v.isEmpty ? 'All' : v; }),),
              const SizedBox(width: 8),
              SizedBox(width: 100, child: TextField(decoration: InputDecoration(hintText: AppLocalizations.of(context)?.classFilter ?? 'Class'), onChanged: (v){ _classId = v.isEmpty ? 'All' : v; }),),
            ]),
          ),
          Expanded(child: TabBarView(children: [
          StreamBuilder(query: _query('daily'), builder: (c, s) => _buildList(s)),
          StreamBuilder(query: _query('weekly'), builder: (c, s) => _buildList(s)),
          StreamBuilder(query: _query('monthly'), builder: (c, s) => _buildList(s)),
          ])),
      ),
    );
  }
}
