
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final _db = FirebaseFirestore.instance;

  Future<void> addPracticeSession({
    required DateTime start,
    required DateTime end,
    required String instrument,
    required double durationSec,
    double activeRatio = 1.0,
  }) async {
    final uid = AuthService.instance.currentUser?.uid;
    if (uid == null) throw Exception('No user signed in');

    final doc = _db.collection('users').doc(uid).collection('sessions').doc();
    await doc.set({
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'instrument': instrument,
      'durationSec': durationSec,
      'activeRatio': activeRatio,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> upsertUserProfile({
    required String nickname,
    String? countryCode,
    String? languageCode,
    String? school,
    String? classId,
  }) async {
    final uid = AuthService.instance.currentUser?.uid;
    if (uid == null) throw Exception('No user signed in');
    final ref = _db.collection('users').doc(uid);
    await ref.set({
      'nickname': nickname,
      'countryCode': countryCode,
      'languageCode': languageCode,
      'school': school,
      'classId': classId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    final uid = AuthService.instance.currentUser?.uid;
    if (uid == null) throw Exception('No user signed in');
    final snap = await _db.collection('users').doc(uid).get();
    return snap.data();
  }
}
