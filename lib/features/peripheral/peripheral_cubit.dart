import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter_ble_showcase/model/peripheral.dart';
import 'package:flutter_ble_showcase/usecase/check_ble_permissions_usecase.dart';
import 'package:flutter_ble_showcase/util/utils.dart';
import 'package:universal_ble/universal_ble.dart';

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
  PeripheralCubit(this._checkBlePermissions)
    : super(const PeripheralInitializingState());

  final CheckBlePermissionsUsecase _checkBlePermissions;

  StreamSubscription? _connectionSub;
  StreamSubscription? _deviceSub;
  StreamSubscription? _advertisementSub;

  // TODO: Integrate with Bloc State
  bool isAdvertising = false;
  String? _connectedCentral;
  _CubitAdvertisingSate _advertisingState = .idle;
  final List<BlePeripheralService> _addedServices = [];

  Future<void> init() async {
    print('PeripheralCubit.init()');
    final capabilities = await UniversalBlePeripheral.getCapabilities();
    if (!capabilities.supportsPeripheralMode) {
      print('Does not support peripheral mode');
      emit(PeripheralErrorState());
      return;
    }

    if (Platform.isAndroid) {
      final arePermissionsGranted = await _checkBlePermissions(
        permissions: [.bluetoothAdvertise],
      );

      if (!arePermissionsGranted) {
        print('BLE permissions denied');
        emit(PeripheralErrorState());
        return;
      }
    }

    _connectionSub = UniversalBlePeripheral.connectionStateStream.listen(
      _onConnectionStateChanged,
    );

    final state = await UniversalBlePeripheral.getAvailabilityState();
    if (state == .ready) {
      _startAdvertising();
    } else {
      _deviceSub = UniversalBle.availabilityStream.listen(
        _onDeviceStateChanged,
      );
    }
  }

  Future<void> _startAdvertising() async {
    print('PeripheralCubit._startAdvertising');
    if (_advertisingState == .advertising) {
      print('PeripheralCubit._startAdvertising: Already advertising');
      return;
    }

    _advertisingState = .advertising;

    await _addServices();

    final services = [counterServiceUuid];

    UniversalBlePeripheral.startAdvertising(
      services: services,
      localName: advertisedName,
    );

    _advertisementSub = UniversalBlePeripheral.advertisingStateStream.listen(
      _onAdvertisingStateChanged,
    );

    const model = PeripheralModel(name: advertisedName);
    emit(const PeripheralInitializedState(model: model));
  }

  void _onConnectionStateChanged(BlePeripheralConnectionStateChanged event) {
    print('PeripheralCubit._onConnectionStateChange: $event');
    if (event.connected) {
      _connectedCentral = event.deviceId;
      emit(const PeripheralConnectedState());
    } else if (_connectedCentral == event.deviceId) {
      _connectedCentral = null;
      _addedServices.clear();
    }
  }

  void _onDeviceStateChanged(AvailabilityState state) {
    print('PeripheralCubit._onDeviceStateChanged: $state');
    if (state == .poweredOn) {
      _startAdvertising();
    }
  }

  void _onAdvertisingStateChanged(BlePeripheralAdvertisingStateChanged event) {
    print(
      'PeripheralCubit._onAdvertisingStateChanged: {state: ${event.state}${event.error != null ? ' error: ${event.error!}' : ''}}',
    );
  }

  Future<void> _addServices() async {
    print('PeripheralCubit._addServices');
    final characteristics = [
      BlePeripheralCharacteristic(
        uuid: counterReadCharacteristicUuid,
        properties: [.read],
        permissions: [.readable],
      ),
      BlePeripheralCharacteristic(
        uuid: counterWriteCharacteristicUuid,
        properties: [.writeWithoutResponse],
        permissions: [.writeable],
      ),
      BlePeripheralCharacteristic(
        uuid: counterNotifyCharacteristicUuid,
        properties: [.notify],
        permissions: [.readable],
      ),
    ];

    final services = [
      BlePeripheralService(
        uuid: counterServiceUuid,
        characteristics: characteristics,
      ),
    ];

    for (final service in services) {
      await UniversalBlePeripheral.addService(service);
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

    _advertisementSub?.cancel();
    _advertisementSub = null;

    UniversalBlePeripheral.stopAdvertising();

    return super.close();
  }
}

enum _CubitAdvertisingSate { idle, advertising }
