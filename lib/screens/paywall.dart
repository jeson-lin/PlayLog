
import 'package:flutter/material.dart';
import '../services/iap_service.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  @override
  void initState() {
    super.initState();
    IapService.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    final iap = IapService.instance;
    final removeAds = iap.find(IapService.kProductRemoveAds);
    final monthly = iap.find(IapService.kProductPremiumMonthly);
    final yearly = iap.find(IapService.kProductPremiumYearly);

    return Scaffold(
      appBar: AppBar(title: const Text('✨ 升級解鎖')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('解鎖完整 AI 建議、去除廣告、獲得更多勳章加成', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: const Text('去除廣告（一次性）'),
              subtitle: Text(removeAds?.price ?? '—'),
              trailing: ElevatedButton(
                onPressed: removeAds == null ? null : () async {
                try { await iap.buy(removeAds); }
                catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('購買失敗：$e'))); }
              },
                child: const Text('購買'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              title: const Text('Premium 月訂'),
              subtitle: Text(monthly?.price ?? '—'),
              trailing: ElevatedButton(
                onPressed: monthly == null ? null : () async {
                try { await iap.buy(monthly); }
                catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('訂閱失敗：$e'))); }
              },
                child: const Text('訂閱'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              title: const Text('Premium 年訂'),
              subtitle: Text(yearly?.price ?? '—'),
              trailing: ElevatedButton(
                onPressed: yearly == null ? null : () async {
                try { await iap.buy(yearly); }
                catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('訂閱失敗：$e'))); }
              },
                child: const Text('訂閱'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('目前狀態'),
            subtitle: Text('Premium: ${iap.isPremium} · RemoveAds: ${iap.removeAds}'),
          )
        ],
      ),
    );
  }
}
