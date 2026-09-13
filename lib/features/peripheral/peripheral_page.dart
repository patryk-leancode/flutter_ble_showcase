import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_showcase/features/peripheral/peripheral_cubit.dart';
import 'package:flutter_ble_showcase/features/peripheral/peripheral_list/peripheral_list_page.dart';
import 'package:flutter_ble_showcase/usecase/check_ble_permissions_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PeripheralPage extends StatelessWidget {
  const PeripheralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PeripheralCubit>(
      create: (context) => PeripheralCubit(
        context.read<PeripheralManager>(),
        context.read<CheckBlePermissionsUsecase>(),
      )..init(),
      child: const _PeripheralScreen(),
    );
  }
}

class _PeripheralScreen extends StatelessWidget {
  const _PeripheralScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peripheral'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: BlocConsumer<PeripheralCubit, PeripheralState>(
          listener: (context, state) {
            if (state is PeripheralConnectedState) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const PeripheralListPage(),
                ),
                (route) => false,
              );
            }
          },
          builder: (context, state) {
            return switch (state) {
              PeripheralInitializingState() => const _PeripheralInitializing(),
              PeripheralErrorState() => const _PeripheralInitializing(),
              PeripheralDataState() => _PeripheralInitialized(state: state),
              PeripheralConnectedState() => const _PeripheralConnected(),
            };
          },
        ),
      ),
    );
  }
}

class _PeripheralInitializing extends StatelessWidget {
  const _PeripheralInitializing();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Initializing BLE Peripheral...',
      style: Theme.of(context).textTheme.headlineMedium,
      textAlign: TextAlign.center,
    );
  }
}

class _PeripheralInitialized extends StatelessWidget {
  const _PeripheralInitialized({required this.state});

  final PeripheralDataState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Name:', style: Theme.of(context).textTheme.headlineSmall),
        Text(state.model.name, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const PeripheralListPage()),
            (route) => false,
          ),
          child: const Text('Continue'),
        ),
      ],
    );
  }
}

class _PeripheralConnected extends StatelessWidget {
  const _PeripheralConnected();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Connected to a Central!',
      style: Theme.of(context).textTheme.headlineMedium,
      textAlign: TextAlign.center,
    );
  }
}
