import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_showcase/features/central/central_cubit.dart';
import 'package:flutter_ble_showcase/features/central/central_list/central_list_page.dart';
import 'package:flutter_ble_showcase/model/peripheral.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CentralPage extends StatelessWidget {
  const CentralPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CentralCubit>(
      create: (context) => CentralCubit(context.read<CentralManager>())..init(),
      child: const _CentralScreen(),
    );
  }
}

class _CentralScreen extends StatelessWidget {
  const _CentralScreen();

  @override
  Widget build(BuildContext context) {
    void listener(BuildContext context, CentralState state) {
      switch (state) {
        case CentralInitializingState():
        case CentralSearchingState():
        case CentralDataState():
        case CentralConnectingState():
        case CentralErrorState():
          break;
        case CentralConnectedState():
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const CentralListPage()),
            (route) => false,
          );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Central'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocConsumer<CentralCubit, CentralState>(
        listener: listener,
        builder: (context, state) {
          return switch (state) {
            CentralInitializingState() => _Loading(state: state),
            CentralSearchingState() => _Loading(state: state),
            CentralDataState() => _PeripheralList(
              peripherals: state.peripherals,
            ),
            CentralConnectingState() => _Loading(state: state),
            CentralConnectedState() => _Connected(peripheral: state.peripheral),
            CentralErrorState() => const _Error(),
          };
        },
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({required this.state});

  final CentralLoadingState state;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        state.loadingText,
        style: Theme.of(context).textTheme.headlineMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _PeripheralList extends StatelessWidget {
  const _PeripheralList({required this.peripherals});

  final List<DetectedPeripheralModel> peripherals;

  @override
  Widget build(BuildContext context) {
    void onPeripheralTap(DetectedPeripheralModel peripheral) {
      // context.read<CentralCubit>().connectToPeripheral(uuid: peripheral.uuid);
    }

    return ListView.separated(
      itemCount: peripherals.length,
      itemBuilder: (context, index) {
        final peripheral = peripherals[index];
        return ListTile(
          title: Text(peripheral.name),
          subtitle: Text(peripheral.uuid),
          tileColor: Theme.of(context).colorScheme.secondaryFixed,
          onTap: () => onPeripheralTap(peripheral),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 8.0),
    );
  }
}

class _Connected extends StatelessWidget {
  const _Connected({required this.peripheral});

  final DetectedPeripheralModel peripheral;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Connected to ${peripheral.name}!',
        style: Theme.of(context).textTheme.headlineMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Error',
        style: Theme.of(context).textTheme.headlineMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}
