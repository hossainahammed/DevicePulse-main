import 'package:flutter/material.dart';
import 'services/native_service.dart';
import 'services/udp_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? data;

  Future<void> load() async {
    final d = await NativeService.getDeviceData();
    if (d is Map<String, dynamic>) {
      data = d;
      data!['timestamp'] = DateTime.now().toIso8601String();
    } else {
      data = {'error': 'Invalid data'};
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final theme = Theme.of(context);
    final batteryLevel = data!['batteryLevel'] ?? 0;
    final batteryTemp = data!['batteryTemp'] ?? 0.0;
    final batteryHealth = data!['batteryHealth'] ?? 'Unknown';
    final deviceName = data!['deviceName'] ?? 'Unknown Device';
    final androidVersion = data!['androidVersion'] ?? 'Stable';
    final wifiSSID = data!['wifiSSID'] ?? 'Not Connected';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Device Status',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildBatteryCard(theme, batteryLevel, batteryTemp),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  theme,
                  Icons.health_and_safety,
                  'Health',
                  batteryHealth,
                  Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  theme,
                  Icons.android,
                  'Android',
                  androidVersion,
                  Colors.blueAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDeviceNameCard(theme, deviceName),
          const SizedBox(height: 16),
          _buildNetworkCard(theme, wifiSSID),
          const SizedBox(height: 32),
          Center(
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (data != null &&
                      data is Map<String, dynamic> &&
                      !data!.containsKey('error')) {
                    await UDPService.broadcast(data!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: theme.colorScheme.secondary,
                        content: const Text(
                          'Pulse shared with the network!',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cannot share: Invalid data'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.bolt, color: Colors.white),
                label: const Text(
                  'Share My Pulse',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryCard(ThemeData theme, int level, double temp) {
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = level > 20
        ? (isDark ? const Color(0xFF1B3124) : const Color(0xFFE8F5E9))
        : (isDark ? const Color(0xFF311B1B) : const Color(0xFFFFEBEE));

    return Card(
      color: cardBg,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Battery Level', style: theme.textTheme.titleMedium),
                    Text(
                      '$level%',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: level / 100,
                      strokeWidth: 8,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      color: level > 20
                          ? theme.colorScheme.primary
                          : Colors.red,
                    ),
                    Icon(
                      Icons.battery_full,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              children: [
                const Icon(
                  Icons.thermostat,
                  size: 20,
                  color: Colors.orangeAccent,
                ),
                const SizedBox(width: 8),
                Text('Temperature: $temp°C', style: theme.textTheme.bodyLarge),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    ThemeData theme,
    IconData icon,
    String title,
    String value,
    Color tintColor,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark
        ? tintColor.withOpacity(0.15)
        : tintColor.withOpacity(0.1);

    return Card(
      color: cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: tintColor, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceNameCard(ThemeData theme, String name) {
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1B1B31) : const Color(0xFFE8EAF6);

    return Card(
      color: cardBg,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.smartphone, color: theme.colorScheme.primary),
        ),
        title: Text(
          'Device Model',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontSize: 12,
          ),
        ),
        subtitle: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildNetworkCard(ThemeData theme, String ssid) {
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF31281B) : const Color(0xFFFFF3E0);

    return Card(
      color: cardBg,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orangeAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.wifi, color: Colors.orangeAccent),
        ),
        title: Text(
          'Connected Wi-Fi',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontSize: 12,
          ),
        ),
        subtitle: Text(
          ssid,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
