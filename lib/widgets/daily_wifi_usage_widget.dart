import 'package:flauncher/providers/network_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DailyWifiUsageWidget extends StatelessWidget {
  const DailyWifiUsageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<NetworkService, SettingsService>(
      builder: (context, networkService, settingsService, _) {
        if (!networkService.hasUsageStatsPermission) {
          return TextButton.icon(
             icon: const Icon(Icons.data_usage, size: 20),
             label: const Text("Grant Usage Permission"),
             onPressed: () => networkService.requestPermission(),
          );
        }

        final period = settingsService.wifiUsagePeriod;
        String label;
        switch (period) {
          case 'weekly':
            label = 'Weekly Usage';
            break;
          case 'monthly':
            label = 'Monthly Usage';
            break;
          case 'daily':
          default:
            label = 'Daily Usage';
            break;
        }

        return FutureBuilder<int>(
          future: networkService.getWifiUsageForPeriod(period),
          builder: (context, snapshot) {
            final usage = snapshot.data ?? networkService.dailyWifiUsage;
            final usageString = _formatBytes(usage);

            return Text(
              "$label: $usageString",
              style: Theme.of(context).textTheme.titleMedium,
            );
          },
        );
      },
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = 0;
    double d = bytes.toDouble();
    while (d >= 1024 && i < suffixes.length - 1) {
      d /= 1024;
      i++;
    }
    return "${d.toStringAsFixed(2)} ${suffixes[i]}";
  }
}
