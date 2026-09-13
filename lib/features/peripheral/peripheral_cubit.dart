import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:flutter_ble_showcase/model/ble_connection_state.dart';
import 'package:flutter_ble_showcase/model/peripheral.dart';
import 'package:flutter_ble_showcase/usecase/check_ble_permissions_usecase.dart';
import 'package:flutter_ble_showcase/util/utils.dart';

sealed class PeripheralState {
  const PeripheralState();
}

final class PeripheralInitializingState extends PeripheralState {
  const PeripheralInitializingState();
}

final class PeripheralErrorState extends PeripheralState {
  const PeripheralErrorState();
}

sealed class PeripheralDataState extends PeripheralState {
  const PeripheralDataState({required this.model});

  final PeripheralModel model;
}

final class PeripheralInitializedState extends PeripheralDataState {
  const PeripheralInitializedState({required super.model});
}

final class PeripheralConnectedState extends PeripheralState {
  const PeripheralConnectedState();
}

class PeripheralCubit extends Cubit<PeripheralState> {
  PeripheralCubit(this._manager, this._checkBlePermissions)
    : super(const PeripheralInitializingState());

  final PeripheralManager _manager;
  final CheckBlePermissionsUsecase _checkBlePermissions;

  StreamSubscription? _connectionSub;
  StreamSubscription? _deviceSub;

  // TODO: Integrate with Bloc State
  Central? _connectedCentral;
  bool isAdvertising = false;
  final List<GATTService> _addedServices = [];

  Future<void> init() async {
    print('PeripheralCubit.init()');
    if (Platform.isAndroid) {
      final arePermissionsGranted = await _checkBlePermissions(
        permissions: [.bluetoothAdvertise],
      );

      if (!arePermissionsGranted) {
        print('BLE permissions denied');
        emit(PeripheralErrorState());
        return;
      }

      _connectionSub = _manager.connectionStateChanged
          .map(_mapArgs)
          .listen(_onConnectionStateChange);
    }

    final state = _manager.state;
    if (state == .poweredOn) {
      _startAdvertising();
    } else {
      _deviceSub = _manager.stateChanged.listen(_onDeviceStateChanged);
    }
  }

  Future<void> _startAdvertising() async {
    print('PeripheralCubit._startAdvertising');
    await _addServices();

    final services = [counterServiceUuid];

    final advertisement = Advertisement(
      name: advertisedName,
      serviceUUIDs: services.map(UUID.fromString).toList(),
    );

    await _manager.startAdvertising(advertisement);

    const model = PeripheralModel(name: advertisedName);
    emit(const PeripheralInitializedState(model: model));
  }

  BleConnectionState _mapArgs(CentralConnectionStateChangedEventArgs args) {
    print('PeripheralCubit._mapArgs: $args');
    switch (args.state) {
      case .disconnected:
        if (_connectedCentral?.uuid == args.central.uuid) {
          _connectedCentral = null;
          _addedServices.clear();
        }
        return .disconnected;
      case .connected:
        _connectedCentral = args.central;
        return .connected;
    }
  }

  void _onConnectionStateChange(BleConnectionState state) {
    print('PeripheralCubit._onConnectionStateChange: $state');
    if (state == .connected) {
      emit(const PeripheralConnectedState());
    }
  }

  void _onDeviceStateChanged(BluetoothLowEnergyStateChangedEventArgs args) {
    print('PeripheralCubit._onDeviceStateChanged: $args');
    if (args.state == .poweredOn) {
      _startAdvertising();
    }
  }

  Future<void> _addServices() async {
    print('PeripheralCubit._addServices');
    final characteristics = [
      GATTCharacteristic.mutable(
        uuid: UUID.fromString(counterReadCharacteristicUuid),
        properties: [.read],
        permissions: [.read],
        descriptors: [],
      ),
      GATTCharacteristic.mutable(
        uuid: UUID.fromString(counterWriteCharacteristicUuid),
        properties: [.writeWithoutResponse],
        permissions: [.write],
        descriptors: [],
      ),
      GATTCharacteristic.mutable(
        uuid: UUID.fromString(counterReadCharacteristicUuid),
        properties: [.notify],
        permissions: [.read],
        descriptors: [],
      ),
    ];

    final services = [
      GATTService(
        uuid: .fromString(counterServiceUuid),
        isPrimary: true,
        includedServices: [],
        characteristics: characteristics,
      ),
    ];

    for (final service in services) {
      await _manager.addService(service);
      _addedServices.add(service);
    }
  }

  @override
  Future<void> close() {
    print('PeripheralCubit.close');
    _connectionSub?.cancel();
    _connectionSub = null;

    _deviceSub?.cancel();
    _deviceSub = null;

    _manager.stopAdvertising();

    return super.close();
  }
}
