import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:flutter_ble_showcase/model/ble_connection_state.dart';
import 'package:flutter_ble_showcase/model/peripheral.dart';
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
  PeripheralCubit(this._manager) : super(const PeripheralInitializingState());

  final PeripheralManager _manager;

  StreamSubscription? sub;

  // TODO: Integrate with Bloc State
  Central? _connectedCentral;
  final List<GATTService> _addedServices = [];

  Future<void> init() async {
    if (Platform.isAndroid) {
      sub = _manager.connectionStateChanged
          .map(_mapArgs)
          .listen(_onConnectionStateChange);
    }

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
    switch (args.state) {
      case ConnectionState.disconnected:
        if (_connectedCentral?.uuid == args.central.uuid) {
          _connectedCentral = null;
          _addedServices.clear();
        }
        return BleConnectionState.disconnected;
      case ConnectionState.connected:
        _connectedCentral = args.central;
        return BleConnectionState.connected;
    }
  }

  void _onConnectionStateChange(BleConnectionState state) {
    if (state == BleConnectionState.connected) {
      emit(const PeripheralConnectedState());
    }
  }

  Future<void> _addServices() async {
    final characteristics = [
      GATTCharacteristic.mutable(
        uuid: UUID.fromString(counterReadCharacteristicUuid),
        properties: [GATTCharacteristicProperty.read],
        permissions: [GATTCharacteristicPermission.read],
        descriptors: [],
      ),
      GATTCharacteristic.mutable(
        uuid: UUID.fromString(counterWriteCharacteristicUuid),
        properties: [GATTCharacteristicProperty.writeWithoutResponse],
        permissions: [GATTCharacteristicPermission.write],
        descriptors: [],
      ),
      GATTCharacteristic.mutable(
        uuid: UUID.fromString(counterReadCharacteristicUuid),
        properties: [GATTCharacteristicProperty.notify],
        permissions: [GATTCharacteristicPermission.read],
        descriptors: [],
      ),
    ];

    final services = [
      GATTService(
        uuid: UUID.fromString(counterServiceUuid),
        isPrimary: true,
        includedServices: [],
        characteristics: characteristics,
      ),
    ];

    for (final service in services) {
      await _manager.addService(service);
    }
  }

  @override
  Future<void> close() {
    sub?.cancel();
    sub = null;

    _manager.stopAdvertising();

    return super.close();
  }
}
