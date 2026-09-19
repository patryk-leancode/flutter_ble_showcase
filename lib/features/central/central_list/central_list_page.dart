import 'package:flutter/material.dart';
import 'package:flutter_ble_showcase/features/central/central_counter/central_counter_page.dart';
import 'package:flutter_ble_showcase/features/central/central_list/central_list_cubit.dart';
import 'package:flutter_ble_showcase/features/home/home_page.dart';
import 'package:flutter_ble_showcase/widgets/bluetooth_features_list.dart';
import 'package:flutter_ble_showcase/widgets/loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_ble/universal_ble.dart';

class CentralListPage extends StatelessWidget {
  const CentralListPage({super.key, required this.connectedDevice});

  final BleDevice connectedDevice;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CentralListCubit(connectedDevice: connectedDevice),
      child: const _CentralListScreen(),
    );
  }
}

class _CentralListScreen extends StatelessWidget {
  const _CentralListScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Central - List')),
      body: BlocConsumer<CentralListCubit, CentralListState>(
        listenWhen: (previous, current) =>
            current == CentralListState.disconnected,
        listener: (context, state) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        },
        builder: (context, state) {
          return Stack(
            alignment: Alignment.center,
            children: [
              const _Content(),
              if (state == CentralListState.disconnecting) const Loader(),
            ],
          );
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    void onCounterTap() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const CentralCounterPage()),
      );
    }

    void onDisconnectTap() => context.read<CentralListCubit>().disconnect();

    return BluetoothFeaturesList(
      onCounterTap: onCounterTap,
      onDisconnectTap: onDisconnectTap,
    );
  }
}
