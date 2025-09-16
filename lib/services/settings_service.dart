
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  Future<double> getRmsThDb() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getDouble('rmsThDb') ?? -45.0;
  }

  Future<Map<String, double>> getGaps() async {
    final sp = await SharedPreferences.getInstance();
    return {
      'piano': sp.getDouble('gap_piano') ?? 20.0,
      'violin': sp.getDouble('gap_violin') ?? 12.0,
      'flute': sp.getDouble('gap_flute') ?? 12.0,
      'guitar': sp.getDouble('gap_guitar') ?? 25.0,
      'drums': sp.getDouble('gap_drums') ?? 10.0,
    };
  }

  Future<void> setRmsThDb(double v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setDouble('rmsThDb', v);
  }

  Future<void> setGap(String instrument, double seconds) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setDouble('gap_' + instrument, seconds);
  }
}


Future<Map<String, dynamic>> exportToMap() async {
  final sp = await SharedPreferences.getInstance();
  return {
    'rmsThDb': sp.getDouble('rmsThDb') ?? -45.0,
    'gaps': {
      'piano': sp.getDouble('gap_piano') ?? 20.0,
      'violin': sp.getDouble('gap_violin') ?? 12.0,
      'flute': sp.getDouble('gap_flute') ?? 12.0,
      'guitar': sp.getDouble('gap_guitar') ?? 25.0,
      'drums': sp.getDouble('gap_drums') ?? 10.0,
    },
    'lang': sp.getString('lang') ?? 'zh-TW',
    'notify': sp.getBool('notify') ?? true,
  };
}

Future<void> importFromMap(Map<String, dynamic> m) async {
  final sp = await SharedPreferences.getInstance();
  if (m.containsKey('rmsThDb')) await sp.setDouble('rmsThDb', (m['rmsThDb'] as num).toDouble());
  if (m.containsKey('gaps')) {
    final g = Map<String, dynamic>.from(m['gaps'] as Map);
    for (final e in g.entries) {
      await sp.setDouble('gap_' + e.key, (e.value as num).toDouble());
    }
  }
  if (m.containsKey('lang')) await sp.setString('lang', m['lang']);
  if (m.containsKey('notify')) await sp.setBool('notify', m['notify'] == true);
}

Future<void> resetDefaults() async {
  final sp = await SharedPreferences.getInstance();
  await sp.setDouble('rmsThDb', -45.0);
  await sp.setDouble('gap_piano', 20.0);
  await sp.setDouble('gap_violin', 12.0);
  await sp.setDouble('gap_flute', 12.0);
  await sp.setDouble('gap_guitar', 25.0);
  await sp.setDouble('gap_drums', 10.0);
}
