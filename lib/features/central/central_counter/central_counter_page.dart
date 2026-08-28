import 'package:flutter/material.dart';
import 'package:flutter_ble_showcase/features/central/central_counter/central_counter_cubit.dart';
import 'package:flutter_ble_showcase/widgets/loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CentralCounterPage extends StatelessWidget {
  const CentralCounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CentralCounterCubit()..init(),
      child: const _CentralCounterScreen(),
    );
  }
}

class _CentralCounterScreen extends StatelessWidget {
  const _CentralCounterScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Central - Counter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocBuilder<CentralCounterCubit, CentralCounterState>(
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
    required this.centralValue,
    required this.peripheralStreamValue,
    required this.areButtonsEnabled,
  });

  final int peripheralValue;
  final int centralValue;
  final int peripheralStreamValue;
  final bool areButtonsEnabled;

  @override
  Widget build(BuildContext context) {
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
          _RefreshButton(enabled: areButtonsEnabled),
          const SizedBox(height: 64.0),
          Text(
            'Central Counter value:',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          _Counter(value: centralValue),
          const SizedBox(height: 16.0),
          _CounterButtons(enabled: areButtonsEnabled),
          const SizedBox(height: 64.0),
          Text(
            'Peripheral Stream Counter value:',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          _Counter(value: peripheralStreamValue),
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

class _RefreshButton extends StatelessWidget {
  const _RefreshButton({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    void onRefreshTap() => context.read<CentralCounterCubit>().refresh();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: ElevatedButton(
        onPressed: enabled ? onRefreshTap : null,
        child: const Text('Refresh'),
      ),
    );
  }
}

class _CounterButtons extends StatelessWidget {
  const _CounterButtons({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    void onPlusTap() => context.read<CentralCounterCubit>().increment();
    void onMinusTap() => context.read<CentralCounterCubit>().decrement();

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
