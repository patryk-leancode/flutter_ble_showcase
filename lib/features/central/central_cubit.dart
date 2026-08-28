import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:flutter_ble_showcase/model/peripheral.dart';

sealed class CentralState {
  const CentralState();

  List<DetectedPeripheralModel> get peripherals => [];
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
  final List<DetectedPeripheralModel> peripherals;
}

final class CentralConnectingState extends CentralLoadingState {
  const CentralConnectingState({required this.peripheral});

  final DetectedPeripheralModel peripheral;

  @override
  String get loadingText => 'Connecting to ${peripheral.name}...';
}

final class CentralConnectedState extends CentralState {
  const CentralConnectedState({required this.peripheral});

  final DetectedPeripheralModel peripheral;
}

final class CentralErrorState extends CentralState {
  const CentralErrorState();
}

class CentralCubit extends Cubit<CentralState> {
  CentralCubit(this._manager) : super(const CentralInitializingState());

  final CentralManager _manager;

  StreamSubscription? _sub;

  List<DetectedPeripheralModel> get _peripherals => state.peripherals;

  Future<void> init() async {
    emit(const CentralSearchingState());

    _sub = _manager.discovered
        .map(_mapDevice)
        .where((d) => d != null)
        .cast<DetectedPeripheralModel>()
        .listen(_onDetectedDevice);

    // TODO: Pass UUID Here
    _manager.startDiscovery();
  }

  // Future<void> connectToPeripheral({required String uuid}) async {
  //   final peripheral = _peripherals.firstWhereOrNull((p) => p.uuid == uuid);

  //   if (peripheral == null) {
  //     emit(const CentralErrorState());
  //     return;
  //   }

  //   emit(CentralConnectingState(peripheral: peripheral));

  //   await _manager.connectToDevice(uuid: uuid);
  //   emit(CentralConnectedState(peripheral: peripheral));
  // }

  DetectedPeripheralModel? _mapDevice(DiscoveredEventArgs discovered) {
    final uuid = discovered.peripheral.uuid;
    final name = discovered.advertisement.name;
    if (name == null) {
      return null;
    }
    return DetectedPeripheralModel(name: name, uuid: uuid.toString());
  }

  void _onDetectedDevice(DetectedPeripheralModel peripheral) {
    final peripherals = [..._peripherals, peripheral];
    emit(CentralDataState(peripherals: peripherals));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _sub = null;

    _manager.stopDiscovery();

    return super.close();
  }
}
