import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:devicepulse/models/device_snapshot.dart';

class UDPService {
  static const int port = 4040;

  static Future<void> startListening() async {
    print('UDP: Starting listener...');
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
    print('UDP: Listener bound to port $port');

    socket.listen((event) {
      if (event == RawSocketEvent.read) {
        final dg = socket.receive();
        if (dg == null) return;

        try {
          final decoded = utf8.decode(dg.data);
          print('UDP: Received data: $decoded');
          final map = jsonDecode(decoded) as Map<String, dynamic>;
          final snapshot = DeviceSnapshot.fromJson(map);

          final box = Hive.box('snapshots');
          box.add(snapshot.toJson());
          print('UDP: Stored snapshot in Hive');
        } catch (e) {
          print('UDP: Error processing data: $e');
        }
      }
    });
  }

  static Future<void> broadcast(Map<String, dynamic> data) async {
    print('UDP: Broadcasting data: $data');
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    socket.broadcastEnabled = true;

    socket.send(
      utf8.encode(jsonEncode(data)),
      InternetAddress('255.255.255.255'),
      port,
    );
    socket.close();
    print('UDP: Broadcast sent');
  }
}

