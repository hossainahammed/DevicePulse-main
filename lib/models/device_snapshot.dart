class DeviceSnapshot {
  final int batteryLevel;
  final double batteryTemp;
  final String batteryHealth;
  final String deviceName;
  final String androidVersion;
  final String wifiSSID;
  final DateTime timestamp;

  DeviceSnapshot({
    required this.batteryLevel,
    required this.batteryTemp,
    required this.batteryHealth,
    required this.deviceName,
    required this.androidVersion,
    required this.wifiSSID,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'batteryLevel': batteryLevel,
      'batteryTemp': batteryTemp,
      'batteryHealth': batteryHealth,
      'deviceName': deviceName,
      'androidVersion': androidVersion,
      'wifiSSID': wifiSSID,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  static DeviceSnapshot fromJson(Map<String, dynamic> json) {
    return DeviceSnapshot(
      batteryLevel: json['batteryLevel'] as int,
      batteryTemp: (json['batteryTemp'] as num).toDouble(),
      batteryHealth: json['batteryHealth'] as String,
      deviceName: json['deviceName'] as String,
      androidVersion: json['androidVersion'] as String,
      wifiSSID: json['wifiSSID'] as String? ?? 'Unknown',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
