import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:universal_ble/universal_ble.dart';

enum PeripheralListState { ready, disconnected }

class PeripheralListCubit extends Cubit<PeripheralListState> {
  PeripheralListCubit() : super(PeripheralListState.ready);

  StreamSubscription? _connectionSub;

  Future<void> init() async {
    _connectionSub = UniversalBlePeripheral.connectionStateStream.listen(
      _onConnectionStateChange,
    );
  }

  void disconnect() {
    emit(PeripheralListState.disconnected);
  }

  void _onConnectionStateChange(BlePeripheralConnectionStateChanged event) {
    if (!event.connected) {
      emit(PeripheralListState.disconnected);
    }
  }

  @override
  Future<void> close() {
    _connectionSub?.cancel();
    _connectionSub = null;

    return super.close();
  }
}
