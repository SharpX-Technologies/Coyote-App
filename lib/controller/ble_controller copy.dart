// import 'dart:async';
// import 'package:coyote_app/services/ble_manager.dart';
// import 'package:coyote_app/services/brsp_manager.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:flutter/widgets.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:tuple/tuple.dart';

// class Battery {
//   int chargingStatus = 0;
//   double batteryPercentage = 0;
//   double batteryVoltage = 0;
//   double currentCycle = 0;

//   Battery();

//   Battery.fromString(String data) {
//     final parts = data.split(':');
//     if (parts.length >= 5) {
//       chargingStatus = int.tryParse(parts[1]) ?? 0;
//       batteryPercentage = double.tryParse(parts[2]) ?? 0;
//       batteryVoltage = double.tryParse(parts[3]) ?? 0;
//       currentCycle = double.tryParse(parts[4]) ?? 0;
//     }
//   }

//   /// SmartPuck battery: response is a 6-char string, voltage 3.00–4.15V → %.
//   /// First char is the type byte ('3'), remaining 5 chars are the raw value.
//   Battery.fromSmartPuck(String raw) {
//     if (raw.length < 5) return;
//     final valueStr = raw.substring(1); // drop leading type byte
//     final millivolts = int.tryParse(valueStr);
//     if (millivolts == null) return;
//     final voltage = millivolts / 100.0; // e.g. 3700 → 37.00 → voltage = 3.70
//     batteryPercentage = ((voltage - 3.0) / (4.15 - 3.0) * 100).clamp(0, 100);
//     batteryVoltage = voltage;
//     chargingStatus = 0; // SmartPuck doesn't report charging status
//   }
// }

// enum DeviceSide { left, right }

// enum Presets { sit, walk, run, non }

// /// Which BLE protocol a slot is using.
// enum DeviceType { newDevice, smartPuck, unknown }

// abstract class _Transport {
//   bool get isConnected;
//   Stream<String> get messageStream;
//   Future<void> sendMessage(String message);
//   Future<void> disconnect();
//   void clearConnection();
// }

// class _NusTransport implements _Transport {
//   final BleManager _m;
//   _NusTransport(this._m);
//   @override
//   bool get isConnected => _m.isConnected;
//   @override
//   Stream<String> get messageStream => _m.messageStream;
//   @override
//   Future<void> sendMessage(String message) => _m.sendMessage(message);
//   @override
//   Future<void> disconnect() => _m.disconnect();
//   @override
//   void clearConnection() => _m.clearConnection();
// }

// class _BrspTransport implements _Transport {
//   final BrspManager _m;
//   _BrspTransport(this._m);
//   @override
//   bool get isConnected => _m.isConnected;
//   @override
//   Stream<String> get messageStream => _m.messageStream;
//   @override
//   Future<void> sendMessage(String message) => _m.sendMessage(message);
//   @override
//   Future<void> disconnect() => _m.disconnect();
//   @override
//   void clearConnection() => _m.clearConnection();
// }

// class BleController extends GetxController with WidgetsBindingObserver {
//   final GetStorage _box = GetStorage();

//   StreamSubscription? _scanSubscription;
//   bool _isScanning = false;
//   bool _leftConnecting = false;
//   bool _rightConnecting = false;

//   StreamSubscription? _leftSubscription;
//   StreamSubscription? _rightSubscription;

//   _Transport? _leftTransport;
//   _Transport? _rightTransport;

//   BleManager? _leftNus;
//   BleManager? _rightNus;
//   BrspManager? _leftBrsp;
//   BrspManager? _rightBrsp;

//   BluetoothDevice deviceInfo1 = BluetoothDevice(
//     remoteId: const DeviceIdentifier('str'),
//   );
//   BluetoothDevice deviceInfo2 = BluetoothDevice(
//     remoteId: const DeviceIdentifier('str'),
//   );
//   String deviceInfoName1 = '';
//   String deviceInfoName2 = '';
//   String msgRcv = '';

//   DeviceType _typeLeft = DeviceType.unknown;
//   DeviceType _typeRight = DeviceType.unknown;

//   DeviceType getDeviceType(DeviceSide side) =>
//       side == DeviceSide.left ? _typeLeft : _typeRight;

//   Battery batteryInfo1 = Battery();
//   Battery batteryInfo2 = Battery();
//   int currentPressure1 = 0;
//   int currentPressure2 = 0;
//   int targetPressure1 = 0;
//   int targetPressure2 = 0;
//   int pumpStatus1 = 0;
//   int pumpStatus2 = 0;
//   Presets selectedPreset1 = Presets.non;
//   Presets selectedPreset2 = Presets.non;
//   Map<String, int> preSets = {'sit': 8, 'walk': 10, 'run': 20};
//   List<ScanResult> scanResults = [];

//   /// 0 = Left, 1 = Right. Shared between ControlScreen and PairScreen.
//   int sideIndex = 0;

//   Timer? _timerLeft;
//   Timer? _timerRight;
//   Timer? _spBatteryLeft;
//   Timer? _spBatteryRight;
//   Timer? _spPumpLeft;
//   Timer? _spPumpRight;
//   Timer? _spPressureLeft;
//   Timer? _spPressureRight;

//   Battery getBatteryInfo(DeviceSide side) =>
//       side == DeviceSide.left ? batteryInfo1 : batteryInfo2;

//   int getCurrentPressure(DeviceSide side) =>
//       side == DeviceSide.left ? currentPressure1 : currentPressure2;

//   int getTargetPressure(DeviceSide side) =>
//       side == DeviceSide.left ? targetPressure1 : targetPressure2;

//   int getPumpStatus(DeviceSide side) {
//     if (side == DeviceSide.left) {
//       return (_leftTransport?.isConnected ?? false) ? pumpStatus1 : 0;
//     } else {
//       return (_rightTransport?.isConnected ?? false) ? pumpStatus2 : 0;
//     }
//   }

//   void stopScan() => _stopReconnectScan();
//   Presets getSelectedPreset(DeviceSide side) =>
//       side == DeviceSide.left ? selectedPreset1 : selectedPreset2;

//   bool isConnected({required DeviceSide deviceSide}) {
//     return deviceSide == DeviceSide.left
//         ? (_leftTransport?.isConnected ?? false)
//         : (_rightTransport?.isConnected ?? false);
//   }

//   bool isDeviceConnected(DeviceSide deviceSide, BluetoothDevice device) {
//     if (!isConnected(deviceSide: deviceSide)) return false;
//     final id = device.remoteId.str;
//     return deviceSide == DeviceSide.left
//         ? deviceInfo1.remoteId.str == id
//         : deviceInfo2.remoteId.str == id;
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     WidgetsBinding.instance.addObserver(this);
//     _restoreState();
//     FlutterBluePlus.adapterState.listen((state) {
//       if (state == BluetoothAdapterState.off) {
//         _handleBluetoothOff();
//       } else if (state == BluetoothAdapterState.on) {
//         _autoReconnect();
//       }
//     });
//     _autoReconnect();
//   }

//   @override
//   void onClose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _stopReconnectScan();
//     _cancelAllTimers();
//     _leftNus?.dispose();
//     _rightNus?.dispose();
//     _leftBrsp?.dispose();
//     _rightBrsp?.dispose();
//     super.onClose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) _autoReconnect();
//   }

//   Future<void> _autoReconnect() async {
//     final state = await FlutterBluePlus.adapterState.first;
//     if (state != BluetoothAdapterState.on) return;
//     if (deviceInfo1.remoteId.str == 'str' && deviceInfo2.remoteId.str == 'str')
//       return;
//     _startReconnectScan();
//     update();
//   }

//   void _startReconnectScan() {
//     final needLeft =
//         deviceInfo1.remoteId.str != 'str' &&
//         !(_leftTransport?.isConnected ?? false);
//     final needRight =
//         deviceInfo2.remoteId.str != 'str' &&
//         !(_rightTransport?.isConnected ?? false);

//     if (!needLeft && !needRight) {
//       _stopReconnectScan();
//       return;
//     }
//     if (_isScanning) return;

