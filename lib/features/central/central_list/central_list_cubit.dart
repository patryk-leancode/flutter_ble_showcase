import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_ble/universal_ble.dart';

enum CentralListState { ready, disconnecting, disconnected }

class CentralListCubit extends Cubit<CentralListState> {
  CentralListCubit({required this.connectedDevice})
    : super(CentralListState.ready);

  final BleDevice connectedDevice;

  Future<void> disconnect() async {
    emit(CentralListState.disconnecting);
    connectedDevice.connectionStream.listen(_onConnectionStateChanged);
    await connectedDevice.disconnect();
  }

  void _onConnectionStateChanged(bool isConnected) {
    if (!isConnected) {
      emit(CentralListState.disconnected);
    }
  }
}
