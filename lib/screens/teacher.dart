
import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/auth_service.dart';

class TeacherScreen extends StatefulWidget {
  const TeacherScreen({super.key});
  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  String _weekKey(DateTime t) {
    final thursday = t.add(Duration(days: 3 - ((t.weekday + 6) % 7)));
    final firstThu = DateTime(thursday.year, 1, 4);
    final week = 1 + ((thursday.difference(firstThu).inDays) / 7).floor();
    return '${thursday.year}-W${week.toString().padLeft(2,'0')}';
  }

  Future<void> _exportCSV(List<Map<String, dynamic>> rows, String filename) async {
    final buffer = StringBuffer();
    if (rows.isEmpty) return;
    final headers = rows.first.keys.toList();
    buffer.writeln(headers.join(','));
    for (final r in rows) {
      buffer.writeln(headers.map((k) => r[k]).join(','));
    }
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename.csv');
    await file.writeAsString(buffer.toString(), encoding: utf8);
    await Share.shareXFiles([XFile(file.path)], text: filename);
  }

  Future<void> _exportPDF(List<Map<String, dynamic>> rows, String filename, BuildContext context) async {
    final pdf = pw.Document();
    final headers = rows.isNotEmpty ? rows.first.keys.toList() : <String>[];
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context ctx) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Report: $filename', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 12),
            pw.Table.fromTextArray(headers: headers, data: rows.map((r)=>headers.map((h)=>r[h]).toList()).toList()),
          ],
        );
      },
    ));
    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename.pdf');
    await file.writeAsBytes(bytes, flush: true);
    await Share.shareXFiles([XFile(file.path)], text: filename);
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.currentUser?.uid;
    if (uid == null) return const Center(child: CircularProgressIndicator());

    final l10n = AppLocalizations.of(context);
    final studentsRef = FirebaseFirestore.instance.collection('teachers').doc(uid).collection('students');
    final week = _weekKey(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text('👩‍🏫 ${l10n?.teacherDashboard ?? 'Teacher Dashboard'}'),
        bottom: TabBar(
          controller: _tab,
          tabs: [
            Tab(text: l10n?.studentsTab ?? 'Students'),
            Tab(text: l10n?.assignmentsTab ?? 'Assignments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          // Students tab with weekly export
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: studentsRef.snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final students = snap.data!.docs;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final rows = <Map<String, dynamic>>[];
                            for (final s in students) {
                              final data = s.data();
                              final suid = data['uid'];
                              final name = (data['nickname'] ?? suid.toString().substring(0,6)).toString();
                              final doc = await FirebaseFirestore.instance
                                .collection('users').doc(suid)
                                .collection('aggregates').doc('weekly')
                                .collection('items').doc(week).get();
                              final totalSec = (doc.data()?['totalSec'] ?? 0).toDouble();
                              final map = (doc.data()?['byInstrument'] ?? {}) as Map<String, dynamic>;
                              final pi = ((map['piano'] ?? 0).toDouble()/60).toStringAsFixed(1);
                              final vi = ((map['violin'] ?? 0).toDouble()/60).toStringAsFixed(1);
                              final fl = ((map['flute'] ?? 0).toDouble()/60).toStringAsFixed(1);
                              final gu = ((map['guitar'] ?? 0).toDouble()/60).toStringAsFixed(1);
                              final dr = ((map['drums'] ?? 0).toDouble()/60).toStringAsFixed(1);
                              rows.add({'name': name, 'uid': suid, 'week': week, 'minutes': (totalSec/60).toStringAsFixed(1), 'piano': pi, 'violin': vi, 'flute': fl, 'guitar': gu, 'drums': dr});
                            }
                            final filename = 'weekly_report_${week}';
                            await _exportCSV(rows, filename);
                          },
                          icon: const Icon(Icons.table_view),
                          label: Text(l10n?.exportCSV ?? 'Export CSV'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final rows = <Map<String, dynamic>>[];
                            for (final s in students) {
                              final data = s.data();
                              final suid = data['uid'];
                              final name = (data['nickname'] ?? suid.toString().substring(0,6)).toString();
                              final doc = await FirebaseFirestore.instance
                                .collection('users').doc(suid)
                                .collection('aggregates').doc('weekly')
                                .collection('items').doc(week).get();
                              final totalSec = (doc.data()?['totalSec'] ?? 0).toDouble();
                              final map = (doc.data()?['byInstrument'] ?? {}) as Map<String, dynamic>;
                              final pi = ((map['piano'] ?? 0).toDouble()/60).toStringAsFixed(1);
                              final vi = ((map['violin'] ?? 0).toDouble()/60).toStringAsFixed(1);
                              final fl = ((map['flute'] ?? 0).toDouble()/60).toStringAsFixed(1);
                              final gu = ((map['guitar'] ?? 0).toDouble()/60).toStringAsFixed(1);
                              final dr = ((map['drums'] ?? 0).toDouble()/60).toStringAsFixed(1);
                              rows.add({'name': name, 'uid': suid, 'week': week, 'minutes': (totalSec/60).toStringAsFixed(1), 'piano': pi, 'violin': vi, 'flute': fl, 'guitar': gu, 'drums': dr});
                            }
                            final filename = 'weekly_report_${week}';
                            await _exportPDF(rows, filename, context);
                          },
                          icon: const Icon(Icons.picture_as_pdf),
                          label: Text(l10n?.exportPDF ?? 'Export PDF'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, i) {
                        final s = students[i];
                        final data = s.data();
                        final suid = data['uid'];
                        final name = (data['nickname'] ?? suid.toString().substring(0,6)).toString();
                        final weeklyAgg = FirebaseFirestore.instance
                          .collection('users').doc(suid)
                          .collection('aggregates').doc('weekly')
                          .collection('items').doc(week);
                        return Card(
                          child: ListTile(
                            title: Text(name),
                            subtitle: StreamBuilder(
                              stream: weeklyAgg.snapshots(),
                              builder: (context, snapAgg) {
                                if (!snapAgg.hasData || !(snapAgg.data as DocumentSnapshot).exists) {
                                  return Text('${l10n?.weeklyReport ?? 'Weekly Report'}: 0 ${l10n?.minutes ?? 'min'}');
                                }
                                final data = (snapAgg.data as DocumentSnapshot).data() as Map<String, dynamic>;
                                final mins = ((data['totalSec'] ?? 0).toDouble() / 60).toStringAsFixed(1);
                                return Text('${l10n?.weeklyReport ?? 'Weekly Report'}: $mins ${l10n?.minutes ?? 'min'}');
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          // Assignments tab
          _AssignmentsTab(teacherUid: uid),
        ],
      ),
    );
  }
}

class _AssignmentsTab extends StatefulWidget {
  final String teacherUid;
  const _AssignmentsTab({required this.teacherUid});
  @override
  State<_AssignmentsTab> createState() => _AssignmentsTabState();
}

class _AssignmentsTabState extends State<_AssignmentsTab> {
  final Set<String> _selected = {};
  final _titleCtrl = TextEditingController();
  DateTime _due = DateTime.now().add(const Duration(days: 7));

  Future<void> _create() async {
    final ref = FirebaseFirestore.instance.collection('teachers').doc(widget.teacherUid).collection('assignments').doc();
    await ref.set({
      'title': _titleCtrl.text.trim().isEmpty ? 'Practice' : _titleCtrl.text.trim(),
      'due': _due.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    // assign to selected students
    for (final uid in _selected) {
      await ref.collection('assignees').doc(uid).set({'uid': uid, 'status': 'pending'});
    }
    if (mounted) {
      _titleCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Created')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final listRef = FirebaseFirestore.instance.collection('teachers').doc(widget.teacherUid).collection('assignments').orderBy('createdAt', descending: true);
    final studentsRef = FirebaseFirestore.instance.collection('teachers').doc(widget.teacherUid).collection('students');
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [

StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
  stream: studentsRef.snapshots(),
  builder: (context, snap) {
    if (!snap.hasData) return const SizedBox();
    final docs = snap.data!.docs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)?.selectStudents ?? 'Select Students'),
        Wrap(
          spacing: 8,
          children: docs.map((d){
            final uid = d.data()['uid']; final name = d.data()['nickname'] ?? uid.substring(0,6);
            final on = _selected.contains(uid);
            return FilterChip(label: Text(name), selected: on, onSelected: (v){ setState((){ if(v) _selected.add(uid); else _selected.remove(uid); }); });
          }).toList(),
        ),
      ],
    );
  },
),
const SizedBox(height: 8),
              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(labelText: l10n?.title ?? 'Title'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('${l10n?.dueDate ?? 'Due Date'}: ${_due.toLocal().toString().split(' ').first}'),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _due,
                        firstDate: DateTime.now().subtract(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => _due = picked);
                    },
                    child: Text(l10n?.selectFile ?? 'Select'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _create,
                child: Text(l10n?.create ?? 'Create'),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: listRef.snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snap.data!.docs;
              if (docs.isEmpty) return Center(child: Text(AppLocalizations.of(context)?.noEntries ?? 'No entries yet'));
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final aid = docs[i].id;
                  final d = docs[i].data();
                  return ListTile(
                    leading: const Icon(Icons.assignment_outlined),
                    title: Text(d['title'] ?? ''),
                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${l10n?.dueDate ?? 'Due Date'}: ${(d['due'] ?? '').toString().split('T').first}'),
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance.collection('teachers').doc(widget.teacherUid).collection('assignments').doc(aid).collection('assignees').snapshots(),
                        builder: (context, s2){
                          if (!s2.hasData) return const SizedBox();
                          final total = s2.data!.docs.length;
                          final done = s2.data!.docs.where((e)=> (e.data()['status'] ?? '') == 'done').length;
                          return Text('${AppLocalizations.of(context)?.status ?? 'Status'}: $done / $total');
                        },
                      ),
                    ]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