//     _isScanning = true;

//     FlutterBluePlus.startScan(
//       withServices: [
//         Guid(BleManager.NUS_SERVICE_UUID),
//         Guid(BrspManager.BRSP_SERVICE_UUID),
//       ],
//     );

//     _scanSubscription = FlutterBluePlus.scanResults.listen((results) async {
//       final futures = <Future>[];

//       for (final result in results) {
//         final id = result.device.remoteId.str;

//         if (id == deviceInfo1.remoteId.str &&
//             !(_leftTransport?.isConnected ?? false) &&
//             !_leftConnecting) {
//           _leftConnecting = true;
//           futures.add(
//             connect(
//               scanResult: result,
//               deviceSide: DeviceSide.left,
//             ).catchError((_) {}).whenComplete(() => _leftConnecting = false),
//           );
//         }

//         if (id == deviceInfo2.remoteId.str &&
//             !(_rightTransport?.isConnected ?? false) &&
//             !_rightConnecting) {
//           _rightConnecting = true;
//           futures.add(
//             connect(
//               scanResult: result,
//               deviceSide: DeviceSide.right,
//             ).catchError((_) {}).whenComplete(() => _rightConnecting = false),
//           );
//         }
//       }

//       await Future.wait(futures);

//       final bothDone =
//           (deviceInfo1.remoteId.str == 'str' ||
//               (_leftTransport?.isConnected ?? false)) &&
//           (deviceInfo2.remoteId.str == 'str' ||
//               (_rightTransport?.isConnected ?? false));
//       if (bothDone) _stopReconnectScan();
//     });
//   }

//   void _stopReconnectScan() {
//     if (!_isScanning) return;
//     _isScanning = false;
//     _scanSubscription?.cancel();
//     _scanSubscription = null;
//     FlutterBluePlus.stopScan();
//   }

//   Future<void> connect({
//     required ScanResult scanResult,
//     required DeviceSide deviceSide,
//   }) async {
//     final device = scanResult.device;

//     final alreadyConnected = deviceSide == DeviceSide.left
//         ? (_leftTransport?.isConnected ?? false)
//         : (_rightTransport?.isConnected ?? false);
//     if (alreadyConnected) return;

//     final serviceUuids = scanResult.advertisementData.serviceUuids
//         .map((g) => g.toString().toUpperCase())
//         .toList();

//     final isBrsp = serviceUuids.any((u) => u.contains('DA2B84F1'));
//     final type = isBrsp ? DeviceType.smartPuck : DeviceType.newDevice;

//     if (deviceSide == DeviceSide.left) {
//       deviceInfo1 = device;
//       if (device.advName.isNotEmpty) deviceInfoName1 = device.advName;
//       _typeLeft = type;
//       await _connectSide(DeviceSide.left, device, type);
//     } else {
//       deviceInfo2 = device;
//       if (device.advName.isNotEmpty) deviceInfoName2 = device.advName;
//       _typeRight = type;
//       await _connectSide(DeviceSide.right, device, type);
//     }

//     final bothDone =
//         (deviceInfo1.remoteId.str == 'str' ||
//             (_leftTransport?.isConnected ?? false)) &&
//         (deviceInfo2.remoteId.str == 'str' ||
//             (_rightTransport?.isConnected ?? false));
//     if (bothDone) _stopReconnectScan();

//     _updateSideIndex();
//     _saveState();
//     update();
//   }

//   Future<void> _connectSide(
//     DeviceSide side,
//     BluetoothDevice device,
//     DeviceType type,
//   ) async {
//     if (side == DeviceSide.left) {
//       await _leftSubscription?.cancel();
//       _leftSubscription = null;
//     } else {
//       await _rightSubscription?.cancel();
//       _rightSubscription = null;
//     }

//     _Transport transport;

//     if (type == DeviceType.smartPuck) {
//       final mgr = BrspManager(onDisconnected: () => _handleDisconnected(side));
//       await mgr.connect(device);
//       transport = _BrspTransport(mgr);

//       if (side == DeviceSide.left) {
//         _leftBrsp?.dispose();
//         _leftBrsp = mgr;
//         _leftTransport = transport;
//         _leftSubscription = mgr.messageStream.listen((msg) {
//           String currentTime =
//               "${DateTime.now().hour.toString().padLeft(2, '0')}:"
//               "${DateTime.now().minute.toString().padLeft(2, '0')}:"
//               "${DateTime.now().second.toString().padLeft(2, '0')}";

//           msgRcv += "\n[$currentTime] $msg";
//           update();
//           splitData(msg, DeviceSide.left);
//         });
//       } else {
//         _rightBrsp?.dispose();
//         _rightBrsp = mgr;
//         _rightTransport = transport;
//         _rightSubscription = mgr.messageStream.listen((msg) {
//           String currentTime =
//               "${DateTime.now().hour.toString().padLeft(2, '0')}:"
//               "${DateTime.now().minute.toString().padLeft(2, '0')}:"
//               "${DateTime.now().second.toString().padLeft(2, '0')}";

//           msgRcv += "\n[$currentTime] $msg";
//           update();
//           splitData(msg, DeviceSide.right);
//         });
//       }

//       await _sendInitialMessages(side);
//       _startSmartPuckTimers(side);
//     } else {
//       final mgr = BleManager(onDisconnected: () => _handleDisconnected(side));
//       await mgr.connect(device);
//       transport = _NusTransport(mgr);

//       if (side == DeviceSide.left) {
//         _leftNus?.dispose();
//         _leftNus = mgr;
//         _leftTransport = transport;
//         _leftSubscription = mgr.messageStream.listen((msg) {
//           splitData(msg, DeviceSide.left);
//         });
//       } else {
//         _rightNus?.dispose();
//         _rightNus = mgr;
//         _rightTransport = transport;
//         _rightSubscription = mgr.messageStream.listen(
//           (msg) => splitData(msg, DeviceSide.right),
//         );
//       }

//       await _sendInitialMessages(side);
//       _startNewDeviceTimer(side);
//     }
//   }

//   Future<void> disconnect(DeviceSide deviceSide) async {
//     _cancelSideTimers(deviceSide);

//     if (deviceSide == DeviceSide.left) {
//       await _leftSubscription?.cancel();
//       _leftSubscription = null;
//       await _leftTransport?.disconnect();
//       _leftTransport = null;
//       deviceInfo1 = BluetoothDevice(remoteId: const DeviceIdentifier('str'));
//       deviceInfoName1 = '';
//       batteryInfo1 = Battery();
//       currentPressure1 = 0;
//       targetPressure1 = 0;
//       pumpStatus1 = 0;
//       selectedPreset1 = Presets.non;
//       _typeLeft = DeviceType.unknown;
//     } else {
//       await _rightSubscription?.cancel();
//       _rightSubscription = null;
//       await _rightTransport?.disconnect();
//       _rightTransport = null;
//       deviceInfo2 = BluetoothDevice(remoteId: const DeviceIdentifier('str'));
//       deviceInfoName2 = '';
//       batteryInfo2 = Battery();
//       currentPressure2 = 0;
//       targetPressure2 = 0;
//       pumpStatus2 = 0;
//       selectedPreset2 = Presets.non;
//       _typeRight = DeviceType.unknown;
//     }

//     _stopReconnectScan();
//     update();
//     _saveState();
//   }

//   void _handleDisconnected(DeviceSide side) {
//     _cancelSideTimers(side);

//     if (side == DeviceSide.left) {
//       _leftSubscription?.cancel();
//       _leftSubscription = null;
//       _leftTransport = null;
//       batteryInfo1 = Battery();
//       currentPressure1 = 0;
//       pumpStatus1 = 0;
//       _leftConnecting = false;
//     } else {
//       _rightSubscription?.cancel();
//       _rightSubscription = null;
//       _rightTransport = null;
//       batteryInfo2 = Battery();
//       currentPressure2 = 0;
//       pumpStatus2 = 0;
//       _rightConnecting = false;
//     }

