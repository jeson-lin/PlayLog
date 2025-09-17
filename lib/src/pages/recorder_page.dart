import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:share_plus/share_plus.dart';

class RecorderPage extends StatefulWidget {
  const RecorderPage({super.key});
  @override
  State<RecorderPage> createState() => _RecorderPageState();
}

class _RecorderPageState extends State<RecorderPage> {
  final _rec = AudioRecorder();
  bool _recording = false;
  String? _lastPath;

  Future<String> _defaultFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().toIso8601String().replaceAll(':', '-');
    final path = '${dir.path}/recording_$ts.m4a';
    return path;
  }

  Future<void> _toggle() async {
    if (_recording) {
      final path = await _rec.stop();
      setState(() {
        _recording = false;
        _lastPath = path;
      });
    } else {
      final ok = await _rec.hasPermission();
      if (!ok) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('沒有麥克風權限')));
        }
        return;
      }
      final path = await _defaultFilePath();
      await _rec.start(const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100), path: path);
      setState(() {
        _recording = true;
        _lastPath = null;
      });
    }
  }

  @override
  void dispose() {
    _rec.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('錄音（本機保存）')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: _toggle,
              icon: Icon(_recording ? Icons.stop : Icons.mic),
              label: Text(_recording ? '停止錄音' : '開始錄音'),
            ),
            const SizedBox(height: 12),
            if (_lastPath != null) ...[
              const Text('已儲存：'),
              SelectableText(_lastPath!),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => Share.shareXFiles([XFile(_lastPath!)], text: '我的練習錄音'),
                icon: const Icon(Icons.ios_share),
                label: const Text('分享檔案'),
              ),
            ] else
              const Text('錄音檔將儲存在本機（App 文件目錄）'),
          ],
        ),
      ),
    );
  }
}
