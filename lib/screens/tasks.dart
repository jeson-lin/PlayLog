
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService.instance.currentUser?.uid;
    if (uid == null) return const Center(child: CircularProgressIndicator());

    // Find teachers who assigned tasks to me (simple scan; in production, index this)
    final teachers = FirebaseFirestore.instance.collection('teachers');

    return Scaffold(
      appBar: AppBar(title: Text('📝 ' + (AppLocalizations.of(context)?.tasks ?? 'Tasks'))),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: teachers.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final teacherDocs = snap.data!.docs;
          final List<Widget> items = [];
          for (final t in teacherDocs) {
            final tid = t.id;
            final assignees = FirebaseFirestore.instance
              .collection('teachers').doc(tid).collection('assignments');
            items.add(StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: assignees.snapshots(),
              builder: (context, s2) {
                if (!s2.hasData) return const SizedBox();
                final tasks = s2.data!.docs;
                final List<Widget> my = [];
                for (final a in tasks) {
                  final aid = a.id;
                  final mine = FirebaseFirestore.instance.collection('teachers').doc(tid).collection('assignments').doc(aid).collection('assignees').doc(uid);
                  my.add(StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: mine.snapshots(),
                    builder: (context, s3) {
                      if (!s3.hasData || !s3.data!.exists) return const SizedBox();
                      final data = s3.data!.data()!;
                      final status = (data['status'] ?? 'pending').toString();
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.assignment), const SizedBox(width: 8),
                                  Expanded(child: Text(a.data()['title'] ?? '')),
                                  const SizedBox(width: 8),
                                  status == 'done'
                                    ? const Icon(Icons.check_circle, color: Colors.green)
                                    : ElevatedButton(
                                        onPressed: () async {
                                          await mine.set({'uid': uid, 'status': 'done'}, SetOptions(merge: true));
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)?.completed ?? 'Completed')));
                                          }
                                        },
                                        child: Text(AppLocalizations.of(context)?.markDone ?? 'Mark Done'),
                                      ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('${a.data()['due'] ?? ''} · ${AppLocalizations.of(context)?.status ?? 'Status'}: ${status}'),
                              const SizedBox(height: 8),
                              FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                future: mine.get(),
                                builder: (context, fsnap) {
                                  final init = (fsnap.data?.data() ?? {});
                                  final controller = TextEditingController(text: (init['comment'] ?? '').toString());
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: controller,
                                          decoration: InputDecoration(hintText: AppLocalizations.of(context)?.comment ?? 'Comment'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton(
                                        onPressed: () async {
                                          await mine.set({'uid': uid, 'comment': controller.text}, SetOptions(merge: true));
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)?.save ?? 'Save')));
                                          }
                                        },
                                        child: Text(AppLocalizations.of(context)?.save ?? 'Save'),
                                      )
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ));
                }
                return Column(children: my);
              },
            ));
          }
          return ListView(children: items);
        },
      ),
    );
  }
}
