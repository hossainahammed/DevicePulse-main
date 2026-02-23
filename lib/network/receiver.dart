import 'dart:convert';
import 'dart:io';
import 'package:devicepulse/models/device_snapshot.dart';
import 'package:hive/hive.dart';

class SnapshotReceiver {
  static const int port = 45678;

  Future<void> start() async {
    final socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      port,
      reusePort: true,
    );

    socket.listen((event) async {
      if (event == RawSocketEvent.read) {
        final dg = socket.receive();
        if (dg == null) return;

        final data = jsonDecode(utf8.decode(dg.data));

        if (data.containsKey('battery')) {
          final snapshot = DeviceSnapshot.fromJson(data);
          final box = Hive.box<DeviceSnapshot>('snapshots');
          await box.add(snapshot);
        }
      }
    });
  }
}
