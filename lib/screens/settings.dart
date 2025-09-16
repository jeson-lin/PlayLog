
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/iap_service.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import dart:convert;
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'paywall.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../services/locale_provider.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _schoolCtrl = TextEditingController();
  final _classCtrl = TextEditingController();
  Widget _gapRow(BuildContext context, String inst) {
    String label;
    switch (inst) {
      case 'piano': label = AppLocalizations.of(context)?.piano ?? 'Piano'; break;
      case 'violin': label = AppLocalizations.of(context)?.violin ?? 'Violin'; break;
      case 'flute': label = AppLocalizations.of(context)?.flute ?? 'Flute'; break;
      case 'guitar': label = AppLocalizations.of(context)?.guitar ?? 'Guitar'; break;
      case 'drums': label = AppLocalizations.of(context)?.drums ?? 'Drums'; break;
      default: label = inst;
    }
    return Row(
      children: [
        Expanded(child: Text(label)),
        SizedBox(
          width: 180,
          child: Row(children: [
            Expanded(
              child: Slider(
                value: _gaps[inst] ?? 20.0,
                min: 5,
                max: 40,
                divisions: 35,
                label: (_gaps[inst] ?? 20.0).toStringAsFixed(0) + 's',
                onChanged: (v) => setState(() => _gaps[inst] = v),
              ),
            ),
            SizedBox(width: 8),
            Text('${(_gaps[inst] ?? 20.0).toStringAsFixed(0)}s'),
          ]),
        ),
      ],
    );
  }

  double _rmsTh = -45.0;
  final Map<String, double> _gaps = {
    'piano': 20.0, 'violin': 12.0, 'flute': 12.0, 'guitar': 25.0, 'drums': 10.0,
  };
  String _country = 'TW';
  final _nickCtrl = TextEditingController();
  String _lang = 'zh-TW';
  bool _notify = true;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadPrefsAndProfile();
  }

  Future<void> _loadPrefsAndProfile() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _lang = sp.getString('lang') ?? 'zh-TW';
      _notify = sp.getBool('notify') ?? true;
    });
    try {
      final profile = await FirestoreService.instance.fetchUserProfile();
      if (profile != null && profile['countryCode'] is String) {
        _country = profile['countryCode'];
      }
      if (profile != null && profile['nickname'] is String) {
        if (profile['school'] is String) _schoolCtrl.text = profile['school'];
        if (profile['classId'] is String) _classCtrl.text = profile['classId'];
        _nickCtrl.text = profile['nickname'];
      }
    } catch (_) {}
    final rms = await SettingsService.instance.getRmsThDb();
    final gaps = await SettingsService.instance.getGaps();
    setState(() {
      _rmsTh = rms;
      _gaps.addAll(gaps);
      _loadingProfile = false;
    });
  }

  Future<void> _saveProfile() async {
    await FirestoreService.instance.upsertUserProfile(
      nickname: _nickCtrl.text.trim().isEmpty ? 'Player' : _nickCtrl.text.trim(),
      languageCode: _lang,
      countryCode: _country,
      school: _schoolCtrl.text.trim(),
      classId: _classCtrl.text.trim(),
    );
    final sp = await SharedPreferences.getInstance();
    await sp.setString('lang', _lang);
    await sp.setBool('notify', _notify);
    await SettingsService.instance.setRmsThDb(_rmsTh);
    for (final e in _gaps.entries) { await SettingsService.instance.setGap(e.key, e.value); }
    if (mounted) {
      // apply locale instantly
      await context.read<LocaleProvider>().setLocale(_lang);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved ✅')));
    }
  }

  @override
  void dispose() {
    _nickCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: Text('⚙️ ' + (AppLocalizations.of(context)?.settingsTitle ?? 'Settings'))),
      body: _loadingProfile ? const Center(child: CircularProgressIndicator()) : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(AppLocalizations.of(context)?.signinStatus ?? 'Sign-in status'),
            subtitle: Text(user == null
                ? '未登入'
                : 'UID: ${user.uid.substring(0,6)}...  (${user.isAnonymous ? '匿名' : (user.email ?? '已登入')})'),
          ),
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  try { await AuthService.instance.signInWithGoogle(); setState((){}); }
                  catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google 登入失敗: $e'))); }
                },
                icon: const Icon(Icons.login),
                label: Text(AppLocalizations.of(context)?.signInGoogle ?? 'Sign in with Google'),
              ),
              if (Platform.isIOS) ElevatedButton.icon(
                onPressed: () async {
                  try { await AuthService.instance.signInWithApple(); setState((){}); }
                  catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Apple 登入失敗: $e'))); }
                },
                icon: const Icon(Icons.apple),
                label: Text(AppLocalizations.of(context)?.signInApple ?? 'Sign in with Apple'),
              ),
              OutlinedButton.icon(
                onPressed: () async { await AuthService.instance.signOut(); setState((){}); },
                icon: const Icon(Icons.logout),
                label: Text(AppLocalizations.of(context)?.signOut ?? 'Sign out'),
              ),
            ],
          ),
          const Divider(),
          TextField(
            controller: _nickCtrl,
            decoration: InputDecoration(labelText: AppLocalizations.of(context)?.nickname ?? 'Nickname'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text((AppLocalizations.of(context)?.language ?? 'Language') + '：'),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _lang,
                items: const [
                  DropdownMenuItem(value: 'zh-TW', child: Text('繁中')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ja', child: Text('日本語')),
                ],
                onChanged: (v) => setState(() => _lang = v ?? 'zh-TW'),
              ),
            ],
          ),
          Row(
            children: [
              Text((AppLocalizations.of(context)?.country ?? 'Country') + '：'),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _country,
                items: const [
                  DropdownMenuItem(value: 'TW', child: Text('台灣')),
                  DropdownMenuItem(value: 'JP', child: Text('日本')),
                  DropdownMenuItem(value: 'US', child: Text('美國')),
                  DropdownMenuItem(value: 'CN', child: Text('中國')),
                  DropdownMenuItem(value: 'IN', child: Text('印度')),
                  DropdownMenuItem(value: 'BR', child: Text('巴西')),
                ],
                onChanged: (v) => setState(() => _country = v ?? 'TW'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          ListTile(title: Text('🎚 ' + (AppLocalizations.of(context)?.thresholds ?? 'Thresholds'))),
          Row(
            children: [
              Expanded(child: Text(AppLocalizations.of(context)?.rmsThreshold ?? 'RMS Threshold (dBFS)')),
              SizedBox(
                width: 120,
                child: Slider(
                  value: _rmsTh,
                  min: -70,
                  max: -20,
                  divisions: 50,
                  label: _rmsTh.toStringAsFixed(0),
                  onChanged: (v) => setState(() => _rmsTh = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(children: [
            _gapRow(context, 'piano'),
            _gapRow(context, 'violin'),
            _gapRow(context, 'flute'),
            _gapRow(context, 'guitar'),
            _gapRow(context, 'drums'),
          ]),
          const Divider(),
          SwitchListTile(
            value: _notify,
            onChanged: (v) => setState(() => _notify = v),
            title: const Text('練習提醒通知'),
            subtitle: const Text('（MVP 佔位，之後接推播/排程）'),
          ),
          const Divider(),
          ListTile(
            title: Text(AppLocalizations.of(context)?.purchase ?? 'Purchases'),
            subtitle: const Text('去廣告、Premium 訂閱'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaywallScreen())),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)?.restorePurchases ?? 'Restore Purchases'),
            onTap: () async {
              try {
                await IapService.instance.restore();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已送出恢復購買請求，請稍候…')));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('恢復購買失敗：$e')));
                }
              }
            },
          ),
          const Divider(),
          ListTile(
            title: Text(AppLocalizations.of(context)?.privacy ?? 'Privacy Policy'),
            subtitle: const Text('（放置你的連結）'),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)?.tos ?? 'Terms of Service'),
          ),
          const Divider(),
          Row(
            children: [
              Expanded(child: OutlinedButton(
                onPressed: () async {
                  final map = await SettingsService.instance.exportToMap();
                  final jsonStr = jsonEncode(map);
                  await Share.share(jsonStr, subject: 'Practice App Settings');
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)?.exportDone ?? 'Settings exported')));
                },
                child: Text(AppLocalizations.of(context)?.exportSettings ?? 'Export Settings'),
              )),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton(
                onPressed: () async {
                  final res = await FilePicker.platform.pickFiles(type: FileType.any);
                  if (res != null && res.files.isNotEmpty && res.files.single.bytes != null) {
                    final txt = String.fromCharCodes(res.files.single.bytes!);
                    try {
                      final m = jsonDecode(txt) as Map<String, dynamic>;
                      await SettingsService.instance.importFromMap(m);
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)?.importDone ?? 'Settings imported')));
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context)?.error ?? 'Error'}: $e')));
                    }
                  }
                },
                child: Text(AppLocalizations.of(context)?.importSettings ?? 'Import Settings'),
              )),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () async {
              await SettingsService.instance.resetDefaults();
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)?.resetDone ?? 'Settings reset')));
            },
            child: Text(AppLocalizations.of(context)?.resetDefaults ?? 'Reset to Defaults'),
          ),
          const SizedBox(height: 12),
          
            subtitle: const Text('（放置你的連結）'),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _saveProfile, child: Text(AppLocalizations.of(context)?.saveSettings ?? 'Save Settings')),
        ],
      ),
    );
  }
}
