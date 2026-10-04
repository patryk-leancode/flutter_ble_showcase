import 'package:flutter/material.dart';
import 'package:flutter_ble_showcase/features/central/central_coffee_machine/central_coffee_machine_cubit.dart';
import 'package:flutter_ble_showcase/features/home/home_page.dart';
import 'package:flutter_ble_showcase/model/coffee_machine.dart';
import 'package:flutter_ble_showcase/widgets/loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_ble/universal_ble.dart';

class CentralCoffeeMachinePage extends StatelessWidget {
  const CentralCoffeeMachinePage({
    super.key,
    required this.connectedPeripheral,
  });

  final BleDevice connectedPeripheral;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CentralCoffeeMachineCubit(connectedPeripheral: connectedPeripheral)
            ..init(),
      child: const _CentralCoffeeMachineScreen(),
    );
  }
}

class _CentralCoffeeMachineScreen extends StatelessWidget {
  const _CentralCoffeeMachineScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Central'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                await context.read<CentralCoffeeMachineCubit>().disconnect();
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: const Text('Disconnect'),
            ),
          ),
        ],
      ),
      body: BlocBuilder<CentralCoffeeMachineCubit, CentralCoffeeMachineState>(
        builder: (context, state) {
          return Stack(
            alignment: Alignment.center,
            children: [
              state.isError ? const _Error() : _Content(state: state),
              if (state.isLoading) const Loader(),
            ],
          );
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state});

  final CentralCoffeeMachineState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final progress = state.brewProgress;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Companion App', style: textTheme.displayMedium),
            const SizedBox(height: 48.0),
            Text('Cups brewed:', style: textTheme.headlineSmall),
            Text('${state.cupsBrewed}', style: textTheme.displayLarge),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: state.isLoading
                  ? null
                  : context.read<CentralCoffeeMachineCubit>().refresh,
              child: const Text('Refresh'),
            ),
            const SizedBox(height: 48.0),
            SegmentedButton<CupSize>(
              segments: [
                for (final size in CupSize.values)
                  ButtonSegment(value: size, label: Text(size.label)),
              ],
              selected: {state.selectedCupSize},
              onSelectionChanged: (selection) => context
                  .read<CentralCoffeeMachineCubit>()
                  .selectCupSize(selection.first),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: state.canBrew
                  ? context.read<CentralCoffeeMachineCubit>().brew
                  : null,
              child: const Text('Brew'),
            ),
            const SizedBox(height: 48.0),
            Text('Brew progress:', style: textTheme.headlineSmall),
            const SizedBox(height: 16.0),
            LinearProgressIndicator(value: progress.progress / 100),
            const SizedBox(height: 8.0),
            Text(progress.status.label, style: textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Error while performing BLE operation'));
  }
}
