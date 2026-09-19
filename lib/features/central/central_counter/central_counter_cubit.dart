import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter_ble_showcase/util/utils.dart';
import 'package:universal_ble/universal_ble.dart';

sealed class CentralCounterState {
  const CentralCounterState({
    required this.peripheralValue,
    required this.centralValue,
    required this.peripheralStreamValue,
    required this.areButtonsEnabled,
    required this.isLoading,
    required this.isError,
  });

  final int peripheralValue;
  final int centralValue;
  final int peripheralStreamValue;
  final bool areButtonsEnabled;
  final bool isLoading;
  final bool isError;

  CentralCounterState copyWith({bool? isError});
}

final class CentralCounterReadyState extends CentralCounterState {
  const CentralCounterReadyState({
    required super.peripheralValue,
    required super.centralValue,
    required super.peripheralStreamValue,
    super.isError = false,
  }) : super(areButtonsEnabled: true, isLoading: false);

  @override
  CentralCounterState copyWith({bool? isError}) {
    return CentralCounterReadyState(
      peripheralValue: peripheralValue,
      centralValue: centralValue,
      peripheralStreamValue: peripheralStreamValue,
      isError: isError ?? this.isError,
    );
  }
}

final class CentralCounterLoadingState extends CentralCounterState {
  const CentralCounterLoadingState({
    required super.peripheralValue,
    required super.centralValue,
    required super.peripheralStreamValue,
    super.isError = false,
  }) : super(areButtonsEnabled: false, isLoading: true);

  @override
  CentralCounterState copyWith({bool? isError}) {
    return CentralCounterLoadingState(
      peripheralValue: peripheralValue,
      centralValue: centralValue,
      peripheralStreamValue: peripheralStreamValue,
      isError: isError ?? this.isError,
    );
  }
}

class CentralCounterCubit extends Cubit<CentralCounterState> {
  CentralCounterCubit({required this.connectedPeripheral})
    : super(
        const CentralCounterReadyState(
          peripheralValue: 0,
          centralValue: 0,
          peripheralStreamValue: 0,
          isError: false,
        ),
      );

  final BleDevice connectedPeripheral;

  StreamSubscription? sub;

  void init() {
    // sub = _manager
    //     .stream(
    //       serviceUuid: counterServiceUuid,
    //       characteristicUuid: counterNotifyCharacteristicUuid,
    //     )
    //     .listen(_onStreamUpdate);
  }

  Future<void> refresh() async {
    emit(
      CentralCounterLoadingState(
        peripheralValue: state.peripheralValue,
        centralValue: state.centralValue,
        peripheralStreamValue: state.peripheralStreamValue,
        isError: false,
      ),
    );

    final characteristic = await connectedPeripheral.getCharacteristic(
      counterReadCharacteristicUuid,
      service: counterServiceUuid,
    );

    final value = await characteristic.read();

    emit(
      CentralCounterReadyState(
        peripheralValue: intFromUint8List(value),
        centralValue: state.centralValue,
        peripheralStreamValue: state.peripheralStreamValue,
      ),
    );
  }

  void increment() => _updateValue(state.centralValue + 1);

  void decrement() => _updateValue(state.centralValue - 1);

  Future<void> _updateValue(int value) async {
    emit(
      CentralCounterLoadingState(
        peripheralValue: state.peripheralValue,
        centralValue: state.centralValue,
        peripheralStreamValue: state.peripheralStreamValue,
      ),
    );

    // await _manager.write(
    //   serviceUuid: counterServiceUuid,
    //   characteristicUuid: counterWriteCharacteristicUuid,
    //   value: value,
    // );

    emit(
      CentralCounterReadyState(
        peripheralValue: state.peripheralValue,
        centralValue: value,
        peripheralStreamValue: state.peripheralStreamValue,
      ),
    );
  }

  void _onStreamUpdate(int value) {
    emit(
      CentralCounterReadyState(
        peripheralValue: state.peripheralValue,
        centralValue: state.centralValue,
        peripheralStreamValue: value,
      ),
    );
  }

  Future<BleCharacteristic?> _findCharacteristic({
    required String serviceUuid,
    required String characteristicUuid,
  }) async {
    final services = await connectedPeripheral.discoverServices();

    final service = services.firstWhereOrNull((s) => s.uuid == serviceUuid);
    if (service == null) {
      print('Did not find service');
      return null;
    }

    final characteristics = service.characteristics;

    final characteristic = characteristics.firstWhereOrNull(
      (c) => c.uuid == characteristicUuid,
    );
    if (characteristic == null) {
      print('Did not find characteristic');
      return null;
    }

    return characteristic;
  }

  @override
  Future<void> close() {
    sub?.cancel();
    sub = null;

    return super.close();
  }
}
