import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_ble_showcase/util/extensions/ble_device_ext.dart';
import 'package:flutter_ble_showcase/util/utils.dart';
import 'package:universal_ble/universal_ble.dart';

sealed class CentralState {
  const CentralState();
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

  final Map<String, BleDevice> peripherals;
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
  StreamSubscription? _connectionSub;

  BleDevice? _connectedPeripheral;

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

    final state = this.state;
    if (state is! CentralDataState) {
      return;
    }

    final peripheral = state.peripherals[uuid];

    if (peripheral == null) {
      print('Did not find the peripheral $uuid');
      emit(const CentralErrorState());
      return;
    }

    emit(CentralConnectingState(peripheral: peripheral));

    _connectedPeripheral = peripheral;
    _connectedPeripheral?.connectionStream.listen(_onConnectionStateChanged);

    await _connectedPeripheral?.connect(autoConnect: false);
  }

  void _onDetectedDevice(BleDevice discovered) {
    if (state is CentralConnectingState || state is CentralConnectedState) {
      return;
    }

    final currentPeripherals = switch (state) {
      CentralDataState(peripherals: final peripherals) => peripherals,
      _ => <String, BleDevice>{},
    };

    if (!currentPeripherals.containsKey(discovered.deviceId)) {
      final peripherals = {
        ...currentPeripherals,
        discovered.deviceId: discovered,
      };
      emit(CentralDataState(peripherals: peripherals));
    }
  }

  void _onDeviceStateChanged(AvailabilityState state) {
    print('CentralCubit._onDeviceStateChanged: $state');
    if (state == .poweredOn) {
      UniversalBle.startScan();
    }
  }

  void _onConnectionStateChanged(bool isConnected) {
    print('CentralCubit._onConnectionStateChanged: $isConnected');
    if (isConnected) {
      if (_connectedPeripheral case final peripheral?) {
        emit(CentralConnectedState(peripheral: peripheral));
      }
    } else {
      // Handle disconnection
    }
  }

  @override
  Future<void> close() {
    print('CentralCubit.close');
    _scanSub?.cancel();
    _scanSub = null;

    _deviceSub?.cancel();
    _deviceSub = null;

    _connectedPeripheral = null;

    _connectionSub?.cancel();
    _connectionSub = null;

    UniversalBle.stopScan();

    return super.close();
  }

  @override
  void onChange(Change<CentralState> change) {
    print(change);
    super.onChange(change);
  }
}