//     _stopReconnectScan();
//     _startReconnectScan();
//     _updateSideIndex();
//     _saveState();
//     update();
//   }

//   void _handleBluetoothOff() {
//     _stopReconnectScan();
//     _cancelAllTimers();

//     _leftSubscription?.cancel();
//     _leftSubscription = null;
//     _rightSubscription?.cancel();
//     _rightSubscription = null;

//     _leftTransport?.clearConnection();
//     _rightTransport?.clearConnection();
//     _leftTransport = null;
//     _rightTransport = null;

//     deviceInfo1 = BluetoothDevice(remoteId: const DeviceIdentifier('str'));
//     deviceInfo2 = BluetoothDevice(remoteId: const DeviceIdentifier('str'));
//     batteryInfo1 = Battery();
//     batteryInfo2 = Battery();
//     currentPressure1 = 0;
//     currentPressure2 = 0;
//     targetPressure1 = 0;
//     targetPressure2 = 0;
//     pumpStatus1 = 0;
//     pumpStatus2 = 0;
//     selectedPreset1 = Presets.non;
//     selectedPreset2 = Presets.non;
//     scanResults = [];
//     _leftConnecting = false;
//     _rightConnecting = false;
//     _typeLeft = DeviceType.unknown;
//     _typeRight = DeviceType.unknown;
//     _saveState();
//     update();
//   }

//   void splitData(String msg, DeviceSide side) {
//     if (msg.isEmpty) return;

//     final type = side == DeviceSide.left ? _typeLeft : _typeRight;

//     if (type == DeviceType.smartPuck) {
//       _splitSmartPuck(msg, side);
//     } else {
//       _splitNewDevice(msg, side);
//     }

//     _saveState();
//     update();
//   }

//   void _splitNewDevice(String msg, DeviceSide side) {
//     if (msg[0] == '0') {
//       final parts = msg.split(':');
//       if (parts.length < 2) return;
//       final value = int.tryParse(parts[1]) ?? 0;
//       if (side == DeviceSide.left)
//         targetPressure1 = value;
//       else
//         targetPressure2 = value;
//     } else if (msg[0] == '7') {
//       final battery = Battery.fromString(msg);
//       if (side == DeviceSide.left)
//         batteryInfo1 = battery;
//       else
//         batteryInfo2 = battery;
//     } else if (msg[0] == '4') {
//       final parts = msg.split(':');
//       if (parts.length < 2) return;
//       final value = (int.tryParse(parts[1]) ?? 0).clamp(0, 9999);
//       if (side == DeviceSide.left)
//         currentPressure1 = value;
//       else
//         currentPressure2 = value;
//     } else if (msg[0] == '6' || msg[0] == '1' || msg[0] == '2') {
//       final parts = msg.split(':');
//       if (parts.length < 2) return;
//       final value = int.tryParse(parts[1]) ?? 0;
//       if (side == DeviceSide.left)
//         pumpStatus1 = value;
//       else
//         pumpStatus2 = value;
//     }
//   }

//   void _splitSmartPuck(String msg, DeviceSide side) {
//     if (msg.isEmpty) return;
//     final typeChar = msg[0];

//     switch (typeChar) {
//       case '3': // Battery status
//         final battery = Battery.fromSmartPuck(msg);
//         if (side == DeviceSide.left)
//           batteryInfo1 = battery;
//         else
//           batteryInfo2 = battery;
//         break;

//       case '4': // Current pressure — 4-char raw value after type byte
//         if (msg.length >= 2) {
//           final value = (int.tryParse(msg.substring(1)) ?? 0).clamp(0, 9999);
//           if (side == DeviceSide.left)
//             currentPressure1 = value;
//           else
//             currentPressure2 = value;
//         }
//         break;

//       case '6': // On/off + pressure setting — 6-char string after type byte
//         if (msg.length >= 6) {
//           final onOff = int.tryParse(msg.substring(1, 2)) ?? 0;
//           final pressure = int.tryParse(msg.substring(2)) ?? 0;
//           if (side == DeviceSide.left) {
//             pumpStatus1 = onOff;
//             if (pressure > 0) targetPressure1 = pressure;
//           } else {
//             pumpStatus2 = onOff;
//             if (pressure > 0) targetPressure2 = pressure;
//           }
//         }
//         break;

//       case '7': // Reconnected acknowledgement — ignore
//         break;
//     }
//   }

//   Future<void> sendMessage({
//     required String message,
//     required DeviceSide deviceSide,
//   }) async {
//     final transport = deviceSide == DeviceSide.left
//         ? _leftTransport
//         : _rightTransport;
//     if (transport == null || !transport.isConnected) return;
//     try {
//       await transport.sendMessage(message);
//     } catch (e) {
//       print('BleController sendMessage error: $e');
//     }
//   }

//   Future<void> _sendInitialMessages(DeviceSide side) async {
//     final type = side == DeviceSide.left ? _typeLeft : _typeRight;
//     if (type == DeviceType.smartPuck) {
//       await sendMessage(message: '3', deviceSide: side);
//       await sendMessage(message: '4', deviceSide: side);
//       await sendMessage(message: '6', deviceSide: side);
//     } else {
//       await sendMessage(message: '7', deviceSide: side);
//       await sendMessage(message: '4', deviceSide: side);
//       await sendMessage(message: '6', deviceSide: side);
//     }
//   }

//   /// New device: single periodic poll every 5 seconds.
//   void _startNewDeviceTimer(DeviceSide side) {
//     if (side == DeviceSide.left) {
//       _timerLeft?.cancel();
//       _timerLeft = Timer.periodic(const Duration(seconds: 5), (_) {
//         if (_leftTransport?.isConnected ?? false) {
//           sendMessage(message: '4', deviceSide: DeviceSide.left);
//           sendMessage(message: '6', deviceSide: DeviceSide.left);
//           sendMessage(message: '7', deviceSide: DeviceSide.left);
//         }
//       });
//     } else {
//       _timerRight?.cancel();
//       _timerRight = Timer.periodic(const Duration(seconds: 5), (_) {
//         if (_rightTransport?.isConnected ?? false) {
//           sendMessage(message: '4', deviceSide: DeviceSide.right);
//           sendMessage(message: '6', deviceSide: DeviceSide.right);
//           sendMessage(message: '7', deviceSide: DeviceSide.right);
//         }
//       });
//     }
//   }

//   /// SmartPuck: three independent timers matching the Android app exactly.
//   void _startSmartPuckTimers(DeviceSide side) {
//     if (side == DeviceSide.left) {
//       _spBatteryLeft?.cancel();
//       _spPumpLeft?.cancel();
//       _spPressureLeft?.cancel();

//       _spBatteryLeft = Timer.periodic(const Duration(seconds: 20), (_) {
//         if (_leftTransport?.isConnected ?? false)
//           sendMessage(message: '3', deviceSide: DeviceSide.left);
//       });
//       _spPumpLeft = Timer.periodic(const Duration(seconds: 17), (_) {
//         if (_leftTransport?.isConnected ?? false)
//           sendMessage(message: '6', deviceSide: DeviceSide.left);
//       });
//       _spPressureLeft = Timer.periodic(const Duration(milliseconds: 800), (_) {
//         if (_leftTransport?.isConnected ?? false)
//           sendMessage(message: '4', deviceSide: DeviceSide.left);
//       });
//     } else {
//       _spBatteryRight?.cancel();
//       _spPumpRight?.cancel();
//       _spPressureRight?.cancel();

//       _spBatteryRight = Timer.periodic(const Duration(seconds: 20), (_) {
//         if (_rightTransport?.isConnected ?? false)
//           sendMessage(message: '3', deviceSide: DeviceSide.right);
//       });
//       _spPumpRight = Timer.periodic(const Duration(seconds: 17), (_) {
//         if (_rightTransport?.isConnected ?? false)
//           sendMessage(message: '6', deviceSide: DeviceSide.right);
//       });
//       _spPressureRight = Timer.periodic(const Duration(milliseconds: 800), (_) {
//         if (_rightTransport?.isConnected ?? false)
//           sendMessage(message: '4', deviceSide: DeviceSide.right);
//       });
//     }
//   }

