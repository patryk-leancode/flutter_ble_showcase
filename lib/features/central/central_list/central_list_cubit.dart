import 'package:flutter_bloc/flutter_bloc.dart';

enum CentralListState { ready, disconnecting, disconnected }

class CentralListCubit extends Cubit<CentralListState> {
  CentralListCubit() : super(CentralListState.ready);

  Future<void> disconnect() async {
    emit(CentralListState.disconnecting);
    // TODO: disconnect
    emit(CentralListState.disconnected);
  }
}
