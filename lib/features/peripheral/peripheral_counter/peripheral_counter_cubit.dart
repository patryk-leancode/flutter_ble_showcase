import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

sealed class PeripheralCounterState {
  const PeripheralCounterState({
    required this.peripheralValue,
    required this.centralValue,
    required this.peripheralStreamValue,
    required this.areButtonsEnabled,
    required this.isLoading,
  });

  final int peripheralValue;
  final int centralValue;
  final int peripheralStreamValue;
  final bool areButtonsEnabled;
  final bool isLoading;
}

final class PeripheralCounterReadyState extends PeripheralCounterState {
  const PeripheralCounterReadyState({
    required super.peripheralValue,
    required super.centralValue,
    required super.peripheralStreamValue,
  }) : super(areButtonsEnabled: true, isLoading: false);
}

class PeripheralCounterCubit extends Cubit<PeripheralCounterState> {
  PeripheralCounterCubit()
    : super(
        const PeripheralCounterReadyState(
          peripheralValue: 0,
          centralValue: 0,
          peripheralStreamValue: 0,
        ),
      );

  StreamSubscription? _readSub;
  StreamSubscription? _writeSub;

  void init() {
    // _readSub = _manager.characteristicReadRequestsStream.listen(_onReadRequest);
    // _writeSub = _manager.characteristicWriteRequestsStream.listen(
    //   _onWriteRequest,
    // );
  }

  void increment() => _updateValue(state.peripheralValue + 1);

  void decrement() => _updateValue(state.peripheralValue - 1);

  void incrementStream() => _updateStreamValue(state.peripheralStreamValue + 1);

  void decrementStream() => _updateStreamValue(state.peripheralStreamValue - 1);

  void _updateValue(int value) {
    emit(
      PeripheralCounterReadyState(
        peripheralValue: value,
        centralValue: state.centralValue,
        peripheralStreamValue: state.peripheralStreamValue,
      ),
    );
  }

  void _updateStreamValue(int value) {
    // _manager.notifyListener(
    //   serviceUuid: counterServiceUuid,
    //   characteristicUuid: counterNotifyCharacteristicUuid,
    //   value: value,
    // );
    emit(
      PeripheralCounterReadyState(
        peripheralValue: state.peripheralValue,
        centralValue: state.centralValue,
        peripheralStreamValue: value,
      ),
    );
  }

  // void _onReadRequest(BleCharacteristicReadRequest request) {
  //   if (request.uuid == counterReadCharacteristicUuid) {
  //     request.respond(state.peripheralValue);
  //   }
  // }

  // void _onWriteRequest(BleCharacteristicWriteRequest request) {
  //   if (request.uuid == counterWriteCharacteristicUuid) {
  //     emit(
  //       PeripheralCounterReadyState(
  //         peripheralValue: state.peripheralValue,
  //         centralValue: request.value,
  //         peripheralStreamValue: state.peripheralStreamValue,
  //       ),
  //     );
  //   }
  // }

  @override
  Future<void> close() {
    _readSub?.cancel();
    _readSub = null;

    _writeSub?.cancel();
    _writeSub = null;

    return super.close();
  }
}
