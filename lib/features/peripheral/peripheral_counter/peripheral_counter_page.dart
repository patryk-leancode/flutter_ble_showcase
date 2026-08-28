import 'package:flutter/material.dart';
import 'package:flutter_ble_showcase/features/peripheral/peripheral_counter/peripheral_counter_cubit.dart';
import 'package:flutter_ble_showcase/widgets/loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PeripheralCounterPage extends StatelessWidget {
  const PeripheralCounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PeripheralCounterCubit()..init(),
      child: const _PeripheralCounterScreen(),
    );
  }
}

class _PeripheralCounterScreen extends StatelessWidget {
  const _PeripheralCounterScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peripheral - Counter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocBuilder<PeripheralCounterCubit, PeripheralCounterState>(
        builder: (context, state) {
          return Stack(
            alignment: Alignment.center,
            children: [
              _Content(
                peripheralValue: state.peripheralValue,
                centralValue: state.centralValue,
                peripheralStreamValue: state.peripheralStreamValue,
                areButtonsEnabled: state.areButtonsEnabled,
              ),
              if (state.isLoading) const Loader(),
            ],
          );
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.peripheralValue,
    required this.areButtonsEnabled,
    required this.peripheralStreamValue,
    required this.centralValue,
  });

  final int peripheralValue;
  final int centralValue;
  final int peripheralStreamValue;
  final bool areButtonsEnabled;

  @override
  Widget build(BuildContext context) {
    PeripheralCounterCubit cubit() => context.read<PeripheralCounterCubit>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Peripheral Counter value:',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          _Counter(value: peripheralValue),
          const SizedBox(height: 16.0),
          _CounterButtons(
            enabled: areButtonsEnabled,
            onPlusTap: cubit().increment,
            onMinusTap: cubit().decrement,
          ),
          const SizedBox(height: 64.0),
          Text(
            'Central Counter value:',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          _Counter(value: centralValue),
          const SizedBox(height: 64.0),
          Text(
            'Peripheral Stream Counter value:',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          _Counter(value: peripheralStreamValue),
          const SizedBox(height: 16.0),
          _CounterButtons(
            enabled: areButtonsEnabled,
            onPlusTap: cubit().incrementStream,
            onMinusTap: cubit().decrementStream,
          ),
        ],
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Text('$value', style: Theme.of(context).textTheme.displayLarge);
  }
}

class _CounterButtons extends StatelessWidget {
  const _CounterButtons({
    required this.enabled,
    required this.onPlusTap,
    required this.onMinusTap,
  });

  final bool enabled;
  final VoidCallback onPlusTap;
  final VoidCallback onMinusTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Row(
        children: [
          const Spacer(),
          ElevatedButton(
            onPressed: enabled ? onMinusTap : null,
            child: const Icon(Icons.remove),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: enabled ? onPlusTap : null,
            child: const Icon(Icons.add),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
