Design Overview
"DevicePulse" is a Flutter-based Android app for sharing live device "pulses" (e.g., battery status, model) via peer-to-peer UDP broadcasting on the same Wi-Fi network. It consists of:

Dashboard Screen: Displays current device data fetched from native Android code; includes a "Share My Pulse" button to broadcast data.
Received Screen: Lists stored snapshots from other devices, updated reactively via Hive.
Services: UDPService handles networking (listening/broadcasting), NativeService fetches device data via MethodChannel.
Storage: Hive box ('snapshots') stores received data as Maps for easy access.
The app emphasizes simplicity: no server, no login—just launch, share, and view. Rationale: Enable quick device monitoring in shared environments (e.g., family/group Wi-Fi) without complex setup.

Rationale for Choices
P2P Networking: UDP was chosen for its simplicity in local networks, avoiding server costs/maintenance. Broadcasting to all peers (vs. targeted sending) keeps it easy but limits scalability.
Local Storage: Hive ensures data persists locally without internet, aligning with offline-first design. Reactive updates keep the UI fresh without manual refreshes.
Native Integration: Flutter lacks direct access to Android battery APIs, so MethodChannel bridges this gap. Keeps core logic in Dart while offloading platform-specific tasks.
Data Flow: Dashboard fetches data → User broadcasts → Listener receives → Stores in Hive → UI updates. This modular flow isolates concerns (e.g., networking from UI).
Error Handling: Silent ignores (e.g., malformed UDP packets) prevent crashes but could hide issues—added debug prints for troubleshooting.
UI Simplicity: Tab layout mimics standard apps; no animations to avoid performance hits on low-end devices.
Implementation Details
Project Structure:
lib/main.dart: Initializes Hive and UDP listener; runs app.
lib/screens/: Dashboard (fetches/displays data) and Received (lists Hive data).
lib/services/: UDPService (binds to port 4040, listens/broadcasts), NativeService (calls Android via channel).
lib/models/: DeviceSnapshot (data class with JSON serialization).
Key Code Snippets:
Listener: RawDatagramSocket.bind() in UDPService.startListening() runs in background, parsing JSON and storing in Hive.
Broadcast: socket.send() to 255.255.255.255:4040 with JSON-encoded data.
Data Fetch: MethodChannel.invokeMethod('getDeviceData') returns Map; parsed in Dart.
Dependencies: Hive (storage), path_provider (Hive init), flutter/material (UI).
Debugging Notes: Added prints (e.g., "Raw data from NativeService") to trace issues. Common problems: Listener not started (forgot UDPService.startListening() in main), data mismatches (e.g., incomplete DeviceSnapshot fields), network blocks (firewalls on port 4040).
Build/Run: flutter run on Android; requires Wi-Fi for testing. Gradle warnings (e.g., version upgrades) are non-critical.
Future Enhancements: Add encryption (e.g., via AES), TCP for reliability, iOS support, or cloud sync for broader use.