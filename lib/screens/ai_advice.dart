
import 'package:flutter/material.dart';
import '../services/iap_service.dart';
import 'paywall.dart';

class AiAdviceScreen extends StatelessWidget {
  const AiAdviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final iap = IapService.instance;
    final premium = iap.isPremium;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI Practice Advice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_open_rounded),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaywallScreen())),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Today\'s Plan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('• Scales: 15 min'),
          const Text('• Slow practice: 10 min'),
          const Text('• Focused passage: 5 min'),
          const Divider(),
          if (!premium) ...[
            const Text('🔒 Premium 可解鎖：'),
            const Text('• 問題分析（音準/節奏誤差）'),
            const Text('• 時間分配圖表'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaywallScreen())),
              child: const Text('升級解鎖'),
            ),
          ] else ...[
            const Text('✅ 已解鎖完整分析範例：'),
            const SizedBox(height: 8),
            const Text('Pitch偏差：高音區平均 +12c'),
            const Text('節奏誤差：平均落後 0.18s，建議 70 BPM 慢練'),
            const SizedBox(height: 8),
            const Text('時間分配：音階 50% / 曲子 33% / 段落 17%'),
          ]
        ],
      ),
    );
  }
}
