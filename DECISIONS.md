Key Technical Decisions
1. Framework and Platform Choice: Flutter with Android Native Integration
Decision: Used Flutter for cross-platform development, but relied heavily on Android-specific native code (via MethodChannel) to access device data like battery level, temperature, and model info.
Rationale: Flutter provides a unified UI and logic layer, enabling rapid prototyping. However, device-specific data (e.g., battery health) isn't directly accessible via Flutter plugins, so native Android code (Kotlin/Java) was necessary for reliability and accuracy.
Limitations:
Platform Constraints: The app is Android-only due to the native MethodChannel implementation. iOS support would require rewriting the native layer (e.g., using Swift/Objective-C), which wasn't prioritized for this prototype.
Data Access Constraints: Android permissions (e.g., BATTERY_STATS) are required for detailed battery data. On some devices/ROMs (like your Realme RMX3195), access might be restricted or require root, leading to incomplete data (e.g., only basic model/SDK info was fetched in testing).
Performance: Native calls add overhead; heavy polling could drain battery, so data is fetched on-demand.
2. Networking: UDP Broadcasting for Peer-to-Peer Sharing
Decision: Implemented UDP (User Datagram Protocol) for broadcasting device snapshots to all devices on the same Wi-Fi network.
Rationale: UDP is lightweight and ideal for P2P discovery/sharing without a central server. It allows simple, fire-and-forget broadcasts (e.g., to 255.255.255.255 on port 4040), enabling real-time "pulse" sharing. No need for complex TCP handshakes or server infrastructure.
Limitations:
Network Constraints: Requires same Wi-Fi network; doesn't work over cellular, VPNs, or public Wi-Fi (due to firewalls/port blocking). Port 4040 could be blocked by routers/firewalls, causing silent failures.
Reliability: UDP is connectionless and unreliable—packets can be lost, duplicated, or arrive out-of-order. No built-in retries or acknowledgments, so broadcasts might not reach all peers.
Security: No encryption or authentication; data is sent in plain JSON, making it vulnerable to eavesdropping on the network. Not suitable for sensitive data.
Scalability: Inefficient for large networks (e.g., broadcasts flood all devices); tested only on small-scale (2 devices).
3. Storage: Hive for Local Data Persistence
Decision: Used Hive (a lightweight, NoSQL key-value database) to store received device snapshots locally as a generic Map box.
Rationale: Hive is fast, easy to integrate with Flutter, and doesn't require a server—perfect for offline, local storage. It supports reactive updates (via ValueListenableBuilder), allowing the UI to refresh automatically when new data arrives. Chose a Map box over typed boxes to handle dynamic data structures flexibly (e.g., storing JSON-like Maps from broadcasts).
Justification:
Alternatives Considered: SharedPreferences (too basic, no reactivity); SQLite (overkill for simple key-value needs, more complex setup); Firebase (requires internet/server, against P2P design).
Pros: Low overhead, works offline, easy querying/deletion. Fits the app's need for storing transient "received pulses" without persistence across app restarts (data is ephemeral).
Limitations: Not optimized for large datasets (e.g., thousands of snapshots could slow performance). No built-in encryption; data is stored unencrypted on-device. Typed boxes were avoided to prevent type mismatches, but this reduces type safety.
4. Data Model and Serialization
Decision: Defined a DeviceSnapshot class with fields like battery level, temperature, and timestamp, serialized to/from JSON.
Rationale: Provides structure for device data, enabling consistent broadcasting/storage. JSON is simple for UDP transmission.
Limitations: Assumes all devices send complete snapshots; partial data (e.g., missing battery fields) causes silent failures in parsing. No versioning for schema changes.
5. UI and Architecture: Tab-Based Layout with Services
Decision: Simple tabbed interface (Dashboard for live data, Received for history) with separate service classes (UDPService, NativeService).
Rationale: Clean separation of concerns; services handle business logic, UI focuses on display.
Limitations: No advanced features like user authentication, data filtering, or export. UI skips frames on heavy loads (e.g., data fetching), indicating potential optimization needs.
Overall Trade-Offs
Prototype Focus: Decisions prioritized simplicity and speed (e.g., UDP over TCP, Hive over SQLite) for a proof-of-concept. Production would require security (encryption), reliability (TCP/WebSockets), and cross-platform support.
Testing Constraints: Limited to Android; full P2P testing requires multiple devices on the same network.
