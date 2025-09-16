
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class StatsService {
  StatsService._();
  static final StatsService instance = StatsService._();
  final _db = FirebaseFirestore.instance;

  String _dayKey(DateTime t) => t.toIso8601String().substring(0,10); // YYYY-MM-DD
  String _monthKey(DateTime t) => '${t.year}-${t.month.toString().padLeft(2,'0')}';
  String _weekKey(DateTime t) {
    // ISO week rough calc: year-Www
    final thursday = t.add(Duration(days: 3 - ((t.weekday + 6) % 7)));
    final firstThu = DateTime(thursday.year, 1, 4);
    final week = 1 + ((thursday.difference(firstThu).inDays) / 7).floor();
    return '${thursday.year}-W${week.toString().padLeft(2,'0')}';
  }

  Future<void> updateAggregatesAndLeaderboards({
    required DateTime start,
    required DateTime end,
    required String instrument,
    required double durationSec,
    double? activeRatio,
  }) async {
    final uid = AuthService.instance.currentUser?.uid;
    if (uid == null) throw Exception('No user signed in');

    final day = _dayKey(start);
    final week = _weekKey(start);
    final month = _monthKey(start);

    final userRef = _db.collection('users').doc(uid);

final userDoc = await _db.collection('users').doc(uid).get();
final nick = (userDoc.data() ?? {})['nickname'];
final country = (userDoc.data() ?? {})['countryCode'];


    final Map<String, dynamic> inc = {
      'totalSec': FieldValue.increment(durationSec),
      'byInstrument.${instrument}': FieldValue.increment(durationSec),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final batch = _db.batch();
    // User aggregates
    batch.set(userRef.collection('aggregates').doc('daily').collection('items').doc(day), inc, SetOptions(merge: true));
    batch.set(userRef.collection('aggregates').doc('weekly').collection('items').doc(week), inc, SetOptions(merge: true));
    batch.set(userRef.collection('aggregates').doc('monthly').collection('items').doc(month), inc, SetOptions(merge: true));

    // Public leaderboards
    final lbBase = _db.collection('leaderboards');
    batch.set(lbBase.doc('daily').collection('items').doc(day).collection('users').doc(uid), {
      'uid': uid,
      'nickname': nick,
      'countryCode': country,
      'school': school,
      'classId': classId,
      'totalSec': FieldValue.increment(durationSec),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    batch.set(lbBase.doc('weekly').collection('items').doc(week).collection('users').doc(uid), {
      'uid': uid,
      'nickname': nick,
      'countryCode': country,
      'school': school,
      'classId': classId,
      'totalSec': FieldValue.increment(durationSec),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    batch.set(lbBase.doc('monthly').collection('items').doc(month).collection('users').doc(uid), {
      'uid': uid,
      'nickname': nick,
      'countryCode': country,
      'school': school,
      'classId': classId,
      'totalSec': FieldValue.increment(durationSec),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();

    // Post-update: update longestSessionSec and sumActiveRatioSec atomically via transactions
    final double arSec = (activeRatio ?? 1.0) * durationSec;
    for (final entry in [
      userRef.collection('aggregates').doc('daily').collection('items').doc(day),
      userRef.collection('aggregates').doc('weekly').collection('items').doc(week),
      userRef.collection('aggregates').doc('monthly').collection('items').doc(month),
    ]) {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(entry);
        final data = (snap.data() ?? {});
        final prevLongest = (data['longestSessionSec'] ?? 0).toDouble();
        final newLongest = durationSec > prevLongest ? durationSec : prevLongest;
        final prevSumAr = (data['sumActiveRatioSec'] ?? 0).toDouble();
        tx.set(entry, {
          'longestSessionSec': newLongest,
          'sumActiveRatioSec': prevSumAr + arSec,
        }, SetOptions(merge: true));
      });
    }

  }
}
