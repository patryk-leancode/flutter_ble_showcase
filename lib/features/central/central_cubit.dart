import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';

sealed class CentralState {
  const CentralState();

  List<DiscoveredEventArgs> get peripherals => [];
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
  final List<DiscoveredEventArgs> peripherals;
}

final class CentralConnectingState extends CentralLoadingState {
  const CentralConnectingState({required this.peripheral});

  final DiscoveredEventArgs peripheral;

  @override
  String get loadingText => 'Connecting to ${peripheral.advertisement.name}...';
}

final class CentralConnectedState extends CentralState {
  const CentralConnectedState({required this.peripheral});

  final DiscoveredEventArgs peripheral;
}

final class CentralErrorState extends CentralState {
  const CentralErrorState();
}

class CentralCubit extends Cubit<CentralState> {
  CentralCubit(this._manager) : super(const CentralInitializingState());

  final CentralManager _manager;

  StreamSubscription? _discoverySub;
  StreamSubscription? _deviceSub;

  List<DiscoveredEventArgs> get _peripherals => state.peripherals;

  Future<void> init() async {
    print('CentralCubit.init()');
    emit(const CentralSearchingState());

    _discoverySub = _manager.discovered.listen(_onDetectedDevice);

    final state = _manager.state;
    if (state == .poweredOn) {
      _manager.startDiscovery();
    } else {
      _deviceSub = _manager.stateChanged.listen(_onDeviceStateChanged);
    }
  }

  Future<void> connectToPeripheral({required String uuid}) async {
    print('CentralCubit.connectToPeripheral: $uuid');
    // final peripheral = _peripherals.firstWhereOrNull((p) => p.uuid == uuid);

    // if (peripheral == null) {
    //   emit(const CentralErrorState());
    //   return;
    // }

    // emit(CentralConnectingState(peripheral: peripheral));

    // await _manager.connectToDevice(uuid: uuid);
    // emit(CentralConnectedState(peripheral: peripheral));
  }

  void _onDetectedDevice(DiscoveredEventArgs discovered) {
    print('CentralCubit._onDetectedDevice: $discovered');
    final peripherals = [..._peripherals, discovered];
    emit(CentralDataState(peripherals: peripherals));
  }

  void _onDeviceStateChanged(BluetoothLowEnergyStateChangedEventArgs args) {
    print('CentralCubit._onDeviceStateChanged: $args');
    if (args.state == .poweredOn) {
      _manager.startDiscovery();
    }
  }

  @override
  Future<void> close() {
    print('CentralCubit.close');
    _discoverySub?.cancel();
    _discoverySub = null;

    _manager.stopDiscovery();

    return super.close();
  }
}