//   void _cancelSideTimers(DeviceSide side) {
//     if (side == DeviceSide.left) {
//       _timerLeft?.cancel();
//       _timerLeft = null;
//       _spBatteryLeft?.cancel();
//       _spBatteryLeft = null;
//       _spPumpLeft?.cancel();
//       _spPumpLeft = null;
//       _spPressureLeft?.cancel();
//       _spPressureLeft = null;
//     } else {
//       _timerRight?.cancel();
//       _timerRight = null;
//       _spBatteryRight?.cancel();
//       _spBatteryRight = null;
//       _spPumpRight?.cancel();
//       _spPumpRight = null;
//       _spPressureRight?.cancel();
//       _spPressureRight = null;
//     }
//   }

//   void _cancelAllTimers() {
//     _cancelSideTimers(DeviceSide.left);
//     _cancelSideTimers(DeviceSide.right);
//   }

//   Future<void> setGuage({
//     required int pressure,
//     required DeviceSide deviceSide,
//   }) async {
//     if (deviceSide == DeviceSide.left)
//       targetPressure1 = pressure;
//     else
//       targetPressure2 = pressure;

//     final type = deviceSide == DeviceSide.left ? _typeLeft : _typeRight;
//     String cmd;
//     if (type == DeviceType.smartPuck) {
//       cmd = pressure < 10
//           ? '50${pressure.toString().padLeft(2, '0')}'
//           : '5$pressure';
//     } else {
//       cmd = '5:$pressure';
//     }
//     await sendMessage(message: cmd, deviceSide: deviceSide);
//     _saveState();
//   }

//   void ApplyPreset({
//     required DeviceSide deviceSide,
//     required Presets preset,
//   }) async {
//     if (!isConnected(deviceSide: deviceSide)) return;

//     int value = 0;
//     if (preset == Presets.sit)
//       value = preSets['sit'] ?? 0;
//     else if (preset == Presets.walk)
//       value = preSets['walk'] ?? 0;
//     else
//       value = preSets['run'] ?? 0;

//     if (deviceSide == DeviceSide.left) {
//       selectedPreset1 = preset;
//       targetPressure1 = value;
//     } else {
//       selectedPreset2 = preset;
//       targetPressure2 = value;
//     }

//     await setGuage(pressure: value, deviceSide: deviceSide);
//     _saveState();
//     update();
//   }

//   void setPreset({required Presets preset, required int value}) {
//     if (preset == Presets.sit)
//       preSets['sit'] = value;
//     else if (preset == Presets.walk)
//       preSets['walk'] = value;
//     else
//       preSets['run'] = value;
//     _saveState();
//     update();
//   }

//   void removePreset(DeviceSide deviceSide) {
//     if (deviceSide == DeviceSide.left)
//       selectedPreset1 = Presets.non;
//     else
//       selectedPreset2 = Presets.non;
//     _saveState();
//     update();
//   }

//   void _updateSideIndex() {
//     final leftOn = _leftTransport?.isConnected ?? false;
//     final rightOn = _rightTransport?.isConnected ?? false;
//     if (leftOn && !rightOn)
//       sideIndex = 0;
//     else if (rightOn && !leftOn)
//       sideIndex = 1;
//   }

//   Future<void> scan() async {
//     FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
//     FlutterBluePlus.scanResults.listen((results) {
//       scanResults = results.toList();
//       update();
//     });
//   }

//   void _saveState() {
//     final leftId = deviceInfo1.remoteId.str;
//     final rightId = deviceInfo2.remoteId.str;

//     if (leftId != 'str') {
//       _box.write('leftDeviceId', leftId);
//       _box.write('leftDeviceName', deviceInfoName1);
//       _box.write('leftDeviceType', _typeLeft.index);
//     } else {
//       _box.remove('leftDeviceId');
//       _box.remove('leftDeviceName');
//       _box.remove('leftDeviceType');
//     }

//     if (rightId != 'str') {
//       _box.write('rightDeviceId', rightId);
//       _box.write('rightDeviceName', deviceInfoName2);
//       _box.write('rightDeviceType', _typeRight.index);
//     } else {
//       _box.remove('rightDeviceId');
//       _box.remove('rightDeviceName');
//       _box.remove('rightDeviceType');
//     }

//     _box.write('batteryPercentage1', batteryInfo1.batteryPercentage);
//     _box.write('batteryVoltage1', batteryInfo1.batteryVoltage);
//     _box.write('batteryChargingStatus1', batteryInfo1.chargingStatus);
//     _box.write('batteryCurrentCycle1', batteryInfo1.currentCycle);
//     _box.write('currentPressure1', currentPressure1);
//     _box.write('targetPressure1', targetPressure1);
//     _box.write('pumpStatus1', pumpStatus1);
//     _box.write('selectedPresetIndex1', selectedPreset1.index);

//     _box.write('batteryPercentage2', batteryInfo2.batteryPercentage);
//     _box.write('batteryVoltage2', batteryInfo2.batteryVoltage);
//     _box.write('batteryChargingStatus2', batteryInfo2.chargingStatus);
//     _box.write('batteryCurrentCycle2', batteryInfo2.currentCycle);
//     _box.write('currentPressure2', currentPressure2);
//     _box.write('targetPressure2', targetPressure2);
//     _box.write('pumpStatus2', pumpStatus2);
//     _box.write('selectedPresetIndex2', selectedPreset2.index);

//     _box.write('preSets', preSets);
//   }

//   void _restoreState() {
//     final String? leftId = _box.read<String>('leftDeviceId');
//     final String? rightId = _box.read<String>('rightDeviceId');

//     if (leftId != null) {
//       deviceInfo1 = BluetoothDevice(remoteId: DeviceIdentifier(leftId));
//       deviceInfoName1 = _box.read<String>('leftDeviceName') ?? '';
//       final ti = _box.read<int>('leftDeviceType');
//       if (ti != null && ti >= 0 && ti < DeviceType.values.length) {
//         _typeLeft = DeviceType.values[ti];
//       }
//     }
//     if (rightId != null) {
//       deviceInfo2 = BluetoothDevice(remoteId: DeviceIdentifier(rightId));
//       deviceInfoName2 = _box.read<String>('rightDeviceName') ?? '';
//       final ti = _box.read<int>('rightDeviceType');
//       if (ti != null && ti >= 0 && ti < DeviceType.values.length) {
//         _typeRight = DeviceType.values[ti];
//       }
//     }

//     void _readBattery(Battery b, String suffix) {
//       final dynamic p = _box.read('batteryPercentage$suffix');
//       final dynamic v = _box.read('batteryVoltage$suffix');
//       final int? c = _box.read<int>('batteryChargingStatus$suffix');
//       final dynamic cy = _box.read('batteryCurrentCycle$suffix');
//       if (p is num) b.batteryPercentage = p.toDouble();
//       if (v is num) b.batteryVoltage = v.toDouble();
//       if (c != null) b.chargingStatus = c;
//       if (cy is num) b.currentCycle = cy.toDouble();
//     }

//     _readBattery(batteryInfo1, '1');
//     _readBattery(batteryInfo2, '2');

//     currentPressure1 = _box.read<int>('currentPressure1') ?? 0;
//     targetPressure1 = _box.read<int>('targetPressure1') ?? 0;
//     pumpStatus1 = _box.read<int>('pumpStatus1') ?? 0;
//     currentPressure2 = _box.read<int>('currentPressure2') ?? 0;
//     targetPressure2 = _box.read<int>('targetPressure2') ?? 0;
//     pumpStatus2 = _box.read<int>('pumpStatus2') ?? 0;

//     final sp1 = _box.read<int>('selectedPresetIndex1');
//     if (sp1 != null && sp1 >= 0 && sp1 < Presets.values.length) {
//       selectedPreset1 = Presets.values[sp1];
//     }
//     final sp2 = _box.read<int>('selectedPresetIndex2');
//     if (sp2 != null && sp2 >= 0 && sp2 < Presets.values.length) {
//       selectedPreset2 = Presets.values[sp2];
//     }

