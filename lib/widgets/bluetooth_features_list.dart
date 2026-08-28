import 'package:flutter/material.dart';

class BluetoothFeaturesList extends StatelessWidget {
  const BluetoothFeaturesList({
    super.key,
    required this.onCounterTap,
    this.onDisconnectTap,
  });

  final VoidCallback onCounterTap;
  final VoidCallback? onDisconnectTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ListTile(
          title: const Text('Counter'),
          trailing: const Icon(Icons.chevron_right),
          tileColor: Theme.of(context).colorScheme.secondaryFixed,
          onTap: onCounterTap,
        ),
        if (onDisconnectTap != null) ...[
          const SizedBox(height: 8.0),
          ListTile(
            title: const Text('Disconnect'),
            tileColor: Theme.of(context).colorScheme.secondaryFixed,
            onTap: onDisconnectTap,
          ),
        ],
      ],
    );
  }
}
