import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter_ble_showcase/model/ble_connection_state.dart';

enum PeripheralListState { ready, disconnected }

class PeripheralListCubit extends Cubit<PeripheralListState> {
  PeripheralListCubit() : super(PeripheralListState.ready);

  StreamSubscription? sub;

  Future<void> init() async {
    // if (Platform.isAndroid) {
    //   sub = _manager.connectionStateStream.listen(_onConnectionStateChange);
    // }
  }

  void disconnect() {
    emit(PeripheralListState.disconnected);
  }

  void _onConnectionStateChange(BleConnectionState state) {
    if (state == BleConnectionState.disconnected) {
      emit(PeripheralListState.disconnected);
    }
  }

  @override
  Future<void> close() {
    sub?.cancel();
    sub = null;

    return super.close();
  }
}
