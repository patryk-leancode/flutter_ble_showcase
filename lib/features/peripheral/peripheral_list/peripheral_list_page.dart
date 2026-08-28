import 'package:flutter/material.dart';
import 'package:flutter_ble_showcase/features/home/home_page.dart';
import 'package:flutter_ble_showcase/features/peripheral/peripheral_counter/peripheral_counter_page.dart';
import 'package:flutter_ble_showcase/features/peripheral/peripheral_list/peripheral_list_cubit.dart';
import 'package:flutter_ble_showcase/widgets/bluetooth_features_list.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PeripheralListPage extends StatelessWidget {
  const PeripheralListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PeripheralListCubit()..init(),
      child: const _PeripheralListScreen(),
    );
  }
}

class _PeripheralListScreen extends StatelessWidget {
  const _PeripheralListScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peripheral - List'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocConsumer<PeripheralListCubit, PeripheralListState>(
        listenWhen: (previous, current) =>
            current == PeripheralListState.disconnected,
        listener: (context, state) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        },
        builder: (context, state) => const _Content(),
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
        MaterialPageRoute(builder: (context) => const PeripheralCounterPage()),
      );
    }

    void onDisconnectTap() {
      context.read<PeripheralListCubit>().disconnect();
    }

    return BluetoothFeaturesList(
      onCounterTap: onCounterTap,
      onDisconnectTap: onDisconnectTap,
    );
  }
}
