// lib/services/brsp_manager.dart
//
// Handles the BlueRadios Serial Port (BRSP) protocol for the old SmartPuck
// device. Exposes the exact same public interface as BleManager so that
// BleController can swap between the two transparently.
//
// BRSP handshake (mirrors Android Brsp.java):
//   Step 1 – enable RTS notifications  (flow control)
//   Step 2 – enable TX indications     (incoming data)
//   Step 3 – read INFO characteristic
//   Step 4 – write MODE = 1 (DATA)    → device is now ready
//
// After that, messages are written to RX (app→device) as UTF-8 + '\r',
// and received from TX (device→app) via indication.

import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BrspManager {
  BrspManager({this.onDisconnected});

  // ── BRSP GATT UUIDs ────────────────────────────────────────────────────────
  static const String BRSP_SERVICE_UUID =
      'DA2B84F1-6279-48DE-BDC0-AFBEA0226079';

  static final Guid _serviceUuid = Guid(BRSP_SERVICE_UUID);
  static final Guid _rxUuid =
      Guid('BF03260C-7205-4C25-AF43-93B1C299D159'); // app → device
  static final Guid _txUuid =
      Guid('18CDA784-4BD3-4370-85BB-BFED91EC86AF'); // device → app
  static final Guid _modeUuid =
      Guid('A87988B9-694C-479C-900E-95DFA6C00A24');
  static final Guid _rtsUuid =
      Guid('FDD6B4D3-046D-4330-BDEC-1FD0C90CB43B');
  static final Guid _infoUuid =
      Guid('99564A02-DC01-4D3C-B04E-3BB1EF0571B2');

  // ── State ──────────────────────────────────────────────────────────────────
  BluetoothDevice? _device;
  BluetoothCharacteristic? _rxChar;
  bool _manualDisconnect = false;
  bool _isConnected = false;

  StreamSubscription? _connectionStateSubscription;
  StreamSubscription? _txSubscription;

  final StreamController<String> _messageController =
      StreamController<String>.broadcast();

  Stream<String> get messageStream => _messageController.stream;
  bool get isConnected => _isConnected;

  final void Function()? onDisconnected;

  // ── Scan helper ────────────────────────────────────────────────────────────

  /// Returns a scan stream filtered to the BRSP service UUID.
  Stream<List<ScanResult>> startScan({
    Duration timeout = const Duration(seconds: 10),
  }) {
    FlutterBluePlus.startScan(
      withServices: [_serviceUuid],
      timeout: timeout,
    );
    return FlutterBluePlus.scanResults;
  }

  void stopScan() => FlutterBluePlus.stopScan();

  // ── Connect ────────────────────────────────────────────────────────────────

  Future<void> connect(BluetoothDevice device) async {
    await device.connect(autoConnect: false, timeout: const Duration(seconds: 15),license: License.free);
    _device = device;

    await _connectionStateSubscription?.cancel();
    _connectionStateSubscription = device.connectionState.listen((state) async {
      if (state == BluetoothConnectionState.disconnected) {
        _isConnected = false;
        _rxChar = null;
        if (!_manualDisconnect) {
          onDisconnected?.call();
        }
      }
    });

    await _initBrsp(device);
  }

  // ── Disconnect ─────────────────────────────────────────────────────────────

  Future<void> disconnect() async {
    _manualDisconnect = true;
    await _txSubscription?.cancel();
    _txSubscription = null;
    await _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
    await _device?.disconnect();
    _manualDisconnect = false;
    _isConnected = false;
    _device = null;
    _rxChar = null;
  }

  /// Clears in-memory connection state without calling disconnect() on the
  /// device. Use when Bluetooth adapter is turned off.
  void clearConnection() {
    _txSubscription?.cancel();
    _txSubscription = null;
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
    _isConnected = false;
    _device = null;
    _rxChar = null;
  }

  // ── Send ───────────────────────────────────────────────────────────────────

  /// Sends [message] to the device, appending '\r' as the SmartPuck expects.
  /// Splits into 20-byte chunks to respect the BLE MTU limit.
  Future<void> sendMessage(String message) async {
    if (_rxChar == null || !_isConnected) {
      throw Exception('BrspManager: not ready — handshake incomplete or disconnected');
    }

    final bytes = utf8.encode('$message\r');
    const chunkSize = 20;

    for (int i = 0; i < bytes.length; i += chunkSize) {
      if (_rxChar == null) throw Exception('Disconnected mid-send');
      final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
      try {
        await _rxChar!.write(bytes.sublist(i, end), withoutResponse: false);
      } catch (e) {
        throw Exception('BrspManager send failed: $e');
      }
    }
  }

  void dispose() {
    _txSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    _messageController.close();
  }

  // ── BRSP 4-step handshake ─────────────────────────────────────────────────

  Future<void> _initBrsp(BluetoothDevice device) async {
    final services = await device.discoverServices();

    BluetoothService? brspService;
    for (final s in services) {
      if (s.serviceUuid == _serviceUuid) {
        brspService = s;
        break;
      }
    }
    if (brspService == null) {
      throw Exception('BrspManager: BRSP service not found on device');
    }

    final chars = brspService.characteristics;
    final rx   = _findChar(chars, _rxUuid);
    final tx   = _findChar(chars, _txUuid);
    final mode = _findChar(chars, _modeUuid);
    final rts  = _findChar(chars, _rtsUuid);
    final info = _findChar(chars, _infoUuid);

    if (rx == null || tx == null || mode == null) {
      throw Exception('BrspManager: required characteristics (RX/TX/MODE) not found');
    }

    // Step 1 – subscribe to RTS notifications (flow control)
    if (rts != null) {
      await rts.setNotifyValue(true);
    }
    // Small delay matching the Android BRSP library workaround
    await Future.delayed(const Duration(milliseconds: 500));

    // Step 2 – subscribe to TX indications (incoming data from device)
    await tx.setNotifyValue(true);
    await _txSubscription?.cancel();
    _txSubscription = tx.onValueReceived.listen(_onTxData);

    // Step 3 – read INFO characteristic
    if (info != null) {
      await info.read();
    }

    // Step 4 – set BRSP mode to DATA (value = 1)
    await mode.write([1], withoutResponse: false);

    // Ready
    _rxChar = rx;
    _isConnected = true;
  }

  // ── Incoming data ─────────────────────────────────────────────────────────

  void _onTxData(List<int> bytes) {
    if (bytes.isEmpty) return;
    final text = utf8.decode(bytes, allowMalformed: true).trim();
    if (text.isEmpty) return;
    _messageController.add(text);
  }

  // ── Util ──────────────────────────────────────────────────────────────────

  BluetoothCharacteristic? _findChar(
      List<BluetoothCharacteristic> list, Guid uuid) {
    try {
      return list.firstWhere((c) => c.characteristicUuid == uuid);
    } catch (_) {
      return null;
    }
  }
}
