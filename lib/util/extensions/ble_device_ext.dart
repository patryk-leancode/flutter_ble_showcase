import 'package:universal_ble/universal_ble.dart';

extension BleDeviceExt on BleDevice {
  String get deviceName => name ?? 'Name not available';
}
