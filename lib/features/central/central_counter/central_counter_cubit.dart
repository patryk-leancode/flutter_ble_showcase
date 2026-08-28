import 'dart:async';

import 'package:bloc/bloc.dart';

sealed class CentralCounterState {
  const CentralCounterState({
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

final class CentralCounterReadyState extends CentralCounterState {
  const CentralCounterReadyState({
    required super.peripheralValue,
    required super.centralValue,
    required super.peripheralStreamValue,
  }) : super(areButtonsEnabled: true, isLoading: false);
}

final class CentralCounterLoadingState extends CentralCounterState {
  const CentralCounterLoadingState({
    required super.peripheralValue,
    required super.centralValue,
    required super.peripheralStreamValue,
  }) : super(areButtonsEnabled: false, isLoading: true);
}

class CentralCounterCubit extends Cubit<CentralCounterState> {
  CentralCounterCubit()
    : super(
        const CentralCounterReadyState(
          peripheralValue: 0,
          centralValue: 0,
          peripheralStreamValue: 0,
        ),
      );

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
      ),
    );

    // final value = await _manager.read(
    //   serviceUuid: counterServiceUuid,
    //   characteristicUuid: counterReadCharacteristicUuid,
    // );

    // emit(
    //   CentralCounterReadyState(
    //     peripheralValue: value,
    //     centralValue: state.centralValue,
    //     peripheralStreamValue: state.peripheralStreamValue,
    //   ),
    // );
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

  @override
  Future<void> close() {
    sub?.cancel();
    sub = null;

    return super.close();
  }
}
