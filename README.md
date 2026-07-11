# Coyote App — BLE Protocol & Developer Reference

A Flutter app that connects via Bluetooth Low Energy (BLE) to two prosthetic vacuum pump devices simultaneously — one for the left side, one for the right. It supports two generations of hardware with different BLE protocols.

---

## Table of Contents

- [Hardware Support](#hardware-support)
- [Architecture](#architecture)
- [Connection Lifecycle](#connection-lifecycle)
- [GATT UUIDs](#gatt-uuids)
- [Commands Sent — App → Device](#commands-sent--app--device)
- [Responses Received — Device → App](#responses-received--device--app)
- [Polling Timers](#polling-timers)
- [State & Persistence](#state--persistence)
- [Scan Filtering](#scan-filtering)
- [Common Pitfalls](#common-pitfalls)

---

## Hardware Support

| Property | New Device (NUS) | Old Device (SmartPuck / BRSP) |
|---|---|---|
| BLE Protocol | Nordic UART Service (NUS) | BlueRadios Serial Port (BRSP) |
| Device Name Prefix | `PUCK_` | `BlueRadios` |
| Message Format | Colon-delimited e.g. `"4:12"` | Positional bytes e.g. `"4X12"` |
| Connection Init | Subscribe to TX characteristic | 4-step BRSP handshake |
| Message Terminator | None | `\r` appended to every send |

---

## Architecture

### Key Files

| File | Responsibility |
|---|---|
| `lib/controller/ble_controller.dart` | Central state manager (GetX). Owns both device slots, timers, message routing, and persistence. |
| `lib/services/ble_manager.dart` | Low-level NUS BLE handler for the new device. |
| `lib/services/brsp_manager.dart` | Low-level BRSP BLE handler for the SmartPuck. Runs the 4-step handshake. |
| `lib/screens/pair_screen.dart` | Scan UI. Lists only `PUCK_` and `BlueRadios` devices. User picks Left or Right side before connecting. |
| `lib/screens/control_screen.dart` | Main control UI. Gauge, Sit/Walk/Run presets, battery, pump on/off. |

### Transport Abstraction

Both device types share the same `_Transport` interface so `BleController` treats them identically after connection:

```dart
abstract class _Transport {
  bool get isConnected;
  Stream<String> get messageStream;
  Future<void> sendMessage(String message);
  Future<void> disconnect();
  void clearConnection();
}
```

- `_NusTransport` wraps `BleManager` (new device)
- `_BrspTransport` wraps `BrspManager` (old device)

`BleController` never talks to `BleManager` or `BrspManager` directly — always through the transport interface.

---

## Connection Lifecycle

### Auto-Reconnect

On every app open, resume from background, or Bluetooth power-on, the controller calls `_autoReconnect()`. This starts a BLE scan filtered to both service UUIDs:

```dart
FlutterBluePlus.startScan(withServices: [
  Guid("6E400001-B5A3-F393-E0A9-E50E24DCCA9E"),  // NUS
  Guid("DA2B84F1-6279-48DE-BDC0-AFBEA0226079"),  // BRSP
]);
```

If a found device's MAC matches a saved left or right MAC, `connect()` is called automatically. Once both needed sides are connected the scan stops.

### Device Type Detection

At connect time, the advertised service UUIDs are read from the `ScanResult`:

```dart
final isBrsp = serviceUuids.any((u) => u.contains("DA2B84F1"));
final type = isBrsp ? DeviceType.smartPuck : DeviceType.newDevice;
```

The detected type is saved to local storage alongside the MAC so it survives app restarts.

### BRSP Handshake (SmartPuck only)

Before any data can flow on the old device, a 4-step handshake must complete **in order**:

| Step | Action | Detail |
|---|---|---|
| 1 | Enable RTS notifications | Subscribe to RTS characteristic. Wait 500ms. |
| 2 | Enable TX indications | Subscribe to TX characteristic. All incoming data arrives here. |
| 3 | Read INFO characteristic | Read INFO (result ignored, but required by protocol). |
| 4 | Set mode to DATA | Write byte `[1]` to MODE characteristic. Device is now ready. |

> The new device (NUS) has no handshake — subscribing to TX is sufficient.

### On Unexpected Disconnect

`_handleDisconnected()` is called. It cancels all timers for that side, clears the transport, resets state (battery, pressure, pump status to 0), and immediately restarts the reconnect scan for that side only. The other side is unaffected.

### On Manual Disconnect

Same as unexpected disconnect but also removes the saved MAC from storage, so auto-reconnect will not attempt to reconnect on next app open.

---

## GATT UUIDs

### New Device — Nordic UART Service (NUS)

| Role | UUID |
|---|---|
| Service | `6E400001-B5A3-F393-E0A9-E50E24DCCA9E` |
| RX (app → device) | `6E400002-B5A3-F393-E0A9-E50E24DCCA9E` |
| TX (device → app) | `6E400003-B5A3-F393-E0A9-E50E24DCCA9E` |

### Old Device — BRSP

| Role | UUID |
|---|---|
| Service | `DA2B84F1-6279-48DE-BDC0-AFBEA0226079` |
| RX (app → device) | `BF03260C-7205-4C25-AF43-93B1C299D159` |
| TX (device → app) | `18CDA784-4BD3-4370-85BB-BFED91EC86AF` |
| MODE | `A87988B9-694C-479C-900E-95DFA6C00A24` |
| RTS (flow control) | `FDD6B4D3-046D-4330-BDEC-1FD0C90CB43B` |
| INFO | `99564A02-DC01-4D3C-B04E-3BB1EF0571B2` |

---

## Commands Sent — App → Device

### New Device

Messages are plain strings, no terminator. Colon `:` is the delimiter.

| Command | String Sent | Meaning |
|---|---|---|
| Request battery | `"7"` | Ask device for battery status |
| Request pressure | `"4"` | Ask for current vacuum pressure |
| Request pump status | `"6"` | Ask for on/off state and target pressure |
| Set pressure | `"5:N"` e.g. `"5:12"` | Set target vacuum to N (0–20) |
| Turn pump ON | `"1"` | Start the vacuum pump |
| Turn pump OFF | `"2"` | Stop the vacuum pump |

### Old Device (SmartPuck)

`BrspManager` appends `\r` to every string before sending. Command is always a single character — no colon.

| Command | Bytes Sent | Meaning |
|---|---|---|
| Request battery | `"3\r"` | Ask device for battery voltage |
| Request pressure | `"4\r"` | Ask for current vacuum pressure |
| Request pump status | `"6\r"` | Ask for on/off state and target pressure |
| Set pressure (< 10) | `"50N\r"` e.g. `"508\r"` | Set target to N when N is single digit |
| Set pressure (≥ 10) | `"5N\r"` e.g. `"515\r"` | Set target to N when N is two digits |
| Turn pump ON | `"1\r"` | Start the vacuum pump |
| Turn pump OFF | `"2\r"` | Stop the vacuum pump |

> ⚠️ The set pressure format differs between devices. New device: `"5:8"`. Old device: `"508"`. Wrong format is silently ignored by hardware.

---

## Responses Received — Device → App

### New Device

All responses are colon-delimited strings. First character is the type byte.

| Type Byte | Example | Format | Parsed Fields |
|---|---|---|---|
| `7` | `"7:1:85:3.72:42"` | `"7:charging:pct:voltage:cycles"` | chargingStatus (0/1), batteryPercentage, batteryVoltage, currentCycle |
| `4` | `"4:12"` | `"4:pressure"` | currentPressure (integer, 0–9999) |
| `6` | `"6:1"` | `"6:pumpStatus"` | pumpStatus (0=off, 1=on) |
| `1` | `"1:1"` | `"1:pumpStatus"` | pumpStatus after turn-on |
| `2` | `"2:0"` | `"2:pumpStatus"` | pumpStatus after turn-off |
| `0` | `"0:12"` | `"0:targetPressure"` | targetPressure confirmation |

### Old Device (SmartPuck)

Responses are **positional byte strings — no delimiter**. Index 0 is always the type byte. Index 1 is always an **unknown skip byte** that must be ignored. Data starts at index 2.

| Type | Example | Length | Parsing |
|---|---|---|---|
| `3` Battery | `"3X4.15"` | 6 chars | Index 2–5 = voltage string e.g. `"4.15"`. Formula: `pct = ((voltage - 3.0) / (4.15 - 3.0)) × 100` |
| `4` Pressure | `"4X08"` | 4 chars | Index 2–3 = 2-digit string e.g. `"08"`. Strip leading zero → integer `8`. |
| `6` Pump+Pressure | `"6X1X08"` | 6+ chars | Index 2 = on/off. Index 3 = skip. Index 4–5 = target pressure 2-digit string. |
| `7` Reconnected | `"7..."` | Any | Acknowledgement only. Ignore. |

> ⚠️ `X` in examples above is the unknown skip byte at index 1. Its value varies. **Always parse from index 2, never index 1.** This is the most common parsing mistake.

---

## Polling Timers

Devices don't push data unprompted — the app polls on timers. Timers start after connection and are cancelled on disconnect.

### New Device — Single Timer

| Interval | Commands Sent |
|---|---|
| Every 5 seconds | `"4"` (pressure), `"6"` (pump status), `"7"` (battery) |

### Old Device (SmartPuck) — Two Timers

| Timer | Interval | Command | Notes |
|---|---|---|---|
| Alternating poll | Every 500ms | `"4"` and `"6"` alternating | At 500ms sends `"4"`, at 1000ms sends `"6"`, at 1500ms sends `"4"`, etc. |
| Battery poll | Every 20 seconds | `"3"` | Battery changes slowly, no need to poll fast |

---

## State & Persistence

`BleController` saves the following to `GetStorage` on every state change:

| Key | Type | Description |
|---|---|---|
| `leftDeviceId` | String | MAC address of left device |
| `leftDeviceName` | String | Display name of left device |
| `leftDeviceType` | int | `DeviceType` enum index (0=newDevice, 1=smartPuck, 2=unknown) |
| `rightDeviceId` | String | MAC address of right device |
| `rightDeviceName` | String | Display name of right device |
| `rightDeviceType` | int | `DeviceType` enum index |
| `batteryPercentage1/2` | double | Last known battery % for left/right |
| `batteryVoltage1/2` | double | Last known battery voltage for left/right |
| `currentPressure1/2` | int | Last known current pressure for left/right |
| `targetPressure1/2` | int | Last set target pressure for left/right |
| `pumpStatus1/2` | int | Last known pump on/off (0 or 1) |
| `selectedPresetIndex1/2` | int | Presets enum index (0=sit, 1=walk, 2=run, 3=non) |
| `preSets` | Map | Custom preset values: `{sit: N, walk: N, run: N}` |

---

## Scan Filtering

Two filters are applied to make sure only known hardware appears:

**Filter 1** — passed to `FlutterBluePlus.startScan()`:
```dart
withServices: [Guid(NUS_SERVICE_UUID), Guid(BRSP_SERVICE_UUID)]
```

**Filter 2** — applied to results in the scan listener (catches devices that don't advertise service UUIDs in their advertisement packet):
```dart
if (!name.startsWith("PUCK_") && !name.startsWith("BlueRadios")) continue;
```

**Display name transformation:**

| Raw Device Name | Displayed As |
|---|---|
| `PUCK_L_A1B2C3` | `L_A1B2C3` |
| `BlueRadiosXYZ` | `BR_XYZ` |

---

## Common Pitfalls

| Mistake | Correct Approach |
|---|---|
| Parsing SmartPuck response from index 1 | Always start from index 2 — index 1 is an unknown skip byte |
| Using `"5:8"` format for SmartPuck pressure | Use `"508"` for values < 10, `"515"` for values ≥ 10 |
| Using `"508"` format for new device pressure | New device uses colon format: `"5:8"` |
| Calling `connect()` with `BluetoothDevice` only | Pass the full `ScanResult` — device type is detected from advertised service UUIDs |
| Relying only on the `withServices` scan filter | Some devices don't advertise service UUIDs. Always also filter by name prefix in the listener |
| Forgetting the BRSP handshake for SmartPuck | The 4-step handshake must complete before sending any command |
| Sending commands before BRSP is ready | `BrspManager.isConnected` returns `true` only after the handshake completes |
| Cancelling only one timer on SmartPuck disconnect | SmartPuck has 2 timers per side (`_spBattery`, `_spPressure`). Cancel both in `_cancelSideTimers()` |

---

*Last updated: July 2026*
