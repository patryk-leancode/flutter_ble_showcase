import 'package:flutter/material.dart';
import 'package:flutter_ble_showcase/features/central/central_page.dart';
import 'package:flutter_ble_showcase/features/peripheral/peripheral_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeScreen();
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    void onPeripheralTap() {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const PeripheralPage()));
    }

    void onCentralTap() {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const CentralPage()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            title: const Text('Peripheral'),
            trailing: const Icon(Icons.chevron_right),
            tileColor: Theme.of(context).colorScheme.secondaryFixed,
            onTap: () => onPeripheralTap(),
          ),
          const SizedBox(height: 8.0),
          ListTile(
            title: const Text('Central'),
            trailing: const Icon(Icons.chevron_right),
            tileColor: Theme.of(context).colorScheme.secondaryFixed,
            onTap: () => onCentralTap(),
          ),
        ],
      ),
    );
  }
}
