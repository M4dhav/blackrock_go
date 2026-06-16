import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';

/// Detects whether the device is on the camp's local WiFi network
/// by looking for the APN coordinator at camp.local:8000.
///
/// When on camp WiFi:  Pythia queries go via fast HTTP path (~10s)
/// When on playa:      Pythia queries go via LoRa mesh path (~45s)
class CampNetworkService extends GetxService {
  final RxBool onCampWifi = false.obs;
  final Rx<String?> campHost = Rx<String?>(null);

  static const _checkInterval = Duration(seconds: 30);
  static const _connectTimeout = Duration(seconds: 3);

  Timer? _timer;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _probe();
    _timer = Timer.periodic(_checkInterval, (_) => _probe());
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  bool get isOnCampWifi => onCampWifi.value;

  Future<void> _probe() async {
    // Try known camp host names in order
    for (final host in ['camp.local', 'apn.local', '192.168.1.77']) {
      if (await _reachable(host)) {
        campHost.value = host;
        onCampWifi.value = true;
        return;
      }
    }
    campHost.value = null;
    onCampWifi.value = false;
  }

  Future<bool> _reachable(String host) async {
    try {
      final socket = await Socket.connect(
        host,
        8000,
        timeout: _connectTimeout,
      );
      await socket.close();
      return true;
    } catch (_) {
      return false;
    }
  }
}
