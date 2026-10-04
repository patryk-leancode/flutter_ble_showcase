import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_ble_showcase/model/coffee_machine.dart';
import 'package:flutter_ble_showcase/util/utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_ble/universal_ble.dart';

final class PeripheralCoffeeMachineState {
  const PeripheralCoffeeMachineState({
    required this.cupsBrewed,
    required this.currentOrder,
    required this.brewProgress,
    this.isDisconnected = false,
  });

  final int cupsBrewed;
  final CupSize? currentOrder;
  final BrewProgress brewProgress;
  final bool isDisconnected;

  PeripheralCoffeeMachineState copyWith({
    int? cupsBrewed,
    CupSize? currentOrder,
    BrewProgress? brewProgress,
    bool? isDisconnected,
  }) {
    return PeripheralCoffeeMachineState(
      cupsBrewed: cupsBrewed ?? this.cupsBrewed,
      currentOrder: currentOrder ?? this.currentOrder,
      brewProgress: brewProgress ?? this.brewProgress,
      isDisconnected: isDisconnected ?? this.isDisconnected,
    );
  }
}

class PeripheralCoffeeMachineCubit extends Cubit<PeripheralCoffeeMachineState> {
  PeripheralCoffeeMachineCubit()
    : super(
        const PeripheralCoffeeMachineState(
          cupsBrewed: 0,
          currentOrder: null,
          brewProgress: .idle,
        ),
      );

  static const _progressStep = 10;

  Timer? _brewTimer;
  StreamSubscription? _connectionSub;

  void init() {
    UniversalBlePeripheral.setReadRequestHandlers(_onReadRequest);

    UniversalBlePeripheral.setWriteRequestHandlers(_onWriteRequest);

    _connectionSub = UniversalBlePeripheral.connectionStateStream.listen(
      _onConnectionStateChange,
    );
  }

  void disconnect() => emit(state.copyWith(isDisconnected: true));

  void _onConnectionStateChange(BlePeripheralConnectionStateChanged event) {
    if (!event.connected) {
      disconnect();
    }
  }

  void brewManually() => emit(state.copyWith(cupsBrewed: state.cupsBrewed + 1));

  PeripheralReadRequestResult? _onReadRequest(
    String deviceId,
    String characteristicId,
    int offset,
    Uint8List? value,
  ) {
    if (characteristicId == cupsBrewedCharacteristicUuid) {
      return PeripheralReadRequestResult(
        value: uInt8ListFromInt(state.cupsBrewed),
      );
    } else {
      return null;
    }
  }

  PeripheralWriteRequestResult? _onWriteRequest(
    String deviceId,
    String characteristicId,
    int offset,
    Uint8List? value,
  ) {
    if (characteristicId != brewCharacteristicUuid || value == null) {
      return null;
    }

    final index = intFromUint8List(value);
    if (index < 0 || index >= CupSize.values.length) {
      return null;
    }

    if (state.brewProgress.status != .brewing) {
      _startBrewing(CupSize.values[index]);
    }
    return PeripheralWriteRequestResult();
  }

  void _startBrewing(CupSize size) {
    _brewTimer?.cancel();

    _publish(
      state.copyWith(
        currentOrder: size,
        brewProgress: const BrewProgress(status: .brewing, progress: 0),
      ),
    );

    _brewTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final progress = state.brewProgress.progress + _progressStep;

      if (progress >= 100) {
        timer.cancel();
        _publish(
          state.copyWith(
            cupsBrewed: state.cupsBrewed + 1,
            brewProgress: const BrewProgress(status: .ready, progress: 100),
          ),
        );
      } else {
        _publish(
          state.copyWith(
            brewProgress: BrewProgress(status: .brewing, progress: progress),
          ),
        );
      }
    });
  }

  void _publish(PeripheralCoffeeMachineState newState) {
    emit(newState);

    UniversalBlePeripheral.updateCharacteristicValue(
      characteristicId: brewProgressCharacteristicUuid,
      value: newState.brewProgress.toBytes(),
    );
  }

  @override
  Future<void> close() {
    _brewTimer?.cancel();
    _brewTimer = null;

    _connectionSub?.cancel();
    _connectionSub = null;

    return super.close();
  }
}
