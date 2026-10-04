import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:flutter_ble_showcase/model/coffee_machine.dart';
import 'package:flutter_ble_showcase/util/utils.dart';
import 'package:universal_ble/universal_ble.dart';

sealed class CentralCoffeeMachineState {
  const CentralCoffeeMachineState({
    required this.cupsBrewed,
    required this.selectedCupSize,
    required this.brewProgress,
    required this.isLoading,
    required this.isError,
  });

  final int cupsBrewed;
  final CupSize selectedCupSize;
  final BrewProgress brewProgress;
  final bool isLoading;
  final bool isError;

  bool get canBrew => !isLoading && brewProgress.status != .brewing;

  CentralCoffeeMachineState copyWith({
    int? cupsBrewed,
    CupSize? selectedCupSize,
    BrewProgress? brewProgress,
    bool? isError,
  });
}

final class CentralCoffeeMachineReadyState extends CentralCoffeeMachineState {
  const CentralCoffeeMachineReadyState({
    required super.cupsBrewed,
    required super.selectedCupSize,
    required super.brewProgress,
    super.isError = false,
  }) : super(isLoading: false);

  @override
  CentralCoffeeMachineState copyWith({
    int? cupsBrewed,
    CupSize? selectedCupSize,
    BrewProgress? brewProgress,
    bool? isError,
  }) {
    return CentralCoffeeMachineReadyState(
      cupsBrewed: cupsBrewed ?? this.cupsBrewed,
      selectedCupSize: selectedCupSize ?? this.selectedCupSize,
      brewProgress: brewProgress ?? this.brewProgress,
      isError: isError ?? this.isError,
    );
  }
}

final class CentralCoffeeMachineLoadingState extends CentralCoffeeMachineState {
  const CentralCoffeeMachineLoadingState({
    required super.cupsBrewed,
    required super.selectedCupSize,
    required super.brewProgress,
    super.isError = false,
  }) : super(isLoading: true);

  @override
  CentralCoffeeMachineState copyWith({
    int? cupsBrewed,
    CupSize? selectedCupSize,
    BrewProgress? brewProgress,
    bool? isError,
  }) {
    return CentralCoffeeMachineLoadingState(
      cupsBrewed: cupsBrewed ?? this.cupsBrewed,
      selectedCupSize: selectedCupSize ?? this.selectedCupSize,
      brewProgress: brewProgress ?? this.brewProgress,
      isError: isError ?? this.isError,
    );
  }
}

class CentralCoffeeMachineCubit extends Cubit<CentralCoffeeMachineState> {
  CentralCoffeeMachineCubit({required this.connectedPeripheral})
    : super(
        const CentralCoffeeMachineReadyState(
          cupsBrewed: 0,
          selectedCupSize: .medium,
          brewProgress: .idle,
        ),
      );

  final BleDevice connectedPeripheral;

  StreamSubscription? sub;

  void init() async {
    final characteristic = await connectedPeripheral.getCharacteristic(
      brewProgressCharacteristicUuid,
      service: coffeeMachineServiceUuid,
    );

    sub = characteristic.notifications.listen(_onProgressUpdate);
    await characteristic.notifications.subscribe();
  }

  Future<void> refresh() async {
    emit(
      CentralCoffeeMachineLoadingState(
        cupsBrewed: state.cupsBrewed,
        selectedCupSize: state.selectedCupSize,
        brewProgress: state.brewProgress,
      ),
    );

    final characteristic = await connectedPeripheral.getCharacteristic(
      cupsBrewedCharacteristicUuid,
      service: coffeeMachineServiceUuid,
    );

    final value = await characteristic.read();

    emit(
      CentralCoffeeMachineReadyState(
        cupsBrewed: intFromUint8List(value),
        selectedCupSize: state.selectedCupSize,
        brewProgress: state.brewProgress,
      ),
    );
  }

  void selectCupSize(CupSize size) =>
      emit(state.copyWith(selectedCupSize: size));

  Future<void> brew() async {
    final characteristic = await connectedPeripheral.getCharacteristic(
      brewCharacteristicUuid,
      service: coffeeMachineServiceUuid,
    );

    await characteristic.write(
      uInt8ListFromInt(state.selectedCupSize.index),
      withResponse: false,
    );
  }

  Future<void> disconnect() async {
    emit(
      CentralCoffeeMachineLoadingState(
        cupsBrewed: state.cupsBrewed,
        selectedCupSize: state.selectedCupSize,
        brewProgress: state.brewProgress,
      ),
    );

    await connectedPeripheral.disconnect();
  }

  void _onProgressUpdate(Uint8List value) {
    emit(state.copyWith(brewProgress: .fromBytes(value)));
  }

  @override
  Future<void> close() {
    sub?.cancel();
    sub = null;

    return super.close();
  }
}