//     final dynamic storedPresets = _box.read('preSets');
//     if (storedPresets is Map) {
//       preSets = storedPresets.map(
//         (key, value) => MapEntry(key.toString(), (value as num).toInt()),
//       );
//     }

//     update();
//   }
// }

import 'dart:async';
import 'package:coyote_app/services/ble_manager.dart';
import 'package:coyote_app/services/brsp_manager.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class Battery {
  int chargingStatus = 0;
  double batteryPercentage = 0;
  double batteryVoltage = 0;
  double currentCycle = 0;

  Battery();

  Battery.fromString(String data) {
    final parts = data.split(':');
    if (parts.length >= 5) {
      chargingStatus = int.tryParse(parts[1]) ?? 0;
      batteryPercentage = double.tryParse(parts[2]) ?? 0;
      batteryVoltage = double.tryParse(parts[3]) ?? 0;
      currentCycle = double.tryParse(parts[4]) ?? 0;
    }
  }

  /// SmartPuck battery response: exactly 6 chars
  /// index 0 = type byte ('3')
  /// index 1 = unknown/skip byte
  /// index 2-5 = voltage string e.g. "4.15"
  Battery.fromSmartPuck(String raw) {
    if (raw.length != 6) return;
    final voltageStr = raw.substring(2, 6);
    final voltage = double.tryParse(voltageStr) ?? 0;
    batteryVoltage = voltage;
    batteryPercentage = ((voltage - 3.0) / (4.15 - 3.0) * 100).clamp(
      0.0,
      100.0,
    );
    chargingStatus = 0;
  }
}

enum DeviceSide { left, right }

enum Presets { sit, walk, run, non }

enum DeviceType { newDevice, smartPuck, unknown }

abstract class _Transport {
  bool get isConnected;
  Stream<String> get messageStream;
  Future<void> sendMessage(String message);
  Future<void> disconnect();
  void clearConnection();
}

class _NusTransport implements _Transport {
  final BleManager _m;
  _NusTransport(this._m);
  @override
  bool get isConnected => _m.isConnected;
  @override
  Stream<String> get messageStream => _m.messageStream;
  @override
  Future<void> sendMessage(String message) => _m.sendMessage(message);
  @override
  Future<void> disconnect() => _m.disconnect();
  @override
  void clearConnection() => _m.clearConnection();
}

class _BrspTransport implements _Transport {
  final BrspManager _m;
  _BrspTransport(this._m);
  @override
  bool get isConnected => _m.isConnected;
  @override
  Stream<String> get messageStream => _m.messageStream;
  @override
  Future<void> sendMessage(String message) => _m.sendMessage(message);
  @override
  Future<void> disconnect() => _m.disconnect();
  @override
  void clearConnection() => _m.clearConnection();
}

class BleController extends GetxController with WidgetsBindingObserver {
  final GetStorage _box = GetStorage();

  StreamSubscription? _scanSubscription;
  bool _isScanning = false;
  bool _leftConnecting = false;
  bool _rightConnecting = false;

  StreamSubscription? _leftSubscription;
  StreamSubscription? _rightSubscription;

  _Transport? _leftTransport;
  _Transport? _rightTransport;

  BleManager? _leftNus;
  BleManager? _rightNus;
  BrspManager? _leftBrsp;
  BrspManager? _rightBrsp;

  BluetoothDevice deviceInfo1 = BluetoothDevice(
    remoteId: const DeviceIdentifier('str'),
  );
  BluetoothDevice deviceInfo2 = BluetoothDevice(
    remoteId: const DeviceIdentifier('str'),
  );
  String deviceInfoName1 = '';
  String deviceInfoName2 = '';
  String msgRcv = '';

  DeviceType _typeLeft = DeviceType.unknown;
  DeviceType _typeRight = DeviceType.unknown;

  DeviceType getDeviceType(DeviceSide side) =>
      side == DeviceSide.left ? _typeLeft : _typeRight;

  Battery batteryInfo1 = Battery();
  Battery batteryInfo2 = Battery();
  int currentPressure1 = 0;
  int currentPressure2 = 0;
  int targetPressure1 = 0;
  int targetPressure2 = 0;
  int pumpStatus1 = 0;
  int pumpStatus2 = 0;
  Presets selectedPreset1 = Presets.non;
  Presets selectedPreset2 = Presets.non;
  Map<String, int> preSets = {'sit': 8, 'walk': 10, 'run': 20};
  List<ScanResult> scanResults = [];

  int sideIndex = 0;

  Timer? _timerLeft;
  Timer? _timerRight;
  Timer? _spBatteryLeft;
  Timer? _spBatteryRight;
  Timer? _spPumpLeft;
  Timer? _spPumpRight;
  Timer? _spPressureLeft;
  Timer? _spPressureRight;

  Battery getBatteryInfo(DeviceSide side) =>
      side == DeviceSide.left ? batteryInfo1 : batteryInfo2;

  int getCurrentPressure(DeviceSide side) =>
      side == DeviceSide.left ? currentPressure1 : currentPressure2;

  int getTargetPressure(DeviceSide side) =>
      side == DeviceSide.left ? targetPressure1 : targetPressure2;

  int getPumpStatus(DeviceSide side) {
    if (side == DeviceSide.left) {
      return (_leftTransport?.isConnected ?? false) ? pumpStatus1 : 0;
    } else {
      return (_rightTransport?.isConnected ?? false) ? pumpStatus2 : 0;
    }
  }

  void stopScan() => _stopReconnectScan();

  Presets getSelectedPreset(DeviceSide side) =>
      side == DeviceSide.left ? selectedPreset1 : selectedPreset2;

  bool isConnected({required DeviceSide deviceSide}) {
    return deviceSide == DeviceSide.left
        ? (_leftTransport?.isConnected ?? false)
        : (_rightTransport?.isConnected ?? false);
  }

