import 'package:flutter/material.dart';
import 'package:flutter_ble_showcase/features/home/home_page.dart';
import 'package:flutter_ble_showcase/features/peripheral/peripheral_coffee_machine/peripheral_coffee_machine_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PeripheralCoffeeMachinePage extends StatelessWidget {
  const PeripheralCoffeeMachinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PeripheralCoffeeMachineCubit()..init(),
      child: const _PeripheralCoffeeMachineScreen(),
    );
  }
}

class _PeripheralCoffeeMachineScreen extends StatelessWidget {
  const _PeripheralCoffeeMachineScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peripheral'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: context.read<PeripheralCoffeeMachineCubit>().disconnect,
            child: const Text('Disconnect'),
          ),
        ],
      ),
      body:
          BlocConsumer<
            PeripheralCoffeeMachineCubit,
            PeripheralCoffeeMachineState
          >(
            listenWhen: (previous, current) => current.isDisconnected,
            listener: (context, state) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
            builder: (context, state) => _Content(state: state),
          ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state});

  final PeripheralCoffeeMachineState state;

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
            Text('Coffe Machine', style: textTheme.displayMedium),
            const SizedBox(height: 48.0),
            Text('Cups brewed:', style: textTheme.headlineSmall),
            Text('${state.cupsBrewed}', style: textTheme.displayLarge),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: context
                  .read<PeripheralCoffeeMachineCubit>()
                  .brewManually,
              child: const Text('Brew manually'),
            ),
            const SizedBox(height: 64.0),
            Text('Current order:', style: textTheme.headlineSmall),
            Text(
              state.currentOrder?.label ?? '—',
              style: textTheme.displaySmall,
            ),
            const SizedBox(height: 64.0),
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
