import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_ble_showcase/util/extensions/ble_device_ext.dart';
import 'package:universal_ble/universal_ble.dart';

sealed class CentralState {
  const CentralState();

  List<BleDevice> get peripherals => [];
}

sealed class CentralLoadingState extends CentralState {
  const CentralLoadingState();

  String get loadingText;
}

final class CentralInitializingState extends CentralLoadingState {
  const CentralInitializingState();

  @override
  String get loadingText => 'Initializing BLE Central...';
}

final class CentralSearchingState extends CentralLoadingState {
  const CentralSearchingState();

  @override
  String get loadingText => 'Searching for peripherals...';
}

final class CentralDataState extends CentralState {
  const CentralDataState({required this.peripherals});

  @override
  final List<BleDevice> peripherals;
}

final class CentralConnectingState extends CentralLoadingState {
  const CentralConnectingState({required this.peripheral});

  final BleDevice peripheral;

  @override
  String get loadingText => 'Connecting to ${peripheral.deviceName}...';
}

final class CentralConnectedState extends CentralState {
  const CentralConnectedState({required this.peripheral});

  final BleDevice peripheral;
}

final class CentralErrorState extends CentralState {
  const CentralErrorState();
}

class CentralCubit extends Cubit<CentralState> {
  CentralCubit() : super(const CentralInitializingState());

  StreamSubscription? _scanSub;
  StreamSubscription? _deviceSub;

  List<BleDevice> get _peripherals => state.peripherals;

  Future<void> init() async {
    print('CentralCubit.init()');
    emit(const CentralSearchingState());

    _scanSub = UniversalBle.scanStream.listen(_onDetectedDevice);

    final state = await UniversalBle.getBluetoothAvailabilityState();
    if (state == .poweredOn) {
      UniversalBle.startScan();
    } else {
      _deviceSub = UniversalBle.availabilityStream.listen(
        _onDeviceStateChanged,
      );
    }
  }

  Future<void> connectToPeripheral({required String uuid}) async {
    print('CentralCubit.connectToPeripheral: $uuid');
  }

  void _onDetectedDevice(BleDevice discovered) {
    print('CentralCubit._onDetectedDevice: $discovered');
    final peripherals = [..._peripherals, discovered];
    emit(CentralDataState(peripherals: peripherals));
  }

  void _onDeviceStateChanged(AvailabilityState state) {
    print('CentralCubit._onDeviceStateChanged: $state');
    if (state == .poweredOn) {
      UniversalBle.startScan();
    }
  }

  @override
  Future<void> close() {
    print('CentralCubit.close');
    _scanSub?.cancel();
    _scanSub = null;

    UniversalBle.stopScan();

    return super.close();
  }
}