  bool isDeviceConnected(DeviceSide deviceSide, BluetoothDevice device) {
    if (!isConnected(deviceSide: deviceSide)) return false;
    final id = device.remoteId.str;
    return deviceSide == DeviceSide.left
        ? deviceInfo1.remoteId.str == id
        : deviceInfo2.remoteId.str == id;
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _restoreState();
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.off) {
        _handleBluetoothOff();
      } else if (state == BluetoothAdapterState.on) {
        _autoReconnect();
      }
    });
    _autoReconnect();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopReconnectScan();
    _cancelAllTimers();
    _leftNus?.dispose();
    _rightNus?.dispose();
    _leftBrsp?.dispose();
    _rightBrsp?.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _autoReconnect();
  }

  // ── Auto reconnect ────────────────────────────────────────────────────────

  Future<void> _autoReconnect() async {
    final state = await FlutterBluePlus.adapterState.first;
    if (state != BluetoothAdapterState.on) return;
    if (deviceInfo1.remoteId.str == 'str' && deviceInfo2.remoteId.str == 'str')
      return;
    _startReconnectScan();
    update();
  }

  void _startReconnectScan() {
    final needLeft =
        deviceInfo1.remoteId.str != 'str' &&
        !(_leftTransport?.isConnected ?? false);
    final needRight =
        deviceInfo2.remoteId.str != 'str' &&
        !(_rightTransport?.isConnected ?? false);

    if (!needLeft && !needRight) {
      _stopReconnectScan();
      return;
    }
    if (_isScanning) return;

    _isScanning = true;

    FlutterBluePlus.startScan(
      withServices: [
        Guid(BleManager.NUS_SERVICE_UUID),
        Guid(BrspManager.BRSP_SERVICE_UUID),
      ],
    );

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) async {
      final futures = <Future>[];

      for (final result in results) {
        final id = result.device.remoteId.str;

        if (id == deviceInfo1.remoteId.str &&
            !(_leftTransport?.isConnected ?? false) &&
            !_leftConnecting) {
          _leftConnecting = true;
          futures.add(
            connect(
              scanResult: result,
              deviceSide: DeviceSide.left,
            ).catchError((_) {}).whenComplete(() => _leftConnecting = false),
          );
        }

        if (id == deviceInfo2.remoteId.str &&
            !(_rightTransport?.isConnected ?? false) &&
            !_rightConnecting) {
          _rightConnecting = true;
          futures.add(
            connect(
              scanResult: result,
              deviceSide: DeviceSide.right,
            ).catchError((_) {}).whenComplete(() => _rightConnecting = false),
          );
        }
      }

      await Future.wait(futures);

      final bothDone =
          (deviceInfo1.remoteId.str == 'str' ||
              (_leftTransport?.isConnected ?? false)) &&
          (deviceInfo2.remoteId.str == 'str' ||
              (_rightTransport?.isConnected ?? false));
      if (bothDone) _stopReconnectScan();
    });
  }

  void _stopReconnectScan() {
    if (!_isScanning) return;
    _isScanning = false;
    _scanSubscription?.cancel();
    _scanSubscription = null;
    FlutterBluePlus.stopScan();
  }

  // ── Connect ───────────────────────────────────────────────────────────────

  Future<void> connect({
    required ScanResult scanResult,
    required DeviceSide deviceSide,
  }) async {
    final device = scanResult.device;

    final alreadyConnected = deviceSide == DeviceSide.left
        ? (_leftTransport?.isConnected ?? false)
        : (_rightTransport?.isConnected ?? false);
    if (alreadyConnected) return;

    // Detect device type from advertised service UUIDs
    final serviceUuids = scanResult.advertisementData.serviceUuids
        .map((g) => g.toString().toUpperCase())
        .toList();

    final isBrsp = serviceUuids.any((u) => u.contains('DA2B84F1'));
    final type = isBrsp ? DeviceType.smartPuck : DeviceType.newDevice;

    if (deviceSide == DeviceSide.left) {
      deviceInfo1 = device;
      if (device.advName.isNotEmpty) deviceInfoName1 = device.advName;
      _typeLeft = type;
      await _connectSide(DeviceSide.left, device, type);
    } else {
      deviceInfo2 = device;
      if (device.advName.isNotEmpty) deviceInfoName2 = device.advName;
      _typeRight = type;
      await _connectSide(DeviceSide.right, device, type);
    }

    final bothDone =
        (deviceInfo1.remoteId.str == 'str' ||
            (_leftTransport?.isConnected ?? false)) &&
        (deviceInfo2.remoteId.str == 'str' ||
            (_rightTransport?.isConnected ?? false));
    if (bothDone) _stopReconnectScan();

    _updateSideIndex();
    _saveState();
    update();
  }

  Future<void> _connectSide(
    DeviceSide side,
    BluetoothDevice device,
    DeviceType type,
  ) async {
    if (side == DeviceSide.left) {
      await _leftSubscription?.cancel();
      _leftSubscription = null;
    } else {
      await _rightSubscription?.cancel();
      _rightSubscription = null;
    }

    _Transport transport;

    if (type == DeviceType.smartPuck) {
      // ── SmartPuck / BRSP ─────────────────────────────────────────────────
      final mgr = BrspManager(onDisconnected: () => _handleDisconnected(side));
      await mgr.connect(device);
      transport = _BrspTransport(mgr);

      if (side == DeviceSide.left) {
        _leftBrsp?.dispose();
        _leftBrsp = mgr;
        _leftTransport = transport;
        _leftSubscription = mgr.messageStream.listen((msg) {
          final t = DateTime.now();
          final ts =
              '${t.hour.toString().padLeft(2, '0')}:'
              '${t.minute.toString().padLeft(2, '0')}:'
              '${t.second.toString().padLeft(2, '0')}';
          msgRcv += '\n[$ts] $msg';
          splitData(msg, DeviceSide.left);
          update();
        });
      } else {
        _rightBrsp?.dispose();
        _rightBrsp = mgr;
        _rightTransport = transport;
        _rightSubscription = mgr.messageStream.listen((msg) {
          final t = DateTime.now();
          final ts =
              '${t.hour.toString().padLeft(2, '0')}:'
              '${t.minute.toString().padLeft(2, '0')}:'
              '${t.second.toString().padLeft(2, '0')}';
          msgRcv += '\n[$ts] $msg';
          splitData(msg, DeviceSide.right);
          update();
        });
      }

      await _sendInitialMessages(side);
      _startSmartPuckTimers(side);
    } else {
      // ── New device / NUS ─────────────────────────────────────────────────
      final mgr = BleManager(onDisconnected: () => _handleDisconnected(side));
      await mgr.connect(device);
      transport = _NusTransport(mgr);

      if (side == DeviceSide.left) {
        _leftNus?.dispose();
        _leftNus = mgr;
        _leftTransport = transport;
        _leftSubscription = mgr.messageStream.listen(
          (msg) => splitData(msg, DeviceSide.left),
        );
      } else {
        _rightNus?.dispose();
        _rightNus = mgr;
        _rightTransport = transport;
        _rightSubscription = mgr.messageStream.listen(
          (msg) => splitData(msg, DeviceSide.right),
        );
      }

      await _sendInitialMessages(side);
      _startNewDeviceTimer(side);
    }
  }

  // ── Disconnect ────────────────────────────────────────────────────────────

  Future<void> disconnect(DeviceSide deviceSide) async {
    _cancelSideTimers(deviceSide);

    if (deviceSide == DeviceSide.left) {
      await _leftSubscription?.cancel();
      _leftSubscription = null;
      await _leftTransport?.disconnect();
      _leftTransport = null;
      deviceInfo1 = BluetoothDevice(remoteId: const DeviceIdentifier('str'));
      deviceInfoName1 = '';
      batteryInfo1 = Battery();
      currentPressure1 = 0;
      targetPressure1 = 0;
      pumpStatus1 = 0;
      selectedPreset1 = Presets.non;
      _typeLeft = DeviceType.unknown;
    } else {
      await _rightSubscription?.cancel();
      _rightSubscription = null;
      await _rightTransport?.disconnect();
      _rightTransport = null;
      deviceInfo2 = BluetoothDevice(remoteId: const DeviceIdentifier('str'));
      deviceInfoName2 = '';
      batteryInfo2 = Battery();
      currentPressure2 = 0;
      targetPressure2 = 0;
      pumpStatus2 = 0;
      selectedPreset2 = Presets.non;
      _typeRight = DeviceType.unknown;
    }

    _stopReconnectScan();
    update();
    _saveState();
  }

  void _handleDisconnected(DeviceSide side) {
    _cancelSideTimers(side);

    if (side == DeviceSide.left) {
      _leftSubscription?.cancel();
      _leftSubscription = null;
      _leftTransport = null;
      batteryInfo1 = Battery();
      currentPressure1 = 0;
      pumpStatus1 = 0;
      _leftConnecting = false;
    } else {
      _rightSubscription?.cancel();
      _rightSubscription = null;
      _rightTransport = null;
      batteryInfo2 = Battery();
      currentPressure2 = 0;
      pumpStatus2 = 0;
      _rightConnecting = false;
    }

    _stopReconnectScan();
    _startReconnectScan();
    _updateSideIndex();
    _saveState();
    update();
  }

  void _handleBluetoothOff() {
    _stopReconnectScan();
    _cancelAllTimers();

    _leftSubscription?.cancel();
    _leftSubscription = null;
    _rightSubscription?.cancel();
    _rightSubscription = null;

    _leftTransport?.clearConnection();
    _rightTransport?.clearConnection();
    _leftTransport = null;
    _rightTransport = null;

    deviceInfo1 = BluetoothDevice(remoteId: const DeviceIdentifier('str'));
    deviceInfo2 = BluetoothDevice(remoteId: const DeviceIdentifier('str'));
    batteryInfo1 = Battery();
    batteryInfo2 = Battery();
    currentPressure1 = 0;
    currentPressure2 = 0;
    targetPressure1 = 0;
    targetPressure2 = 0;
    pumpStatus1 = 0;
    pumpStatus2 = 0;
    selectedPreset1 = Presets.non;
    selectedPreset2 = Presets.non;
    scanResults = [];
    _leftConnecting = false;
    _rightConnecting = false;
    _typeLeft = DeviceType.unknown;
    _typeRight = DeviceType.unknown;
    _saveState();
    update();
  }

  // ── Message parsing ───────────────────────────────────────────────────────

  void splitData(String msg, DeviceSide side) {
    if (msg.isEmpty) return;
    final type = side == DeviceSide.left ? _typeLeft : _typeRight;
    if (type == DeviceType.smartPuck) {
      _splitSmartPuck(msg, side);
    } else {
      _splitNewDevice(msg, side);
    }
    _saveState();
    update();
  }

  void _splitNewDevice(String msg, DeviceSide side) {
    if (msg.isEmpty) return;
    if (msg[0] == '0') {
      final parts = msg.split(':');
      if (parts.length < 2) return;
      final value = int.tryParse(parts[1]) ?? 0;
      if (side == DeviceSide.left)
        targetPressure1 = value;
      else
        targetPressure2 = value;
    } else if (msg[0] == '7') {
      final battery = Battery.fromString(msg);
      if (side == DeviceSide.left)
        batteryInfo1 = battery;
      else
        batteryInfo2 = battery;
    } else if (msg[0] == '4') {
      final parts = msg.split(':');
      if (parts.length < 2) return;
      final value = (int.tryParse(parts[1]) ?? 0).clamp(0, 9999);
      if (side == DeviceSide.left)
        currentPressure1 = value;
      else
        currentPressure2 = value;
    } else if (msg[0] == '6' || msg[0] == '1' || msg[0] == '2') {
      final parts = msg.split(':');
      if (parts.length < 2) return;
      final value = int.tryParse(parts[1]) ?? 0;
      if (side == DeviceSide.left)
        pumpStatus1 = value;
      else
        pumpStatus2 = value;
    }
  }

  void _splitSmartPuck(String msg, DeviceSide side) {
    if (msg.isEmpty) return;
    final typeChar = msg[0];

    switch (typeChar) {
      case '3':
        // 6 chars: index 0=type, index 1=skip, index 2-5=voltage e.g. "3X4.15"
        if (msg.length == 6) {
          final voltageStr = msg.substring(2, 6);
          final voltage = double.tryParse(voltageStr) ?? 0;
          final b = Battery();
          b.batteryVoltage = voltage;
          b.batteryPercentage = ((voltage - 3.0) / (4.15 - 3.0) * 100).clamp(
            0.0,
            100.0,
          );
          if (side == DeviceSide.left)
            batteryInfo1 = b;
          else
            batteryInfo2 = b;
        }
        break;

      case '4':
        // 4 chars: index 0=type, index 1=skip, index 2-3=pressure e.g. "4X08"
        if (msg.length == 4) {
          var num = msg.substring(2, 4);
          if (num.startsWith('0')) num = num.substring(1);
          final value = (int.tryParse(num) ?? 0).clamp(0, 9999);
          if (side == DeviceSide.left)
            currentPressure1 = value;
          else
            currentPressure2 = value;
        }
        break;

      case '6':
        // 6+ chars: index 0=type, index 1=skip, index 2=onOff,
        //           index 3=skip, index 4-5=pressure e.g. "6X1X08"
        if (msg.length >= 6) {
          final onOff = int.tryParse(msg.substring(2, 3)) ?? 0;
          final pressure = int.tryParse(msg.substring(4, 6)) ?? 0;
          if (side == DeviceSide.left) {
            pumpStatus1 = onOff;
            if (pressure > 0) targetPressure1 = pressure;
          } else {
            pumpStatus2 = onOff;
            if (pressure > 0) targetPressure2 = pressure;
          }
        }
        break;

      case '7':
        // Reconnected acknowledgement — nothing to do
        break;
    }
  }

  // ── Send ──────────────────────────────────────────────────────────────────

  Future<void> sendMessage({
    required String message,
    required DeviceSide deviceSide,
  }) async {
    final transport = deviceSide == DeviceSide.left
        ? _leftTransport
        : _rightTransport;
    if (transport == null || !transport.isConnected) return;
    try {
      await transport.sendMessage(message);
    } catch (e) {
      print('BleController sendMessage error: $e');
    }
  }

  Future<void> _sendInitialMessages(DeviceSide side) async {
    final type = side == DeviceSide.left ? _typeLeft : _typeRight;
    if (type == DeviceType.smartPuck) {
      await sendMessage(message: '3', deviceSide: side);
      await sendMessage(message: '4', deviceSide: side);
      await sendMessage(message: '6', deviceSide: side);
    } else {
      await sendMessage(message: '7', deviceSide: side);
      await sendMessage(message: '4', deviceSide: side);
      await sendMessage(message: '6', deviceSide: side);
    }
  }

  // ── Timers ────────────────────────────────────────────────────────────────

  void _startNewDeviceTimer(DeviceSide side) {
    if (side == DeviceSide.left) {
      _timerLeft?.cancel();
      _timerLeft = Timer.periodic(const Duration(seconds: 5), (_) {
        if (_leftTransport?.isConnected ?? false) {
          sendMessage(message: '4', deviceSide: DeviceSide.left);
          sendMessage(message: '6', deviceSide: DeviceSide.left);
          sendMessage(message: '7', deviceSide: DeviceSide.left);
        }
      });
    } else {
      _timerRight?.cancel();
      _timerRight = Timer.periodic(const Duration(seconds: 5), (_) {
        if (_rightTransport?.isConnected ?? false) {
          sendMessage(message: '4', deviceSide: DeviceSide.right);
          sendMessage(message: '6', deviceSide: DeviceSide.right);
          sendMessage(message: '7', deviceSide: DeviceSide.right);
        }
      });
    }
  }

  void _startSmartPuckTimers(DeviceSide side) {
    if (side == DeviceSide.left) {
      _spBatteryLeft?.cancel();
      _spPumpLeft?.cancel();
      _spPressureLeft?.cancel();

      // Battery every 20 seconds — unchanged
      _spBatteryLeft = Timer.periodic(const Duration(seconds: 20), (_) {
        if (_leftTransport?.isConnected ?? false)
          sendMessage(message: '3', deviceSide: DeviceSide.left);
      });

      // 4 and 6 alternate every 500ms
      bool _sendPressure = true;
      _spPressureLeft = Timer.periodic(const Duration(milliseconds: 500), (_) {
        if (_leftTransport?.isConnected ?? false) {
          sendMessage(
            message: _sendPressure ? '4' : '6',
            deviceSide: DeviceSide.left,
          );
          _sendPressure = !_sendPressure;
        }
      });
    } else {
      _spBatteryRight?.cancel();
      _spPumpRight?.cancel();
      _spPressureRight?.cancel();

      // Battery every 20 seconds — unchanged
      _spBatteryRight = Timer.periodic(const Duration(seconds: 20), (_) {
        if (_rightTransport?.isConnected ?? false)
          sendMessage(message: '3', deviceSide: DeviceSide.right);
      });

      // 4 and 6 alternate every 500ms
      bool _sendPressure = true;
      _spPressureRight = Timer.periodic(const Duration(milliseconds: 500), (_) {
        if (_rightTransport?.isConnected ?? false) {
          sendMessage(
            message: _sendPressure ? '4' : '6',
            deviceSide: DeviceSide.right,
          );
          _sendPressure = !_sendPressure;
        }
      });
    }
  }

  void _cancelSideTimers(DeviceSide side) {
    if (side == DeviceSide.left) {
      _timerLeft?.cancel();
      _timerLeft = null;
      _spBatteryLeft?.cancel();
      _spBatteryLeft = null;
      _spPumpLeft?.cancel();
      _spPumpLeft = null;
      _spPressureLeft?.cancel();
      _spPressureLeft = null;
    } else {
      _timerRight?.cancel();
      _timerRight = null;
      _spBatteryRight?.cancel();
      _spBatteryRight = null;
      _spPumpRight?.cancel();
      _spPumpRight = null;
      _spPressureRight?.cancel();
      _spPressureRight = null;
    }
  }

  void _cancelAllTimers() {
    _cancelSideTimers(DeviceSide.left);
    _cancelSideTimers(DeviceSide.right);
  }

  // ── Presets & gauge ───────────────────────────────────────────────────────

  Future<void> setGuage({
    required int pressure,
    required DeviceSide deviceSide,
  }) async {
    if (deviceSide == DeviceSide.left)
      targetPressure1 = pressure;
    else
      targetPressure2 = pressure;

    final type = deviceSide == DeviceSide.left ? _typeLeft : _typeRight;
    String cmd;
    if (type == DeviceType.smartPuck) {
      cmd = pressure < 10
          ? '50$pressure' // e.g. 8 → "508"
          : '5$pressure';
    } else {
      cmd = '5:$pressure';
    }
    await sendMessage(message: cmd, deviceSide: deviceSide);
    _saveState();
  }

  void ApplyPreset({
    required DeviceSide deviceSide,
    required Presets preset,
  }) async {
    if (!isConnected(deviceSide: deviceSide)) return;

    int value = 0;
    if (preset == Presets.sit)
      value = preSets['sit'] ?? 0;
    else if (preset == Presets.walk)
      value = preSets['walk'] ?? 0;
    else
      value = preSets['run'] ?? 0;

    if (deviceSide == DeviceSide.left) {
      selectedPreset1 = preset;
      targetPressure1 = value;
    } else {
      selectedPreset2 = preset;
      targetPressure2 = value;
    }

    await setGuage(pressure: value, deviceSide: deviceSide);
    _saveState();
    update();
  }

  void setPreset({required Presets preset, required int value}) {
    if (preset == Presets.sit)
      preSets['sit'] = value;
    else if (preset == Presets.walk)
      preSets['walk'] = value;
    else
      preSets['run'] = value;
    _saveState();
    update();
  }

  void removePreset(DeviceSide deviceSide) {
    if (deviceSide == DeviceSide.left)
      selectedPreset1 = Presets.non;
    else
      selectedPreset2 = Presets.non;
    _saveState();
    update();
  }

  void _updateSideIndex() {
    final leftOn = _leftTransport?.isConnected ?? false;
    final rightOn = _rightTransport?.isConnected ?? false;
    if (leftOn && !rightOn)
      sideIndex = 0;
    else if (rightOn && !leftOn)
      sideIndex = 1;
  }

  // Future<void> scan() async {
  //   FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
  //   FlutterBluePlus.scanResults.listen((results) {
  //     scanResults = results.toList();
  //     update();
  //   });
  // }
  // Future<void> scan() async {
  //   FlutterBluePlus.startScan(
  //     withServices: [
  //       Guid(BleManager.NUS_SERVICE_UUID),
  //       Guid(BrspManager.BRSP_SERVICE_UUID),
  //     ],
  //     timeout: const Duration(seconds: 15),
  //   );
  //   FlutterBluePlus.scanResults.listen((results) {
  //     scanResults = results.toList();
  //     update();
  //   });
  // }
  Future<void> scan() async {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    FlutterBluePlus.scanResults.listen((results) {
      scanResults = results.where((r) {
        final name = r.device.platformName;
        return name.startsWith('PUCK_') || name.startsWith('BlueRadios');
      }).toList();
      update();
    });
  }

  // ── Persist ───────────────────────────────────────────────────────────────

  void _saveState() {
    final leftId = deviceInfo1.remoteId.str;
    final rightId = deviceInfo2.remoteId.str;

    if (leftId != 'str') {
      _box.write('leftDeviceId', leftId);
      _box.write('leftDeviceName', deviceInfoName1);
      _box.write('leftDeviceType', _typeLeft.index);
    } else {
      _box.remove('leftDeviceId');
      _box.remove('leftDeviceName');
      _box.remove('leftDeviceType');
    }

    if (rightId != 'str') {
      _box.write('rightDeviceId', rightId);
      _box.write('rightDeviceName', deviceInfoName2);
      _box.write('rightDeviceType', _typeRight.index);
    } else {
      _box.remove('rightDeviceId');
      _box.remove('rightDeviceName');
      _box.remove('rightDeviceType');
    }

    _box.write('batteryPercentage1', batteryInfo1.batteryPercentage);
    _box.write('batteryVoltage1', batteryInfo1.batteryVoltage);
    _box.write('batteryChargingStatus1', batteryInfo1.chargingStatus);
    _box.write('batteryCurrentCycle1', batteryInfo1.currentCycle);
    _box.write('currentPressure1', currentPressure1);
    _box.write('targetPressure1', targetPressure1);
    _box.write('pumpStatus1', pumpStatus1);
    _box.write('selectedPresetIndex1', selectedPreset1.index);

    _box.write('batteryPercentage2', batteryInfo2.batteryPercentage);
    _box.write('batteryVoltage2', batteryInfo2.batteryVoltage);
    _box.write('batteryChargingStatus2', batteryInfo2.chargingStatus);
    _box.write('batteryCurrentCycle2', batteryInfo2.currentCycle);
    _box.write('currentPressure2', currentPressure2);
    _box.write('targetPressure2', targetPressure2);
    _box.write('pumpStatus2', pumpStatus2);
    _box.write('selectedPresetIndex2', selectedPreset2.index);

    _box.write('preSets', preSets);
  }

  void _restoreState() {
    final String? leftId = _box.read<String>('leftDeviceId');
    final String? rightId = _box.read<String>('rightDeviceId');

    if (leftId != null) {
      deviceInfo1 = BluetoothDevice(remoteId: DeviceIdentifier(leftId));
      deviceInfoName1 = _box.read<String>('leftDeviceName') ?? '';
      final ti = _box.read<int>('leftDeviceType');
      if (ti != null && ti >= 0 && ti < DeviceType.values.length) {
        _typeLeft = DeviceType.values[ti];
      }
    }
    if (rightId != null) {
      deviceInfo2 = BluetoothDevice(remoteId: DeviceIdentifier(rightId));
      deviceInfoName2 = _box.read<String>('rightDeviceName') ?? '';
      final ti = _box.read<int>('rightDeviceType');
      if (ti != null && ti >= 0 && ti < DeviceType.values.length) {
        _typeRight = DeviceType.values[ti];
      }
    }

    void readBattery(Battery b, String suffix) {
      final dynamic p = _box.read('batteryPercentage$suffix');
      final dynamic v = _box.read('batteryVoltage$suffix');
      final int? c = _box.read<int>('batteryChargingStatus$suffix');
      final dynamic cy = _box.read('batteryCurrentCycle$suffix');
      if (p is num) b.batteryPercentage = p.toDouble();
      if (v is num) b.batteryVoltage = v.toDouble();
      if (c != null) b.chargingStatus = c;
      if (cy is num) b.currentCycle = cy.toDouble();
    }

    readBattery(batteryInfo1, '1');
    readBattery(batteryInfo2, '2');

    currentPressure1 = _box.read<int>('currentPressure1') ?? 0;
    targetPressure1 = _box.read<int>('targetPressure1') ?? 0;
    pumpStatus1 = _box.read<int>('pumpStatus1') ?? 0;
    currentPressure2 = _box.read<int>('currentPressure2') ?? 0;
    targetPressure2 = _box.read<int>('targetPressure2') ?? 0;
    pumpStatus2 = _box.read<int>('pumpStatus2') ?? 0;

    final sp1 = _box.read<int>('selectedPresetIndex1');
    if (sp1 != null && sp1 >= 0 && sp1 < Presets.values.length) {
      selectedPreset1 = Presets.values[sp1];
    }
    final sp2 = _box.read<int>('selectedPresetIndex2');
    if (sp2 != null && sp2 >= 0 && sp2 < Presets.values.length) {
      selectedPreset2 = Presets.values[sp2];
    }

    final dynamic storedPresets = _box.read('preSets');
    if (storedPresets is Map) {
      preSets = storedPresets.map(
        (key, value) => MapEntry(key.toString(), (value as num).toInt()),
      );
    }

    update();
  }
}
