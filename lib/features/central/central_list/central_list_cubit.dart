import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_ble/universal_ble.dart';

enum CentralListState { ready, disconnecting, disconnected }

class CentralListCubit extends Cubit<CentralListState> {
  CentralListCubit({required this.connectedDevice})
    : super(CentralListState.ready);

  final BleDevice connectedDevice;

  StreamSubscription? _connectionSub;

  Future<void> disconnect() async {
    emit(CentralListState.disconnecting);
    _connectionSub = connectedDevice.connectionStream.listen(
      _onConnectionStateChanged,
    );
    await connectedDevice.disconnect();
  }

  void _onConnectionStateChanged(bool isConnected) {
    if (!isConnected) {
      emit(CentralListState.disconnected);
    }
  }

  @override
  Future<void> close() {
    _connectionSub?.cancel();
    _connectionSub = null;

    return super.close();
  }
}
