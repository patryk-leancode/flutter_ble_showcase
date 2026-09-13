import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_showcase/features/central/central_cubit.dart';
import 'package:flutter_ble_showcase/features/central/central_list/central_list_page.dart';
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
            CentralDataState() => _PeripheralList(argsList: state.peripherals),
            CentralConnectingState() => _Loading(state: state),
            CentralConnectedState() => _Connected(args: state.peripheral),
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
  const _PeripheralList({required this.argsList});

  final List<DiscoveredEventArgs> argsList;

  @override
  Widget build(BuildContext context) {
    void onPeripheralTap(DiscoveredEventArgs peripheral) {
      // context.read<CentralCubit>().connectToPeripheral(uuid: peripheral.uuid);
    }

    return Column(
      children: [
        Container(
          width: .infinity,
          color: ColorScheme.of(context).surface,
          child: Padding(
            padding: const .all(16.0),
            child: Text(
              'Found ${argsList.length} devices',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: .center,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: argsList.length,
            itemBuilder: (context, index) {
              final args = argsList[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: ColorScheme.of(context).surface,
                  child: Text('${index + 1}'),
                ),
                title: Text(args.advertisement.name ?? 'Name not available'),
                subtitle: Text(args.peripheral.uuid.toString()),
                tileColor: Theme.of(context).colorScheme.secondaryFixed,
                onTap: () => onPeripheralTap(args),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 8.0),
          ),
        ),
      ],
    );
  }
}

class _Connected extends StatelessWidget {
  const _Connected({required this.args});

  final DiscoveredEventArgs args;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Connected to ${args.advertisement.name ?? 'Name not available'}!',
        style: Theme.of(context).textTheme.headlineMedium,
        textAlign: .center,
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
        textAlign: .center,
      ),
    );
  }
}
